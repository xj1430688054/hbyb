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



################�밴��������дsql####################

echo "ɾ����"
db2 "drop table  IACMain_NCP"
db2 "drop table  IACMain_NCPB"
db2 "drop table  IACMain_NCPX"
db2 "drop table  IACMain_NCPPostpone"
db2 "drop table  IAClaimPolicy_NCP"
db2 "drop table  KSCMain_NCP"
db2 "drop table  KSClaim_NCP"
db2 "drop table  IAPolicyNoPost_NCP"










db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

