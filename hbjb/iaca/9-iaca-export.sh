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
echo "������·��(����/home/instiaci/IACA/) ->"|tr -d "\012"
    read _DATAPATH	

echo ""
echo "�����뿪ʼʱ��(����2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME	

################���ϲ��ֲ������޸�        ###############
_AREACODE=`db2 -x  "select PARAMETERVALUE from CADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���

#��ǰʱ��
date1=$(date +"%Y%m%d%H%M%S")

 if [ ! -d ${_DATAPATH}]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 



CompanyCode=`db2 -x  "select CODECODE from Cabizcode where CODETYPE ='CompanyCode'"`
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

	mkdir -p ${_DATAPATH}IACA_${company}_${date1}_01.txt
	
db2 "EXPORT TO ${_DATAPATH}IACA_${company}_${date1}_02.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACA_${company}_${date1}_02.log\
			select a.LastPoliConfirmNo, a.ConfirmSequenceNo, a.PolicyNo, a.CityCode, a.EffectiveDate, a.ExpireDate
			from CACMain_NCPX a, CACMain_NCPPostpone b
			where b.LastPoliConfirmNo is not null and a.LastPoliConfirmNo = b.LastPoliConfirmNo and b.CompanyCode = '${company}' and b.UpdateTime >= ${_DATETIME}"

ConfirmSequenceNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPPostpone"`
echo "${ConfirmSequenceNo}"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($ConfirmSequenceNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"

	for X_ConfirmSequenceNo in ${array[@]}
	do
		LastPoliConfirmNo=`db2 -x  "select LastPoliConfirmNo from CACMain_NCPPostpone where ConfirmSequenceNo= '${X_ConfirmSequenceNo}'"`
		LastPoliConfirmNo=`echo ${LastPoliConfirmNo} | tr -d ' '`
		UpdateTime = `db2 -x  "select UpdateTime from CACMain_NCPPostpone where ConfirmSequenceNo= '${X_ConfirmSequenceNo}'"`
		
		t1=`date -d "${UpdateTime}" +%s`
		t2=`date -d "${_DATETIME}" +%s`
		
		if[ -n ${LastPoliConfirmNo} ] && [ ${t1} -gt ${t2} ]
		then
			db2"EXPORT TO ${_DATAPATH}01.txt of DEL modified by codepage=1208 COLDEL|
			select ConfirmSequenceNo, PolicyNo, CityCode, EffectiveDate, ExpireDate, LicenseNo Vin, EngineNo, PolicyNo, AfterExpireDate, NCPValidDate, PostponeDay, NCPStartDate, NCPEndDate
			from CACMain_NCPPostpone
			where ConfirmSequenceNo = '${X_ConfirmSequenceNo}' and CompanyCode = '${company}'"
			
			CoverageCode=`db2 -x  "select CoverageCode from CACCoverage_NCPPostpone where ConfirmSequenceNo= '${X_ConfirmSequenceNo}'"`
			X_CoverageCode = ${CoverageCode}|sed 's/[ ][ ]*/,/g'
			Y_CoverageCode = "|"${X_CoverageCode}
			#������׷�ӵ��ļ����
			sed 's/$/&${Y_CoverageCode}/g' ${_DATAPATH}01.txt
			#���ļ�д�뵽ָ���ļ�
			sed '$a ${_DATAPATH}01.txt' ${_DATAPATH}IACA_${company}_${date1}_01.txt
			#ɾ����ʱ�ļ�
			rm -rf ${_DATAPATH}01.txt
			
		
		fi
		if[ !-n ${LastPoliConfirmNo} ] && [ ${t1} -gt ${t2} ]
		then
			db2"EXPORT TO ${_DATAPATH}02.txt of DEL modified by codepage=1208 COLDEL|
			select b.ConfirmSequenceNo, b.PolicyNo, b.CityCode, b.EffectiveDate, b.ExpireDate, b.LicenseNo b.Vin, b.EngineNo, a.PolicyNo,a.AfterExpireDate, a.NCPValidDate, a.PostponeDay, a.NCPStartDate, a.NCPEndDate
			from CACMain_NCPPostpone a,CACMain_NCPB b
			where b.ConfirmSequenceNo = a.LastPoliConfirmNo and a.CompanyCode = '${company}' and a.ConfirmSequenceNo = '${X_ConfirmSequenceNo}'"
			
			CoverageCode=`db2 -x  "select CoverageCode from CACCoverage_NCPPostpone where ConfirmSequenceNo= '${X_ConfirmSequenceNo}'"`
			X_CoverageCode = ${CoverageCode}|sed 's/[ ][ ]*/,/g'
			Y_CoverageCode = "|"${X_CoverageCode}
			#������׷�ӵ��ļ����
			sed 's/$/&${Y_CoverageCode}/g' ${_DATAPATH}02.txt
			#���ļ�д�뵽ָ���ļ�
			
			sed '$a ${_DATAPATH}02.txt' ${_DATAPATH}IACA_${company}_${date1}_01.txt
			#ɾ����ʱ�ļ�
			rm -rf ${_DATAPATH}02.txt
			
		
		fi
		
	done
done

#ɾ����ʱ�ļ�
rm -rf ${_DATAPATH}company.txt





	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

