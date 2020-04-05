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
echo  "connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}"
db2 set schema=${_SCHEMA}

echo ""
echo "������·��(����/home/instiaci/IACI/) ->"|tr -d "\012"
    read _DATAPATH
#   _DATAPATH=/home/instiaci/IACI/


echo ""
echo "�����뿪ʼʱ��(����2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME	
#_DATETIME="2020-03-23 12:00:00"

echo ""
echo "���������������ļ�·��(����/home/instiaci/xj/pass.txt) ->"|tr -d "\012"
    read _PASSPATH	
#_PASSPATH=/home/instiaci/xj/pass.txt
################���ϲ��ֲ������޸�        ###############
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���

#��ǰʱ��
date1=$(date +"%Y%m%d%H%M%S")

#�ж�·���Ƿ����
 if [ ! -d ${_DATAPATH} ]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 


##���α�����Ͷ��ȷ����
CompanyCode=`db2 -x  "select CompanyCode  from iadcompany "`
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
	
	_DATAPATH1=${_DATAPATH}"Data/"${date1}"/"${company}"/"
	_DATAPATH2=${_DATAPATH}"Data/"${date1}"/"
	echo "${_DATAPATH1}"
	
	if [ ! -d ${_DATAPATH1} ]; 
	then 
		mkdir -p ${_DATAPATH1} 
	fi 
	
	echo "û����������"
	db2 "EXPORT TO ${_DATAPATH1}IACI_${company}${date1}_01.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH1}IACI_${company}${date1}_01.log\
				select PolicyConfirmNo, PolicyNo, CityCode, to_char(TIMESTAMP(StartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(EndDate),'YYYY-MM-DD HH24:MI:SS'), LicenseNo,FrameNo, EngineNo, PolicyNo, to_char(TIMESTAMP(AfterEndDate),'YYYY-MM-DD HH24:MI:SS'), NCPValidDate,PostponeDay, to_char(TIMESTAMP(NCPStartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(NCPEndDate),'YYYY-MM-DD HH24:MI:SS') 
				from IACMain_NCPPostpone
				where (LastPoliConfirmNo is null or LastPoliConfirmNo='') and CompanyCode = '${company}' and UpdateTime > '${_DATETIME}'
				union
				select b.PolicyConfirmNo, b.PolicyNo, b.CityCode, to_char(TIMESTAMP(b.StartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(b.EndDate),'YYYY-MM-DD HH24:MI:SS'), b.LicenseNo,b.FrameNo, b.EngineNo, a.PolicyNo, to_char(TIMESTAMP(a.AfterEndDate),'YYYY-MM-DD HH24:MI:SS'), a.NCPValidDate, a.PostponeDay, to_char(TIMESTAMP(a.NCPStartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(a.NCPEndDate),'YYYY-MM-DD HH24:MI:SS')
				from IACMain_NCPPostpone a,IACMain_NCPB b
				where a.LastPoliConfirmNo is not null and b.PolicyConfirmNo = a.LastPoliConfirmNo and a.CompanyCode = '${company}' and a.UpdateTime >'${_DATETIME}'"

			
	db2 "EXPORT TO ${_DATAPATH1}IACI_${company}${date1}_02.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH1}IACI_${company}${date1}_02.log\
				select a.LastPoliConfirmNo, a.PolicyConfirmNo, a.PolicyNo, a.CityCode, to_char(TIMESTAMP(a.StartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(a.EndDate),'YYYY-MM-DD HH24:MI:SS')
				from IACMain_NCPX a, IACMain_NCPPostpone b
				where b.LastPoliConfirmNo is not null and a.LastPoliConfirmNo = b.LastPoliConfirmNo and b.CompanyCode = '${company}' and b.UpdateTime > '${_DATETIME}'"

done


#���������map��

declare -A map=();

 while read line
do	

	 key=`echo ${line} | cut -d " " -f1`
    value=`echo ${line} | cut -d " " -f2`
	if [  -z "$key" ]
    then
		echo ""
	else
		if [  -z "$value" ]
		then
			echo ""
		else
			#echo "${key}:${value}"
			map["${key}"]="${value}"
			#echo ${map[@]}
			#echo ${!map[@]}
		fi
    fi

done < ${_PASSPATH}

	#echo "map"
	#echo ${map[@]}
	#echo ${!map[@]}

#######��ʼ���а�ѹ��������
cd ${_DATAPATH2}
filelist=$(ls)
for file in $filelist
do
	if [ -d $file ]
	then
	
	#echo ""    
	#echo "������${file}������ ->"|tr -d "\012"
    #read _PASS
	
	#echo "${file} 12346" >> ${_PASSPATH}
	
	zip -rP  ${map[${file}]}  ${file}.zip  ${file}
	fi
done




	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

