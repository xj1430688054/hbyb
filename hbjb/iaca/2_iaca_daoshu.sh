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
echo "�������ռ� ->"|tr -d "\012"
#	read _TBSDATA
_TBSDATA=tbsdata

echo ""
echo "�����������ռ� ->"|tr -d "\012"
#	read _TBSINDEX
_TBSINDEX=tbsindex

################�밴��������дsql####################

####���������ܴ󣬡���ִ��֮����ܴܺ�
echo "==============================================="
db2 "insert into CACMain_NCP(CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, STOPTRAVELTYPE, STOPTRASTRATDATE, STOPTRAVELENDDATE, BIZSTATUS, LASTPOLICYCONFIRMNO, VIN, LICENSENO, ENGINENO, FLAG, INPUTDATE, UPDATETIME)
     select 
		a.CONFIRMSEQUENCENO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.EFFECTIVEDATE,
		a.EXPIREDATE,
		a.STOPTRAVELTYPE,
		a.STOPTRASTRATDATE,
		a.STOPTRAVELENDDATE,
		a.BIZSTATUS,
		a.LASTPOLICYCONFIRMNO,
		b.VIN,
		b.LICENSENO,
		b.ENGINENO,
		'0',
		sys.extracttime, 
		sys.extracttime
	 from  (select current timestamp as extracttime from sysibm.sysdummy1) sys  , cacmain a
	 inner join CACVehicle b on a.CONFIRMSEQUENCENO=b.CONFIRMSEQUENCENO
	where a.EXPIREDATE >= '2020-01-23' 
	 
	 "


db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

