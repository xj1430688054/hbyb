#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ���������
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
_AREACODE=`db2 -x  "select PARAMETERVALUE from IADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
_CLOSINGDAT=`db2 -x "select parametervalue from iadsysconfig where PARAMETERCODE = 'ClosingDate'"`
_CLOSINGDAT=`echo ${_CLOSINGDAT} | tr -d ' '`


echo ""
echo "�������ϴ�����ʱ�� ->"| tr -d "\012"
#	read _LASTDATE
_LASTDATE='2020-02-02'


#���³б�������
db2 "merge into IACMAIN a 
		using  (select POLICYCONFIRMNO,EndDate  from IACMain_NCPPostpone where IACMain_NCPPostpone.Flag != '1') b 
		on a.POLICYCONFIRMNO = b.POLICYCONFIRMNO 
		when matched 
			then update set  a.ENDDATE= b.EndDate ,a.UnderwriteReason  = '3'
			else ignore
"

			

#���»������ݱ�����������״̬
#��ȡ��������Ͷ��ȷ����	
X_PolicyConfirmNo=`db2 -x  "select c1.POLICYCONFIRMNO from IACMain_NCP c1, IACMain_NCPX c2 where c1.POLICYCONFIRMNO = c2.LastPoliConfirmNo"`
echo "${X_PolicyConfirmNo}"
echo "Ͷ��ȷ����"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($X_PolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"
#���»������ݱ��б�������Ϣ
for NCPX_PolicyConfirmNo in ${array[@]}
do
db2 "update IACMain_NCP set  Flag = '1' where POLICYCONFIRMNO = '${X_PolicyConfirmNo}'"
 
done	

#��ȡ��������Ͷ��ȷ����
PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPPostpone 
	where LastPoliConfirmNo = '' and Flag != '1' 
	union 
	select LastPoliConfirmNo as  PolicyConfirmNo from IACMain_NCPPostpone 
	where LastPoliConfirmNo != '' and Flag != '1'"`


echo "Ͷ��ȷ����"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($PolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"
#���»������ݱ��б�������Ϣ
for NCP_PolicyConfirmNo in ${array[@]}
do
db2 "update IACMain_NCP set  Flag = '1' where   PolicyConfirmNo = '${NCP_PolicyConfirmNo}'"
##���±�������Ϣ
db2 "update IACMain_NCPB set Flag = '1' where   PolicyConfirmNo = '${NCP_PolicyConfirmNo}'"
#����˳�ӱ���������
db2 "update IACMain_NCPPostpone set  Flag = '1' where   PolicyConfirmNo = '${NCP_PolicyConfirmNo}'"
done	



################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

