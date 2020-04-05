#!/usr/bin/env bash



main()
{
echo "开始时间"
date
#########################################################
#功能：更新数据
##########################################################

echo "请输入数据库名 ->"|tr -d "\012"
    read _DBNAME
#_DBNAME=iaci42db
	

	
echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
    read _DBUSER
#_DBUSER=instiaci

	
echo ""    	
echo "请输入数据库用户密码 ->"|tr -d "\012"
    read _PWD
#_PWD=password

	
echo ""    
echo "请输入schema名 ->"|tr -d "\012"
   read _SCHEMA
 #_SCHEMA=instiaci


db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
echo  "connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}"
db2 set schema=${_SCHEMA}

echo ""
echo "请输入路径(例：/home/instiaci/IACI/) ->"|tr -d "\012"
    read _DATAPATH
#   _DATAPATH=/home/instiaci/IACI/


echo ""
echo "请输入开始时间(例：2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME	
#_DATETIME="2020-03-23 12:00:00"

echo ""
echo "请输入密码配置文件路劲(例：/home/instiaci/xj/pass.txt) ->"|tr -d "\012"
    read _PASSPATH	
#_PASSPATH=/home/instiaci/xj/pass.txt
################以上部分不允许修改        ###############
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数

#当前时间
date1=$(date +"%Y%m%d%H%M%S")

#判断路径是否存在
 if [ ! -d ${_DATAPATH} ]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 


##本次保单的投保确认码
CompanyCode=`db2 -x  "select CompanyCode  from iadcompany "`
echo "${CompanyCode}"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($CompanyCode)
#变成原来的分隔符
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
	
	echo "没有续保保单"
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


#把密码存入map中

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

#######开始进行吧压缩包加密
cd ${_DATAPATH2}
filelist=$(ls)
for file in $filelist
do
	if [ -d $file ]
	then
	
	#echo ""    
	#echo "请输入${file}的密码 ->"|tr -d "\012"
    #read _PASS
	
	#echo "${file} 12346" >> ${_PASSPATH}
	
	zip -rP  ${map[${file}]}  ${file}.zip  ${file}
	fi
done




	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

