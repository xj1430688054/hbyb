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
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
    read _DBUSER
	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
    read _PWD
	
echo ""    
echo "������schema�� ->"|tr -d "\012"
    read _SCHEMA

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

echo ""
echo "������·��(����/home/instiaci/IACI/) ->"|tr -d "\012"
    read _DATAPATH	

echo ""
echo "�����뿪ʼʱ��(����2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME		

################���ϲ��ֲ������޸�        ###############
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���

#��ǰʱ��
date1=$(date +"%Y%m%d%H%M%S")

#�ж�·���Ƿ����
 if [ ! -d ${_DATAPATH}]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 


##���α�����Ͷ��ȷ����
CompanyCode=`db2 -x  "select CODECODE from Iabizcode where CODETYPE ='CompanyCode'"`
echo "${CompanyCode}"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($CompanyCode)
#���ԭ���ķָ���
IFS="$OLD_IFS"

for company in ${array[@]}
do




echo "û����������"
db2 "EXPORT TO ${_DATAPATH}IACI_${company}${date1}_01.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACI_${company}${date1}_01.log\
			select PolicyConfirmNo, PolicyNo, CityCode, StartDate, EndDate, LicenseNo FrameNo, EngineNo, PolicyNo, AfterEndDate, NCPValidDate, PostponeDay, NCPStartDate, NCPEndDate  
			from IACMain_NCPPostpone
			where LastPoliConfirmNo is null and CompanyCode = '${company}' and UpdateTime >= ${_DATETIME}"



echo "����������"
db2 "EXPORT TO ${_DATAPATH}IACI_${company}${date1}_01_01.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACI_${company}${date1}_01_01.log\
			select b.PolicyConfirmNo, b.PolicyNo, b.CityCode, b.StartDate, b.EndDate, b.LicenseNo b.FrameNo, b.EngineNo, a.PolicyNo, a.AfterEndDate, a.NCPValidDate, a.PostponeDay, a.NCPStartDate, a.NCPEndDate
			from IACMain_NCPPostpone a,IACMain_NCPB b
			where a.LastPoliConfirmNo is not null and b.PolicyConfirmNo = a.LastPoliConfirmNo and a.CompanyCode = '${company}' and a.UpdateTime >= ${_DATETIME}"

#����������1�ļ�д�뵽û�����ĵ�1�ļ�
sed '$a ${_DATAPATH}IACI_${company}${date1}_01_01.txt' ${_DATAPATH}IACI_${company}${date1}_01.txt
#ɾ����������1�ļ�
rm -rf ${_DATAPATH}IACI_${company}${date1}_01_01.txt

		
db2 "EXPORT TO${_DATAPATH}IACI_${company}${date1}_02.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACI_${company}${date1}_02.log\
			select a.LastPoliConfirmNo, a.PolicyConfirmNo, a.PolicyNo, a.CityCode, a.StartDate, a.EndDate
			from IACMain_NCPX a, IACMain_NCPPostpone b
			where b.LastPoliConfirmNo is not null and a.LastPoliConfirmNo = b.LastPoliConfirmNo and b.CompanyCode = '${company}' and b.UpdateTime >= ${_DATETIME}"

done









	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

