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
echo "请输入地市 ->"|tr -d "\012"
    read _CityCode

	
	
echo ""
echo "请输入疫情开始日期 ->"|tr -d "\012"
    read _VirusStartDate	
echo ""
echo "请输入疫情结束日期 ->"|tr -d "\012"
    read _VirusEndDate		

################以上部分不允许修改        ###############
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数




 
 ##本保单的投保确认码 加上标志 和地市
PolicyConfirmNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPB where flag = '' and citycode = '${_CityCode}'"`
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
	
		db2 "update CACMain_NCPB set Reason = '5', Desc='跨省续保:续保地区${KS_AreaCode}，续保公司${KS_CompanyCode}，投保确认码${KSX_PolicyConfirmNo}', Flag = '0'
		where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
		db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	done
	
	#本保单续保单跨省续保
	PolicyConfirmNo2=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
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
	
			db2 "update CACMain_NCPB set Reason = '5', Desc='跨省续保:续保地区${KS_AreaCode}，续保公司${KS_CompanyCode}，投保确认码${KSX_PolicyConfirmNo}', Flag = '0'
			where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		done	
	done
	
	
	
	
	#本省和跨省理赔
	#Vin码
	Vin=`db2 -x  "select vin from CACMain_NCP where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	
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
			db2 "update CACMain_NCPB set Reason = '4', Desc='理赔:理赔地区${KSL_AreaCode},理赔公司${KSL_CompanyCode},理赔编码${KSL_ClaimQueryNo},出险时间${KSL_DamageDate}',
			Flag = '0' where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		fi
	
	done
	
	
	
	
	
	
	
	
	#疫情开始时间
	t1=`date -d "${_VirusStartDate}" +%s`
	echo "t1:${t1}"	
	#疫情结束时间
	t2=`date -d "${_VirusEndDate}" +%s`
	echo "t2:${t2}"	
	
	#停驶类型1
	StopTravelType1=`db2 -x  "select StopTravelType from CACMain_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	StopTravelType1=`echo ${StopTravelType1} | tr -d ' '`
	echo "StopTravelType1:${StopTravelType1}"	
	
	StopTravelType2=`db2 -x  "select StopTravelType from CACStopRecover where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	StopTravelType2=`echo ${StopTravelType2} | tr -d ' '`
	echo "StopTravelType2:${StopTravelType2}"
	
	
	#本保单停驶
	if [ -n "${StopTravelType1}" ] 
	then 
		#停驶起期
		StopTraStartDate1=`db2 -x  "select DATE(StopTraStartDate) from CACMain_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		echo "StopTraStartDate1:${StopTraStartDate1}"	
		#停驶止期	
		StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from CACMain_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		#本保单的停驶起期
		StartDate1=`date -d "${StopTraStartDate1}" +%s`
		EndDate1=`date -d "${StopTravelEndDate1}" +%s`
		echo "StartDate1:${StartDate1}"
	
	
		if [ ${StartDate1} -ge ${t1} ] && [ ${t2} -ge ${StartDate1} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTraStartDate},停驶止期${StopTravelEndDate}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		elif [ ${EndDate1} -ge ${t1} ] && [ ${t2} -ge ${EndDate1} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTraStartDate},停驶止期${StopTravelEndDate}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		else [ ${StartDate1} -lt ${t1} ] && [ ${t2} -gt ${EndDate1} ]
		
			db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTraStartDate},停驶止期${StopTravelEndDate}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		fi
	fi	
	if [ -n "${StopTravelType2}" ] 
	then
		#保单停复驶表中的停复驶信息
		#停驶起期
		StopTravelStartDate2=`db2 -x  "select DATE(StopTravelStartDate) from CACStopRecover where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		echo "StopTravelStartDate2:${StopTravelStartDate2}"	
		#停驶止期	
		StopTravelEndDate2=`db2 -x  "select DATE(StopTravelEndDate) from CACStopRecover where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		#本保单的停驶起期
		StartDate2=`date -d "${StopTravelStartDate2}" +%s`
		EndDate2=`date -d "${StopTravelEndDate2}" +%s`
		echo "StartDate2:${StartDate2}"
		
		if [ ${StartDate2} -ge ${t1} ] && [ ${t2} -ge ${StartDate2} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTravelStartDate2},停驶止期${StopTravelEndDate2}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		elif [ ${EndDate2} -ge ${t1} ] && [ ${t2} -ge ${EndDate2} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTravelStartDate2},停驶止期${StopTravelEndDate2}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		else [ ${StartDate2} -lt ${t1} ] && [ ${t2} -gt ${EndDate2} ]
			db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${StopTravelStartDate2},停驶止期${StopTravelEndDate2}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		fi
	fi
	
	
	
	#续保单停停驶
	PolicyConfirmNo1=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
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
		X_StopTravelType=`db2 -x  "select StopTravelType from CACMain_NCP where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
		X_StopTravelType=`echo ${X_StopTravelType} | tr -d ' '`
		
		X_StopTravelType1=`db2 -x  "select StopTravelType from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
		X_StopTravelType1=`echo ${X_StopTravelType1} | tr -d ' '`
		
		if [ -n "${X_StopTravelType}" ] 
		then
		
			#续保单停驶起期
			X_StopTraStartDate=`db2 -x  "select DATE(StopTraStartDate) from CACMain_NCP where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			#续保单停驶止期
			X_StopTravelEndDate=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			StartDate3=`date -d "${X_StopTraStartDate}" +%s`
			EndDate3=`date -d "${X_StopTravelEndDate}" +%s`
			if [ ${StartDate3} -ge ${t1} ] && [ ${t2} -ge ${StartDate3} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate}停驶止期${X_StopTravelEndDate}', Flag = '0'
				where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			elif [ ${EndDate3} -ge ${t1} ] && [ ${t2} -ge ${EndDate3} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate}停驶止期${X_StopTravelEndDate}', Flag = '0'
				where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			else [ ${StartDate3} -lt ${t1} ] && [ ${t2} -gt ${EndDate3} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate}停驶止期${X_StopTravelEndDate}', Flag = '0'
				where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			fi
		fi
		if [ -n "${X_StopTravelType1}" ]
		then
			#保单停复驶表中的停复驶信息
			#停驶起期
			X_StopTraStartDate1=`db2 -x  "select DATE(StopTravelStartDate) from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			echo "X_StopTraStartDate1:${X_StopTraStartDate1}"	
			#停驶止期	
			X_StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			#本保单的停驶起期
			StartDate4=`date -d "${X_StopTraStartDate1}" +%s`
			EndDate4=`date -d "${X_StopTravelEndDate1}" +%s`
			echo "StartDate4:${StartDate4}"
		
			if [ ${StartDate4} -ge ${t1} ] && [ ${t2} -ge ${StartDate4} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate1},停驶止期${X_StopTravelEndDate1}', Flag = '0' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			elif [ ${EndDate4} -ge ${t1} ] && [ ${t2} -ge ${EndDate4} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate1},停驶止期${X_StopTravelEndDate1}', Flag = '0' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			else [ ${StartDate4} -lt ${t1} ] && [ ${t2} -gt ${EndDate4} ]
				db2 "update CACMain_NCPB set Reason = '3', Desc='停驶:停驶起期${X_StopTraStartDate1},停驶止期${X_StopTravelEndDate1}', Flag = '0' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			fi
		fi
	done
	
	
	
	
	
	
	
	#最后一张续保单的投保确认码
	LastX_PolicyConfirmNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}' order by EndDate desc fetch first 1 rows only"`
	echo "${LastX_PolicyConfirmNo}"
	#最后一张续保单的业务类型
	LastX_BizStatus=`db2 -x  "select BizStatus from CACMain_NCP where ConfirmSequenceNo = '${LastX_PolicyConfirmNo}'"`
	echo "${LastX_BizStatus}"
	
	if [ "${LastX_BizStatus}" != "1" ]
	then
	
		AmendConfirmNo=`db2 -x  "select AmendConfirmNo from CAPHEAD where  ConfirmSequenceNo = '${LastX_PolicyConfirmNo}'"`
		EndorseDate=`db2 -x  "select DATE(EndDate) from CACMain_NCP where  ConfirmSequenceNo = '${LastX_PolicyConfirmNo}'"`
		
		db2 "update CACMain_NCPB set Reason = '6', Desc='退保：投保确认码${EndorseConfirmNo},退保生效日期${EndorseDate}', Flag = '0'
		where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
		db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	fi


	
	#保期顺延的数据
	PolicyNo=`db2 -x  "select PolicyNo from CAClaimPolicy_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	if [ -n "${PolicyNo}" ]
	then
		db2 "update CACMain_NCPB set Reason = '', Desc='',
		Flag = '' where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
		db2 "update CACMain_NCP set Flag = '' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	fi

	
	#更新基础表中的续保单
	Desc=`db2 -x  "select Desc from CACMain_NCPB where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	Desc=`echo ${Desc} | tr -d ' '`
	if[ -z "${Desc}" ]
	then
		db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	fi
	
done 
 
 
 
 
 
 
 
 
 
 
 
 







	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/7_iaca_dml_dabiao_${times}.log

