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



 db2 "  insert into IACMAIN_NCPB ( POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, FRAMENO, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
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
		'3',
		'',
		'',
		'0',
		sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys  , IACMain_NCP a
		left join IACMain_NCP b on a.POLICYCONFIRMNO = b.LastPoliConfirmNo
		where a.Flag = '0' and a.STARTDATE <  '2020-01-23' and 
		a.ENDDATE  > '2020-04-01' and ( b.ENDDATE >   '2020-04-01' or b.ENDDATE is null)

		
		"


db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

