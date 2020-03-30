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
echo "请输入路径(例：/home/instiaci/IACA/) ->"|tr -d "\012"
    read _DATAPATH	

echo ""
echo "请输入开始时间(例：2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME	

################以上部分不允许修改        ###############
_AREACODE=`db2 -x  "select PARAMETERVALUE from CADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数

#当前时间
date1=$(date +"%Y%m%d%H%M%S")

 if [ ! -d ${_DATAPATH}]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 



CompanyCode=`db2 -x  "select CODECODE from Cabizcode where CODETYPE ='CompanyCode'"`
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

	mkdir -p ${_DATAPATH}IACA_${company}_${date1}_01.txt
	
db2 "EXPORT TO ${_DATAPATH}IACA_${company}_${date1}_02.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH}IACA_${company}_${date1}_02.log\
			select a.LastPoliConfirmNo, a.ConfirmSequenceNo, a.PolicyNo, a.CityCode, a.EffectiveDate, a.ExpireDate
			from CACMain_NCPX a, CACMain_NCPPostpone b
			where b.LastPoliConfirmNo is not null and a.LastPoliConfirmNo = b.LastPoliConfirmNo and b.CompanyCode = '${company}' and b.UpdateTime >= ${_DATETIME}"

ConfirmSequenceNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPPostpone"`
echo "${ConfirmSequenceNo}"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($ConfirmSequenceNo)
#变成原来的分隔符
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
			#将险种追加的文件最后
			sed 's/$/&${Y_CoverageCode}/g' ${_DATAPATH}01.txt
			#将文件写入到指定文件
			sed '$a ${_DATAPATH}01.txt' ${_DATAPATH}IACA_${company}_${date1}_01.txt
			#删除临时文件
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
			#将险种追加的文件最后
			sed 's/$/&${Y_CoverageCode}/g' ${_DATAPATH}02.txt
			#将文件写入到指定文件
			
			sed '$a ${_DATAPATH}02.txt' ${_DATAPATH}IACA_${company}_${date1}_01.txt
			#删除临时文件
			rm -rf ${_DATAPATH}02.txt
			
		
		fi
		
	done
done

#删除临时文件
rm -rf ${_DATAPATH}company.txt





	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

