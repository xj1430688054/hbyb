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

##����������ڼ�ı����������ֱ������� ������

##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����
##########���� ���� ����

 db2 "  insert into CACMain_NCPB ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, VIN, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
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
		'3',
		'',
		'',
		'0',
		sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys  , CACMain_NCP a
		left join CACMain_NCP b on a.CONFIRMSEQUENCENO = b.LASTPOLICYCONFIRMNO
		where a.Flag = '0' and a.EFFECTIVEDATE <  '2020-01-23' and 
		a.EXPIREDATE  > '2020-04-01' and ( b.EXPIREDATE >   '2020-04-01' or b.EXPIREDATE is null)

		
		"


db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

