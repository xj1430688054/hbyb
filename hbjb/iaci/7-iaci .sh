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
echo "请输入疫情开始日期 ->"|tr -d "\012"
    read _VirusStartDate	
echo ""
echo "请输入疫情结束日期 ->"|tr -d "\012"
    read _VirusEndDate		

################以上部分不允许修改        ###############
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数



#判断路径是否存在
 if [ ! -d ${_DATAPATH} ]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 
 
 ##本保单的投保确认码 加上标志 和地市
PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPB where flag = ''"`
echo "${PolicyConfirmNo}"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($PolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"
for B_PolicyConfirmNo in ${array[@]}
do
	##保险起期
	StartDate=`db2 -x  "select DATE(StartDate) from IACMain_NCPB where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "${StartDate}"
	##保险止期
	EndtDate=`db2 -x  "select DATE(EndtDate) from IACMain_NCPB where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	StartDate1=`date -d "${StartDate}" +%s`
	echo "${StartDate1}"
	EndDate1=`date -d "${EndDate}" +%s`
	echo "${EndDate1}"
	
	#业务状态
	BizStatus=`db2 -x  "select BizStatus from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "${BizStatus}"	
	
	echo "StopTravelEndDate:${StopTravelEndDate}"	
	#疫情开始时间
	t1=`date -d "${_VirusStartDate}" +%s`
	echo "t1:${t1}"	
	#疫情结束时间
	t2=`date -d "${_VirusEndDate}" +%s`
	echo "t2:${t2}"	
	
	#停驶类型1
	StopTravelType1=`db2 -x  "select StopTravelType from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	StopTravelType1=`echo ${StopTravelType1} | tr -d ' '`
	echo "StopTravelType1:${StopTravelType1}"	
	
	
	
	
	#本保单停驶
	if [ -n "${StopTravelType1}" ] 
	then 
		#停驶起期
		StopTraStartDate1=`db2 -x  "select DATE(StopTraStartDate) from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		echo "StopTraStartDate1:${StopTraStartDate1}"	
		#停驶止期	
		StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		#本保单的停驶起期
		StartDate1=`date -d "${StopTraStartDate1}" +%s`
		echo "StartDate1:${StartDate1}"
	
	
		if [ ${StartDate1} -gt ${t1} ] && [ ${t2} -gt ${StartDate1} ]
		then
			db2 "update IACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTraStartDate},停驶止期${StopTravelEndDate}', Flag = '0' where PolicyConfirmNo = 
			'${B_PolicyConfirmNo}'"
		fi
	else
		#保单停复驶表中的停复驶信息
		#停驶起期
		StopTravelStartDate2=`db2 -x  "select DATE(StopTravelStartDate) from IACStopRecover where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		echo "StopTravelStartDate2:${StopTravelStartDate2}"	
		#停驶止期	
		StopTravelEndDate2=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		#本保单的停驶起期
		StartDate2=`date -d "${StopTravelStartDate2}" +%s`
		echo "StartDate2:${StartDate2}"
		
		if [ ${StartDate2} -gt ${t1} ] && [ ${t2} -gt ${StartDate2} ]
		then
			db2 "update IACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTravelStartDate2},停驶止期${StopTravelEndDate2}', Flag = '0' where PolicyConfirmNo = 
			'${B_PolicyConfirmNo}'"
		fi
	fi
	
	
	
	#续保单停停驶
	PolicyConfirmNo1=`db2 -x  "select PolicyConfirmNo from IACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "PolicyConfirmNo1：${PolicyConfirmNo1}"
	#保存旧的分隔符
	OLD_IFS="$IFS"
	#分隔符设置成空格
	IFS=" "
	array1=($PolicyConfirmNo1)
	#变成原来的分隔符
	IFS="$OLD_IFS"
	for X_PolicyConfirmNo in ${array1[@]}
	do
		#续保单停驶类型
		X_StopTravelType=`db2 -x  "select StopTravelType from IACMain_NCP where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
		X_StopTravelType=`echo ${X_StopTravelType} | tr -d ' '`
		if [ -n "${X_StopTravelType}" ] 
		then
		
			#续保单停驶起期
			X_StopTraStartDate=`db2 -x  "select DATE(StopTraStartDate) from IACMain_NCP where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			#续保单停驶止期
			X_StopTravelEndDate=`db2 -x  "select DATE(StopTravelEndDate) from IACMain_NCP where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			StartDate3=`date -d "${X_StopTraStartDate}" +%s`
			if [ ${StartDate3} -gt ${t1} ] && [ ${t2} -gt ${StartDate3} ]
			then
				db2 "update IACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate}停驶止期${X_StopTravelEndDate}', Flag = '0'
				where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
			fi
		else
			#保单停复驶表中的停复驶信息
			#停驶起期
			X_StopTraStartDate1=`db2 -x  "select DATE(StopTravelStartDate) from IACStopRecover where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			echo "X_StopTraStartDate1:${X_StopTraStartDate1}"	
			#停驶止期	
			X_StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			#本保单的停驶起期
			StartDate4=`date -d "${X_StopTravelEndDate1}" +%s`
			echo "StartDate4:${StartDate4}"
		
			if [ ${StartDate4} -gt ${t1} ] && [ ${t2} -gt ${StartDate4} ]
			then
				db2 "update IACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate1},停驶止期${X_StopTravelEndDate1}', Flag = '0' where PolicyConfirmNo = 
				'${B_PolicyConfirmNo}'"
			fi
		fi
	done
	
	
	
	
	#本保单跨省续保
	#投保确认码
	CONFIRMSEQUENCENO_1==`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${B_PolicyConfirmNo}'"`
	echo "CONFIRMSEQUENCENO_1：${CONFIRMSEQUENCENO_1}"
	#保存旧的分隔符
	OLD_IFS="$IFS"
	#分隔符设置成空格
	IFS=" "
	array3=($CONFIRMSEQUENCENO_1)
	#变成原来的分隔符
	IFS="$OLD_IFS"
	for KSX_PolicyConfirmNo in ${array3[@]}
	do
		#续保地区
		KS_AreaCode=`db2 -x  "select AREACODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX_PolicyConfirmNo}'"`
		#续保公司
		KS_CompanyCode=`db2 -x  "select COMPANYCODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX_PolicyConfirmNo}'"`
		#续保的投保确认码
		KSX_PolicyConfirmNo=`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX_PolicyConfirmNo}'"`
	
		db2 "update IACMain_NCPB set Reason = '5', Desc='跨省续保:续保地区${KS_AreaCode}，续保公司${KS_CompanyCode}，投保确认码${KSX_PolicyConfirmNo}', Flag = '0'
		where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
	done
	
	#本保单续保单跨省续保
	PolicyConfirmNo2=`db2 -x  "select PolicyConfirmNo from IACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "PolicyConfirmNo2：${PolicyConfirmNo2}"
	#保存旧的分隔符
	OLD_IFS="$IFS"
	#分隔符设置成空格
	IFS=" "
	array4=($PolicyConfirmNo2)
	#变成原来的分隔符
	IFS="$OLD_IFS"
	for KSX1_PolicyConfirmNo in ${array4[@]}
	do
		CONFIRMSEQUENCENO_2==`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${B_PolicyConfirmNo}'"`
		#保存旧的分隔符
		OLD_IFS="$IFS"
		#分隔符设置成空格
		IFS=" "
		array5=($CONFIRMSEQUENCENO_2)
		#变成原来的分隔符
		IFS="$OLD_IFS"
		for KSX2_PolicyConfirmNo in ${array5[@]}
		do
			#续保地区
			KS_AreaCode=`db2 -x  "select AREACODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX2_PolicyConfirmNo}'"`
			#续保公司
			KS_CompanyCode=`db2 -x  "select COMPANYCODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX2_PolicyConfirmNo}'"`
			#续保的投保确认码
			KSX_PolicyConfirmNo=`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX2_PolicyConfirmNo}'"`
	
			db2 "update IACMain_NCPB set Reason = '5', Desc='跨省续保:续保地区${KS_AreaCode}，续保公司${KS_CompanyCode}，投保确认码${KSX_PolicyConfirmNo}', Flag = '0'
			where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
		done	
	done
	
	
	
	
	#最后一张续保单的投保确认码
	LastX_PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}' order by EndDate desc fetch first 1 rows only"`
	echo "${LastX_PolicyConfirmNo}"
	#最后一张续保单的业务类型
	LastX_BizStatus=`db2 -x  "select BizStatus from IACMain_NCP where PolicyConfirmNo = '${LastX_PolicyConfirmNo}'"`
	echo "${LastX_BizStatus}"
	
	if [ "${LastX_BizStatus}" != "1" ]
	then
	
		EndorseConfirmNo=`db2 -x  "select EndorseConfirmNo from IAPHEAD where  PolicyConfirmNo = '${LastX_PolicyConfirmNo}'"`
		EndorseDate=`db2 -x  "select DATE(EndDate) from IACMain_NCP where  PolicyConfirmNo = '${LastX_PolicyConfirmNo}'"`
		
		db2 "update IACMain_NCPB set Reason = '6', Desc='退保：投保确认码${EndorseConfirmNo},退保生效日期${EndorseDate}', Flag = '0'
		where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
	fi






	#本省和跨省理赔
	#Vin码
	Vin=`db2 -x  "select vin from IACMain_NCP where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	
	#投保确认码
	CONFIRMSEQUENCENO==`db2 -x  "select CONFIRMSEQUENCENO from KSClaim_NCP where vin = '${Vin}'"`
	echo "CONFIRMSEQUENCENO：${CONFIRMSEQUENCENO}"
	#保存旧的分隔符
	OLD_IFS="$IFS"
	#分隔符设置成空格
	IFS=" "
	array2=($CONFIRMSEQUENCENO)
	#变成原来的分隔符
	IFS="$OLD_IFS"
	for KSL_PolicyConfirmNo in ${array2[@]}
	do
		#理赔地区
		KSL_AreaCode=`db2 -x  "select AREACODE from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		#理赔公司
		KSL_CompanyCode=`db2 -x  "select COMPANYCODE from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		#理赔编码
		KSL_ClaimQueryNo=`db2 -x  "select CLAIMSEQUENCENO from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		#出险时间
		KSL_DamageDate=`db2 -x  "select DATE(LOSSTIME) from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		
		t3=`date -d "${KSL_DamageDate}" +%s`
		
		if [ ${t3} -gt  ${t1} ] && [ ${t2} -gt ${t3} ]
		then
			db2 "update IACMain_NCPB set Reason = '4', Desc='理赔:理赔地区${KSL_AreaCode},理赔公司${KSL_CompanyCode},理赔编码${KSL_ClaimQueryNo},出险时间${KSL_DamageDate}',
			Flag = '0' where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
		fi
	
	done
	

	
done 
 
 
 
 
 
 
 
 
 
 
 
 







	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

