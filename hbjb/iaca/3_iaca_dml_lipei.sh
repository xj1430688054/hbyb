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
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
echo "�����뱣�չ�˾���������ļ����ƣ�txt ��ʽ ��: test.txt  ����test�� ->"|tr -d "\012"
	read FILENAME
	
echo "�����뱣�չ�˾���ӱ�������������(txt ��ʽ  ���� noyanbao)"
	read NOYANAO

echo "�����뱣�չ�˾׼���ĸ������ݵ�����·���� ���� /home/instiaci/xj/hb/iaci �� ->"|tr -d "\012"
	read DATAPATH



################�밴��������дsql####################
##��ǰ·��
#DATAPATH=$(cd $(dirname $0); pwd)

echo "�������ݵ���ʱ��..."    
echo "��"${FILENAME}".txt����ȡ��PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${FILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${FILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11) 
     MESSAGES  ${FILENAME}.log insert INTO CAClaimPolicy_NCP"

echo "�޸�����ʱ��Ϊ�յĸ���Ϊ��ǰʱ��"
db2 "update CAClaimPolicy_NCP set INPUTDATE = TO_CHAR(current timestamp,'YYYY-MM-DD HH24:MI:SS')  where INPUTDATE is null"
	 
	 
echo "�������ݵ���ʱ��..."    
echo "��"${NOYANAO}".txt����ȡ��PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${NOYANAO}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${NOYANAO}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9) 
     MESSAGES  ${NOYANAO}.log insert INTO CAPolicyNoPost_NCP"

echo "�޸�����ʱ��Ϊ�յĸ���Ϊ��ǰʱ��"	 
db2 "update CAPolicyNoPost_NCP set INPUTDATE = TO_CHAR(current timestamp,'YYYY-MM-DD HH24:MI:SS')  where INPUTDATE is null"
	 

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2_iaca_dml_lipei_${times}.log

