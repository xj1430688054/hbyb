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


################�밴��������дsql####################

##���α�����Ͷ��ȷ����CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct CONFIRMSEQUENCENO from CACMain_NCPB"`







	
		i=$[i+1];
		###��ѯ�ڼ��������� ,��Ҫ�������ּ���ڼ���
		XuPolicyConfirmNo=`db2 -x  "	select 
										a.CONFIRMSEQUENCENO
									from CACMain_NCPX a 
										inner join CACMain_NCP b on a.CONFIRMSEQUENCENO = b.LastPolicyConfirmNo
										"`
	
	while true
	do
	echo "============================="
echo 	"$XuPolicyConfirmNo"
	if [  -z "$XuPolicyConfirmNo" ]
    then
		echo "1111111"
		break;
	else 
		echo "222222"
    fi
	
	echo "-------------------------------------"
	done
	








db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

