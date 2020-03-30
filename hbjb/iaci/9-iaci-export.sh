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
	
echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
    read _DBUSER
	
echo ""    	
echo "请输入数据库用户密码 ->"|tr -d "\012"
    read _PWD
	
echo ""    
echo "请输入schema名 ->"|tr -d "\012"
    read _SCHEMA

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

echo ""
echo "请输入路径(例：/home/instiaci/IACI/) ->"|tr -d "\012"
    read _DATAPATH	

echo ""
echo "请输入开始时间(例：2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME		

################以上部分不允许修改        ###############
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数

#当前时间
date1=$(date +"%Y%m%d%H%M%S")

#判断路径是否存在
 if [ ! -d ${_DATAPATH}]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 


##本次保单的投保确认码
CompanyCode=`db2 -x  "select CODECODE from Iabizcode where CODETYPE ='CompanyCode'"`
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




echo "没有续保保单"
db2 "EXPORT TO ${_DATAPATH}IACI_${company}${date1}_01.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACI_${company}${date1}_01.log\
			select PolicyConfirmNo, PolicyNo, CityCode, StartDate, EndDate, LicenseNo FrameNo, EngineNo, PolicyNo, AfterEndDate, NCPValidDate, PostponeDay, NCPStartDate, NCPEndDate  
			from IACMain_NCPPostpone
			where LastPoliConfirmNo is null and CompanyCode = '${company}' and UpdateTime >= ${_DATETIME}"



echo "有续保保单"
db2 "EXPORT TO ${_DATAPATH}IACI_${company}${date1}_01_01.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACI_${company}${date1}_01_01.log\
			select b.PolicyConfirmNo, b.PolicyNo, b.CityCode, b.StartDate, b.EndDate, b.LicenseNo b.FrameNo, b.EngineNo, a.PolicyNo, a.AfterEndDate, a.NCPValidDate, a.PostponeDay, a.NCPStartDate, a.NCPEndDate
			from IACMain_NCPPostpone a,IACMain_NCPB b
			where a.LastPoliConfirmNo is not null and b.PolicyConfirmNo = a.LastPoliConfirmNo and a.CompanyCode = '${company}' and a.UpdateTime >= ${_DATETIME}"

#将有续保的1文件写入到没续保的的1文件
sed '$a ${_DATAPATH}IACI_${company}${date1}_01_01.txt' ${_DATAPATH}IACI_${company}${date1}_01.txt
#删除有续保的1文件
rm -rf ${_DATAPATH}IACI_${company}${date1}_01_01.txt

		
db2 "EXPORT TO${_DATAPATH}IACI_${company}${date1}_02.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACI_${company}${date1}_02.log\
			select a.LastPoliConfirmNo, a.PolicyConfirmNo, a.PolicyNo, a.CityCode, a.StartDate, a.EndDate
			from IACMain_NCPX a, IACMain_NCPPostpone b
			where b.LastPoliConfirmNo is not null and a.LastPoliConfirmNo = b.LastPoliConfirmNo and b.CompanyCode = '${company}' and b.UpdateTime >= ${_DATETIME}"

done









	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

