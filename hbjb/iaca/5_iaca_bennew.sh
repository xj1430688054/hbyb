#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ�������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
  #  read _DBNAME
_DBNAME=iaca42db	
	
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
 #   read _DBUSER
_DBUSER=instiaci
	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
 #   read _PWD
_PWD=password
	
echo ""    
echo "������schema�� ->"|tr -d "\012"
  #  read _SCHEMA
_SCHEMA=instiaci

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############

echo "�����������ֹ���ڣ������� 2020-01-23�� ->"|tr -d "\012"
#	read _CLOSINGDATA
_STARTDATA=2020-01-23


echo "�����������ֹ���ڣ������� 2020-04-05�� ->"|tr -d "\012"
#	read _CLOSINGDATA
_CLOSINGDATA=2020-04-05

echo ""
echo "�����뱾�δ�������� ��������500000�� ->"|tr -d "\012"
#	read _ROWS
_ROWS=500000

echo ""
echo "�����뱣�������أ� �������� �������人 ��420101�� ->"|tr -d "\012"
#	read _ROWS
_CITYCODE=420100

################�밴��������дsql####################

##����������ڼ�ı����������ֱ������� ������

##########����
_NOFLAG=`db2 -x "select count(*) from cacmain_ncp where flag = ''"`
_NOFLAG1=`db2 -x "select count(*) from cacmain_ncp where flag = '' and citycode = '${_CITYCODE}'"`
echo "��ǰ��Ҫ����������� : ${_ROWS}"
echo "��ǰʡ�ܹ�δ����������ǣ� ${_NOFLAG}"
echo "��ǰ���ܹ�δ����������ǣ� ${_NOFLAG}"


####ȡһ��������Ͷ��ȷ����,�������ʱ������
##confirmsequences=`db2 -x "select  CONFIRMSEQUENCENO from cacmain_ncp 
##						where flag = '' and 
##							CITYCODE = '${_CITYCODE}' 
##							order by EFFECTIVEDATE 
##							fetch first ${_ROWS} row only"`
##							
##echo "${confirmsequences}"
##echo "���α�������������"
####����ɵķָ���
##OLD_IFS="$IFS"
####�ָ������óɿո�
##IFS=" "
##array=($confirmsequences)
####���ԭ���ķָ���
##IFS="$OLD_IFS"
##
##
##
######������������ѯ���еı�����
##for X_PolicyConfirmNo in ${array[@]}
##do

echo "${X_PolicyConfirmNo}"
db2 "insert into CACMain_NCPB ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, VIN, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
		select 
		a.CONFIRMSEQUENCENO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.EFFECTIVEDATE,
		a.EXPIREDATE,
		a.VIN,
		a.LICENSENO,
		a.ENGINENO,
		(case 
			when a.EFFECTIVEDATE <  '${_STARTDATA}' and a.EXPIREDATE  > '${_CLOSINGDATA}' 	then  3
			when a.EFFECTIVEDATE > '${_STARTDATA}' and a.EFFECTIVEDATE < '${_CLOSINGDATA}' 		then 2
			when a.EXPIREDATE > '${_STARTDATA}' and a.EXPIREDATE < '${_CLOSINGDATA}' 		then 1
		end ) enddate,
		'',
		'',
		'',
		sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys  , CACMain_NCP a
		left join CACMain_NCP b on a.LASTPOLICYCONFIRMNO = b.CONFIRMSEQUENCENO  
									
		where (   (a.EFFECTIVEDATE <  '${_STARTDATA}' and a.EXPIREDATE  > '${_CLOSINGDATA}') 
				or (a.EFFECTIVEDATE  > '${_STARTDATA}' and a.EFFECTIVEDATE < '${_CLOSINGDATA}')
				or (a.EXPIREDATE > '${_STARTDATA}' and a.EXPIREDATE < '${_CLOSINGDATA}') 
			)
									
			and a.Flag = '' 
			and (   b.EXPIREDATE is null  
					or (  b.flag = '1' 
						  and 	( (values days(date(b.ExpireDate))- days(date(b.EffectiveDate)) ) <= 30
								 or b.BizStatus  = '4' 
								)
					   )
				)
			and a.citycode = '${_CITYCODE}'

			fetch first ${_ROWS} row only

"
##			and a.CONFIRMSEQUENCENO = '${X_PolicyConfirmNo} 

####���
########���ڵ���Ͷ��ȷ����
shortconfirmsequences=`db2 -x "select 
									b.CONFIRMSEQUENCENO 
							from cacmain_ncpb b 
							where b.flag = '' 
								and b.CITYCODE = '${_CITYCODE}' 
								and (values days(date(b.ExpireDate))- days(date(b.EffectiveDate)) ) <= 30							
							"`

		


##����ɵķָ���
OLD_IFS="$IFS"
##�ָ������óɿո�
IFS=" "
arrays1=($shortconfirmsequences)
##���ԭ���ķָ���
IFS="$OLD_IFS"
					
	
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "��ʼ������ڵ���"
echo "${shortconfirmsequences}"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"

for short_PolicyConfirmNo in ${arrays1[@]}
do
	echo "${short_PolicyConfirmNo}"
	db2 "update cacmain_ncpb  set  Reason = '1', Desc='���ڵ�', Flag = '0'  where CONFIRMSEQUENCENO = '${short_PolicyConfirmNo}'"
	db2 "update cacmain_ncp set flag = '0' where CONFIRMSEQUENCENO = '${short_PolicyConfirmNo}'"

done					










####�˱���Ͷ��ȷ����							
endorconfirmsequences=`db2 -x "select 
									a.CONFIRMSEQUENCENO 
							from cacmain_ncpb a
							inner join cacmain_ncp b on a.CONFIRMSEQUENCENO = b.CONFIRMSEQUENCENO 
														and a.CITYCODE = '${_CITYCODE}' 	
														and a.flag = ''
							where 							
							 b.bizstatus = '4'							
							"`


##����ɵķָ���
OLD_IFS="$IFS"
##�ָ������óɿո�
IFS=" "
arrays2=($endorconfirmsequences)	
##���ԭ���ķָ���
IFS="$OLD_IFS"

echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "��ʼ�����˱�����"
echo "${endorconfirmsequences}"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"

for endor_PolicyConfirmNo in ${arrays2[@]}
do	
	echo "${endor_PolicyConfirmNo}"
	endorpolicy=`db2 -x "select AmendConfirmNo  from caphead where ConfirmSequenceNo  = '${endor_PolicyConfirmNo}'"`
	validate=`db2 -x "select ValidDate   from caphead where ConfirmSequenceNo  = '${endor_PolicyConfirmNo}'"`
	
	db2 "update cacmain_ncpb  set  Reason = '2', Desc='�˱�ȷ���룺 ${endorpolicy}, �˱���Ч���ڣ� ${validate}', Flag = '0' where CONFIRMSEQUENCENO = '${endor_PolicyConfirmNo}'"
	db2 "update cacmain_ncp set flag = '0' where CONFIRMSEQUENCENO = '${endor_PolicyConfirmNo}'"
	
done		
							






db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

