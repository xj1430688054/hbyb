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
echo "�������ʡ�����������ļ����ƣ���: xubao.txt  ����xubao�� ->"|tr -d "\012"
	read _XUBAOFILENAME
#_XUBAOFILENAME=xubao

echo ""
echo "�������ʡ�����������ļ����� (����lipei.txt  ����lipei)->"|tr -d "\012"
	read _CLAIMFILENAME
#_CLAIMFILENAME=lipei

################�밴��������дsql####################
##��ǰ·��
DATAPATH=$(cd $(dirname $0); pwd)


echo "��ձ�"
db2 "delete from KSCMain_NCP"
db2 "delete from KSClaim_NCP"


echo "�����ʡ�������ݵ���ʱ��..." 
date   
echo "��"${_XUBAOFILENAME}"����ȡ��PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${_XUBAOFILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${_XUBAOFILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18) 
     MESSAGES  ${_XUBAOFILENAME}.log insert INTO KSCMain_NCP"
echo "�����ʡ�������ݽ���"
date



echo "�����ʡ���������ݵ���ʱ��..."    
date
echo "��"${_XUBAOFILENAME}"����ȡ��PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${_CLAIMFILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${_CLAIMFILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11,12,13,14) 
     MESSAGES  ${_CLAIMFILENAME}.log insert INTO KSClaim_NCP"
echo "�����ʡ�������ݽ���"
date



db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

