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
_DBNAME=iaci42db	
	
	
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
echo "�������ռ� ->"|tr -d "\012"
#	read _TBSDATA
_TBSDATA=tbsdata

echo ""
echo "�����������ռ� ->"|tr -d "\012"
#	read _TBSINDEX
_TBSINDEX=tbsindex

################�밴��������дsql####################

####���������ܴ󣬡���ִ��֮����ܴܺ�,  
######���赱ǰ�����Ķ�Ӧ�������ж�Ӧ����EndorseTypeΪ2��״��������ʱ�� �ᷢ��sql���������ظ�
echo "==============================================="
db2 "
insert into IACMain_NCP(POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, STOPTRAVELTYPE, STOPTRASTARTDATE, STOPTRAVELENDDATE, BIZSTATUS, LASTPOLICONFIRMNO, FRAMENO, LICENSENO, ENGINENO, FLAG, INPUTDATE, UPDATETIME)

 select 
		a.POLICYCONFIRMNO,
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
		'0',
		sys.extracttime, 
		sys.extracttime
	 from  (select current timestamp as extracttime from sysibm.sysdummy1) sys  , iacmain a
	 inner join IATCItemCar b on a.POLICYCONFIRMNO=b.POLICYCONFIRMNO
	 left join iaphead c on c.PolicyConfirmNo=a.POLICYCONFIRMNO and c.EndorseType = '2' 
	where a.ENDDATE >= '2020-01-23'   
	 
	 "


db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

