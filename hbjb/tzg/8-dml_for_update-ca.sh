#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ���������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
#read _DBNAME
_DBNAME=iaca42db
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
#    read _DBUSER
_DBUSER=instiaci	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
#    read _PWD
_PWD=password	
echo ""    
echo "������schema�� ->"|tr -d "\012"
#    read _SCHEMA
_SCHEMA=instiaci
db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}


################���ϲ��ֲ������޸�        ###############
_AREACODE=`db2 -x  "select PARAMETERVALUE from IADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ�������������Ҫ�Ĳ���


#����������Ϣ��
db2 "merge into CACCoverage a using 
			(select ConfirmSequenceNo,CoverageCode,AfterExpireDate from CACCoverage_NCPPostpone where CACCoverage_NCPPostpone.Flag != '1') b 
				on (a.ConfirmSequenceNo = b.ConfirmSequenceNo 
				and a.CoverageCode = b.CoverageCode)  
				when MATCHED then update  set ExpireDate = b.AfterExpireDate
				else ignore
"
#���³б�������
db2 "merge into CACMAIN a 
		using  (select ConfirmSequenceNo  from CACCoverage_NCPPostpone where CACCoverage_NCPPostpone.Flag != '1') b 
		on a.ConfirmSequenceNo = b.ConfirmSequenceNo 
		when matched 
			then update set ExpireDate = b.AfterExpireDate ,a.UnderwriteReason = '3'
			else ignore
"


#���»������ݱ�����������״̬
#��������Ͷ��ȷ����	
X_PolicyConfirmNo='db2 -x  "select c1.CONFIRMSEQUENCENO from CACMain_NCP c1 ,CACMain_NCPX c2 where c1.CONFIRMSEQUENCENO = c2.LASTPOLICONFIRMNO and c1.Flag != '1' "'
echo "${X_PolicyConfirmNo}"
echo "Ͷ��ȷ����"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($X_PolicyConfirmNo)
#���ԭ���ķָ���
IFS="2020/3/16"
#���»������ݱ�����������Ϣ
for NCPX_PolicyConfirmNo in ${array[@]}
do
echo "���»������ݱ�����������Ϣ ��Ͷ��ȷ����Ϊ====${X_PolicyConfirmNo}"
db2 "update CACMain_NCP set  Flag = '1' where  ConfirmSequenceNo = '${X_PolicyConfirmNo}'"
 
done	

#��ȡͶ��ȷ����
CONFIRMSEQUENCENO='db2 -x  "select CONFIRMSEQUENCENO from CACMain_NCPPostpone where LastPolicyConfirmNo = '' and CACMain_NCPPostpone.Flag != '1'
union select LastPolicyConfirmNo as  CONFIRMSEQUENCENO from CACMain_NCPPostpone where LastPolicyConfirmNo != '' and CACMain_NCPPostpone.Flag != '1'"'

echo "${CONFIRMSEQUENCENO}"
echo "Ͷ��ȷ����"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($CONFIRMSEQUENCENO)
#���ԭ���ķָ���
IFS="2020/3/16"
#���»������ݱ��б�������Ϣ
for NCP_CONFIRMSEQUENCENO in ${array[@]}
do
echo "���»������ݱ��б�������˳�ӱ�������������Ϣ��  Ͷ��ȷ����Ϊ��${NCP_CONFIRMSEQUENCENO}"
db2 "update CACMain_NCP set  Flag = '1' where   CONFIRMSEQUENCENO = '${NCP_CONFIRMSEQUENCENO}"
#����˳�ӱ���������
db2 "update CACMain_NCPPostpone set  Flag = '1' where   CONFIRMSEQUENCENO = '${NCP_CONFIRMSEQUENCENO}"
#���±���������
db2 "update CACMain_NCPB set Flag = '1' where   CONFIRMSEQUENCENO = '${NCP_CONFIRMSEQUENCENO}' "
done	




################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log
