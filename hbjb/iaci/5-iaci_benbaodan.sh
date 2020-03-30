#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ�������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
    read _DBNAME
#_DBNAME=iaci42db	
	
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
    read _DBUSER
#_DBUSER=instiaci
	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
    read _PWD
#_PWD=password
	
echo ""    
echo "������schema�� ->"|tr -d "\012"
    read _SCHEMA
#_SCHEMA=instiaci

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
echo "���������鿪ʼ���ڣ������� 2020-01-23�� ->"|tr -d "\012"
	read _STARTDATA
#_STARTDATA=2020-05-20

echo "�����������ֹ���ڣ������� 2020-04-05�� ->"|tr -d "\012"
	read _CLOSINGDATA
#_CLOSINGDATA=2022-04-05

echo ""
echo "�����뱾�δ�������� ��������500000�� ->"|tr -d "\012"
	read _ROWS
#_ROWS=500000

echo ""
echo "�����뱣�������أ� �������� �������人 ��420100�� ->"|tr -d "\012"
	read _CITYCODE
#_CITYCODE=420300



################�밴��������дsql####################
_NOFLAG=`db2 -x "select count(*) from iacmain_ncp where flag = ''"`
_NOFLAG1=`db2 -x "select count(*) from iacmain_ncp where flag = '' and citycode = '${_CITYCODE}'"`
echo "��ǰʡ��Ҫ����������� : ${_ROWS}"
echo "��ǰʡ�ܹ�δ����������ǣ� ${_NOFLAG}"

PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCP where citycode = '${_CITYCODE}' and flag = '' order by startDate fetch first ${_ROWS} rows only"`
echo "${PolicyConfirmNo}"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($PolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"
for B_PolicyConfirmNo in ${array[@]}
do

db2 "insert into IACMAIN_NCPB(POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, FRAMENO, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
	select 
			a.POLICYCONFIRMNO,
			a.POLICYNO,
			a.COMPANYCODE,
			a.CITYCODE,
			a.STARTDATE,
			a.ENDDATE,
			a.FRAMENO,
			a.LICENSENO,
			a.ENGINENO,
			(case
				when a.startDate < '${_STARTDATA}' and a.endDate < '${_CLOSINGDATA}'	then 1
				when a.startDate > '${_STARTDATA}' and a.startDate < '${_CLOSINGDATA}'	then 2
				when a.startDate < '${_STARTDATA}' and a.endDate > '${_CLOSINGDATA}'	then 3	
			 end	
			),
			'',
			'',
			'',
			CURRENT TIMESTAMP
		from IACMain_NCP a left join IACMain_NCP b on a.LastPoliConfirmNo = b.PolicyConfirmNo
		where
			a.startDate < '${_CLOSINGDATA}' and
			((((values days(date(b.endDate))- days(date(b.startDate))) <= 30 or b.BizStatus != '1') and b.Flag = '1' ) or 
			(a.LastPoliConfirmNo = ''or a.LastPoliConfirmNo is null)) and a.POLICYCONFIRMNO = '${B_PolicyConfirmNo}'"

done


#���ڵ�
ShortPolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPB where citycode = '${_CITYCODE}' and flag = '' and (
								values days(date(endDate))- days(date(startDate))) < 30"`
echo "${ShortPolicyConfirmNo}"								
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array1=($ShortPolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"
for Short_PolicyConfirmNo in ${array1[@]}
do
	db2 "update IACMain_NCPB  set  Reason = '1', Desc='���ڵ�', Flag = '0'  where PolicyConfirmNo = '${Short_PolicyConfirmNo}'"
	db2 "update IACMain_NCP set flag = '1' where PolicyConfirmNo = '${Short_PolicyConfirmNo}'"
done

 
#�˱�
EndorPolicyConfirmNo=`db2 -x  "select a.PolicyConfirmNo from IACMain_NCPB a, IACMain_NCP b where a.citycode = '${_CITYCODE}' and a.flag = '' and b.bizstatus != '1' 
								and a.PolicyConfirmNo = b.PolicyConfirmNo"`
echo "${EndorPolicyConfirmNo}"								
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array2=($EndorPolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"
for Endor_PolicyConfirmNo in ${array2[@]}
do
	EndorseConfirmNo=`db2 -x  "select EndorseConfirmNo from IAPHEAD where  PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"`
	EndorseDate=`db2 -x  "select EndDate from IACMain_NCP where  PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"`

	
	db2 "update IACMain_NCPB  set  Reason = '2', Desc='�˱�ȷ���룺${EndorseConfirmNo},�˱���Ч���ڣ�${EndorseDate}', Flag = '0'  where PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"
	db2 "update IACMain_NCP set flag = '1' where PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"
done





db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

