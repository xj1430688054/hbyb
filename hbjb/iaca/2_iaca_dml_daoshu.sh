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
#_DBNAME=iaca42db	
	
	
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
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ�������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############

echo "�����������ֹ���ڣ������� 2020-01-23�� ->"|tr -d "\012"
	read _STARTDATA
	
	
	
_INPUTTIME=`db2 -x "select to_char(current timestamp,'yyyy-mm-dd hh24:mi:ss') from sysibm.dual"`
#_STARTDATA=2020-01-23

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
		'',
		'${_INPUTTIME}',  
		null
	 from   cacmain a
	 inner join CACVehicle b on a.CONFIRMSEQUENCENO=b.CONFIRMSEQUENCENO
	where a.EXPIREDATE > '${_STARTDATA}'
	
		and a.ValidStatus = '1'
	 
	 "


db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2_iaca_dml_daoshu_${times}.log
