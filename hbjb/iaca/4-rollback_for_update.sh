#!/usr/bin/env bash


main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ����˲���
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
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���

#db2 "drop table CACMain_B"
#db2 "drop table CACMain_X"
#db2 "drop table CAPostponeMain"
#db2 "drop table CACCoverage_B"
#db2 "drop table CACCoverage_X"

db2 "drop table CACMain_A"
db2 "drop table CACMain_B"
db2 "drop table CACMain_X"
db2 "drop table CAPostponeMain"
db2 "drop table CAPostponeCoverage"



#db2 "drop table CACCoverage_X"

db2 "drop index IDX_CACMain_A_01"
db2 "drop index IDX_CACMain_B_01"
db2 "drop index IDX_CACMain_X_01"
db2 "drop index IDX_CACMain_X_02"
db2 "drop index IDX_CAPostponeMain_01 "
db2 "drop index IDX_CAPostponeCoverage_01 "






################�밴��������дrollback �����sql####################


db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4-rollback_${times}.log

