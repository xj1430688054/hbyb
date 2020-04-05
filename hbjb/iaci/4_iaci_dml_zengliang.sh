#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ���������
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
####ȡ��������������������ʱ��
_LASTDATE=`db2 -x "select a.INPUTDATE  from iacmain_ncp a  order by a.INPUTDATE desc    fetch first 1 row only"`



################�밴��������дsql####################

echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------��ȡͶ��ȷ�������ϴ���������º��-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

db2 "insert into IACMain_NCP(POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, STOPTRAVELTYPE, STOPTRASTARTDATE, STOPTRAVELENDDATE, BIZSTATUS, LASTPOLICONFIRMNO, FRAMENO, LICENSENO, ENGINENO, FLAG, INPUTDATE, UPDATETIME)
	 select 
		a.POLICYCONFIRMNO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.STARTDATE,
		(case 
						when d.PolicyConfirmNo is not null   then d.ValidDate 
						when d.PolicyConfirmNo is  null then a.enddate 
		end ) enddate,
		a.STOPTRAVELTYPE,
		a.STOPTRASTARTDATE,
		a.STOPTRAVELENDDATE,
		a.BIZSTATUS,
		a.LASTPOLICONFIRMNO,
		b.FRAMENO,
		b.LICENSENO,
		b.ENGINENO,
		(case 
			when c.PolicyConfirmNo is not null   then '1'
			when c.PolicyConfirmNo is  null then '' 
		end ) flag,
		current timestamp , 
		null 
	 from    iacmain a
	 inner join IATCItemCar b on a.POLICYCONFIRMNO=b.POLICYCONFIRMNO  
								and a.ValidStatus ='1'
								and a.InputDate >= '${_LASTDATE}'
	  left join iacmain_ncp c on a.LASTPOLICONFIRMNO = c.POLICYCONFIRMNO
							and c.flag = '1'
	 left join iaphead d on d.PolicyConfirmNo=a.POLICYCONFIRMNO 
							and d.EndorseType = '2' 

								
"

echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------��ȡ����ȷ����ʱ�����ϴκ�Ĳ�����-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

PPOLICYCONFIRMNOS=`db2 -x "select distinct POLICYCONFIRMNO  from IAPHead where confirmdate >= '${_LASTDATE}' "`

echo "${PPOLICYCONFIRMNOS}"
##����ɵķָ���
OLD_IFS="$IFS"
##�ָ������óɿո�
IFS=" "
array=($PPOLICYCONFIRMNOS)
##���ԭ���ķָ���
IFS="$OLD_IFS"


###��������������ѯ�鱨��
for P_PolicyConfirmNo in ${array[@]}
do	
#	#�ж����������Ƿ�����
#	flag=`db2 -x "select 
#					a.flag 
#				  from iacmain_ncp a
#				  where a.POLICYCONFIRMNO = '${P_PolicyConfirmNo}' "`
#				  
#	if [  -z "$P_PolicyConfirmNo" ]
#   then
	
		####û�д����
		echo "���»������ݱ�"
		db2 "update iacmain_ncp  d 
				set  
					(
						d.POLICYNO, 
						d.COMPANYCODE, 
						d.CITYCODE, 
						d.STARTDATE, 
						d.ENDDATE, 
						d.STOPTRAVELTYPE, 
						d.STOPTRASTARTDATE, 
						d.STOPTRAVELENDDATE, 
						d.BIZSTATUS, 
						d.LASTPOLICONFIRMNO, 
						d.FRAMENO, 
						d.LICENSENO, 
						d.ENGINENO, 
						d.UPDATETIME 
					)
					= 
				(select 
					a.POLICYNO,
					a.COMPANYCODE,
					a.CITYCODE,
					a.STARTDATE,
					(case 
						when c.PolicyConfirmNo is not null   then c.ValidDate 
						when c.PolicyConfirmNo is  null then a.enddate 
					end ) enddate,
					a.STOPTRAVELTYPE,
					a.STOPTRASTARTDATE,
					a.STOPTRAVELENDDATE,
					a.BIZSTATUS,
					a.LASTPOLICONFIRMNO,
					b.FRAMENO,
					b.LICENSENO,
					b.ENGINENO,
					current timestamp 
				from   iacmain a
				inner join IATCItemCar b on a.POLICYCONFIRMNO = b.POLICYCONFIRMNO 
										and a.POLICYCONFIRMNO = '${P_PolicyConfirmNo}'
				inner join iacmain_ncp e on a.POLICYCONFIRMNO = e.POLICYCONFIRMNO 
										and e.flag = ''
				left join iaphead c on c.PolicyConfirmNo=a.POLICYCONFIRMNO and c.EndorseType = '2'
				where a.POLICYCONFIRMNO = d.POLICYCONFIRMNO 
				
				)
					where d.POLICYCONFIRMNO = '${P_PolicyConfirmNo}' 
							and d.flag = ''
				"
		
#	else
		####�����
	#	echo "${P_PolicyConfirmNo} �������Ѿ��������� ���β�������"
		
  #  fi
				 
done



db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4_iaci_dml_zengliang_${times}.log

