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

echo "ɾ����"
db2 "drop table  CACMain_NCP"
db2 "drop table  CACMain_NCPB"
db2 "drop table  CACMain_NCPX"
db2 "drop table  CACMain_NCPPostpone"
db2 "drop table  CACCoverage_NCPPostpone"
db2 "drop table  CAClaimPolicy_NCP"









db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

