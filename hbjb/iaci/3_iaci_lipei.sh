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
###echo "�������ռ� ->"|tr -d "\012"
####	read _TBSDATA
###_TBSDATA=tbsdata
###
###echo ""
###echo "�����������ռ� ->"|tr -d "\012"
####	read _TBSINDEX
###_TBSINDEX=tbsindex

################�밴��������дsql####################


FILENAME=test
DATAPATH=/home/instiaci/xj/hb/

echo "�������ݵ���ʱ��..."    
echo "��"${FILENAME}".txt����ȡ��PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${FILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${FILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11) 
     MESSAGES  ${FILENAME}.log insert INTO IAClaimPolicy_NCP"



db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

