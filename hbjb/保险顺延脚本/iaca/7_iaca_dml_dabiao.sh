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
echo "��������� ->"|tr -d "\012"
    read _CityCode

	
	
echo ""
echo "���������鿪ʼ���� ->"|tr -d "\012"
    read _VirusStartDate	
echo ""
echo "����������������� ->"|tr -d "\012"
    read _VirusEndDate		

################���ϲ��ֲ������޸�        ###############
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���




 
 ##��������Ͷ��ȷ���� ���ϱ�־ �͵���
PolicyConfirmNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPB where flag = '' and citycode = '${_CityCode}'"`
echo "${PolicyConfirmNo}"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($PolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"
for B_PolicyConfirmNo in ${array[@]}
do
	
	
	#��������ʡ����
	#Ͷ��ȷ����
	CONFIRMSEQUENCENO_1==`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${B_PolicyConfirmNo}'"`
	echo "CONFIRMSEQUENCENO_1��${CONFIRMSEQUENCENO_1}"
	#����ɵķָ���
	OLD_IFS="$IFS"
	#�ָ������óɿո�
	IFS=" "
	array3=($CONFIRMSEQUENCENO_1)
	#���ԭ���ķָ���
	IFS="$OLD_IFS"
	for KSX_PolicyConfirmNo in ${array3[@]}
	do
		#��������
		KS_AreaCode=`db2 -x  "select AREACODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX_PolicyConfirmNo}'"`
		#������˾
		KS_CompanyCode=`db2 -x  "select COMPANYCODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX_PolicyConfirmNo}'"`
		#������Ͷ��ȷ����
		KSX_PolicyConfirmNo=`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX_PolicyConfirmNo}'"`
	
		db2 "update CACMain_NCPB set Reason = '5', Desc='��ʡ����:��������${KS_AreaCode}��������˾${KS_CompanyCode}��Ͷ��ȷ����${KSX_PolicyConfirmNo}', Flag = '0'
		where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
		db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	done
	
	#��������������ʡ����
	PolicyConfirmNo2=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "PolicyConfirmNo2��${PolicyConfirmNo2}"
	#����ɵķָ���
	OLD_IFS="$IFS"
	#�ָ������óɿո�
	IFS=" "
	array4=($PolicyConfirmNo2)
	#���ԭ���ķָ���
	IFS="$OLD_IFS"
	for KSX1_PolicyConfirmNo in ${array4[@]}
	do
		CONFIRMSEQUENCENO_2==`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${B_PolicyConfirmNo}'"`
		#����ɵķָ���
		OLD_IFS="$IFS"
		#�ָ������óɿո�
		IFS=" "
		array5=($CONFIRMSEQUENCENO_2)
		#���ԭ���ķָ���
		IFS="$OLD_IFS"
		for KSX2_PolicyConfirmNo in ${array5[@]}
		do
			#��������
			KS_AreaCode=`db2 -x  "select AREACODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX2_PolicyConfirmNo}'"`
			#������˾
			KS_CompanyCode=`db2 -x  "select COMPANYCODE_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX2_PolicyConfirmNo}'"`
			#������Ͷ��ȷ����
			KSX_PolicyConfirmNo=`db2 -x  "select CONFIRMSEQUENCENO_1 from KSCMain_NCP where CONFIRMSEQUENCENO = '${KSX2_PolicyConfirmNo}'"`
	
			db2 "update CACMain_NCPB set Reason = '5', Desc='��ʡ����:��������${KS_AreaCode}��������˾${KS_CompanyCode}��Ͷ��ȷ����${KSX_PolicyConfirmNo}', Flag = '0'
			where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		done	
	done
	
	
	
	
	#��ʡ�Ϳ�ʡ����
	#Vin��
	Vin=`db2 -x  "select vin from CACMain_NCP where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	
	#Ͷ��ȷ����
	CONFIRMSEQUENCENO==`db2 -x  "select CONFIRMSEQUENCENO from KSClaim_NCP where vin = '${Vin}'"`
	echo "CONFIRMSEQUENCENO��${CONFIRMSEQUENCENO}"
	#����ɵķָ���
	OLD_IFS="$IFS"
	#�ָ������óɿո�
	IFS=" "
	array2=($CONFIRMSEQUENCENO)
	#���ԭ���ķָ���
	IFS="$OLD_IFS"
	for KSL_PolicyConfirmNo in ${array2[@]}
	do
		#�������
		KSL_AreaCode=`db2 -x  "select AREACODE from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		#���⹫˾
		KSL_CompanyCode=`db2 -x  "select COMPANYCODE from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		#�������
		KSL_ClaimQueryNo=`db2 -x  "select CLAIMSEQUENCENO from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		#����ʱ��
		KSL_DamageDate=`db2 -x  "select DATE(LOSSTIME) from KSClaim_NCP where CONFIRMSEQUENCENO = '${KSL_PolicyConfirmNo}'"`
		
		t3=`date -d "${KSL_DamageDate}" +%s`
		
		if [ ${t3} -gt  ${t1} ] && [ ${t2} -gt ${t3} ]
		then
			db2 "update CACMain_NCPB set Reason = '4', Desc='����:�������${KSL_AreaCode},���⹫˾${KSL_CompanyCode},�������${KSL_ClaimQueryNo},����ʱ��${KSL_DamageDate}',
			Flag = '0' where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		fi
	
	done
	
	
	
	
	
	
	
	
	#���鿪ʼʱ��
	t1=`date -d "${_VirusStartDate}" +%s`
	echo "t1:${t1}"	
	#�������ʱ��
	t2=`date -d "${_VirusEndDate}" +%s`
	echo "t2:${t2}"	
	
	#ͣʻ����1
	StopTravelType1=`db2 -x  "select StopTravelType from CACMain_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	StopTravelType1=`echo ${StopTravelType1} | tr -d ' '`
	echo "StopTravelType1:${StopTravelType1}"	
	
	StopTravelType2=`db2 -x  "select StopTravelType from CACStopRecover where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	StopTravelType2=`echo ${StopTravelType2} | tr -d ' '`
	echo "StopTravelType2:${StopTravelType2}"
	
	
	#������ͣʻ
	if [ -n "${StopTravelType1}" ] 
	then 
		#ͣʻ����
		StopTraStartDate1=`db2 -x  "select DATE(StopTraStartDate) from CACMain_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		echo "StopTraStartDate1:${StopTraStartDate1}"	
		#ͣʻֹ��	
		StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from CACMain_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		#��������ͣʻ����
		StartDate1=`date -d "${StopTraStartDate1}" +%s`
		EndDate1=`date -d "${StopTravelEndDate1}" +%s`
		echo "StartDate1:${StartDate1}"
	
	
		if [ ${StartDate1} -ge ${t1} ] && [ ${t2} -ge ${StartDate1} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTraStartDate},ͣʻֹ��${StopTravelEndDate}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		elif [ ${EndDate1} -ge ${t1} ] && [ ${t2} -ge ${EndDate1} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTraStartDate},ͣʻֹ��${StopTravelEndDate}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		else [ ${StartDate1} -lt ${t1} ] && [ ${t2} -gt ${EndDate1} ]
		
			db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTraStartDate},ͣʻֹ��${StopTravelEndDate}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		fi
	fi	
	if [ -n "${StopTravelType2}" ] 
	then
		#����ͣ��ʻ���е�ͣ��ʻ��Ϣ
		#ͣʻ����
		StopTravelStartDate2=`db2 -x  "select DATE(StopTravelStartDate) from CACStopRecover where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		echo "StopTravelStartDate2:${StopTravelStartDate2}"	
		#ͣʻֹ��	
		StopTravelEndDate2=`db2 -x  "select DATE(StopTravelEndDate) from CACStopRecover where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
		#��������ͣʻ����
		StartDate2=`date -d "${StopTravelStartDate2}" +%s`
		EndDate2=`date -d "${StopTravelEndDate2}" +%s`
		echo "StartDate2:${StartDate2}"
		
		if [ ${StartDate2} -ge ${t1} ] && [ ${t2} -ge ${StartDate2} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTravelStartDate2},ͣʻֹ��${StopTravelEndDate2}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		elif [ ${EndDate2} -ge ${t1} ] && [ ${t2} -ge ${EndDate2} ]
		then
			db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTravelStartDate2},ͣʻֹ��${StopTravelEndDate2}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		
		else [ ${StartDate2} -lt ${t1} ] && [ ${t2} -gt ${EndDate2} ]
			db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTravelStartDate2},ͣʻֹ��${StopTravelEndDate2}', Flag = '0' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
			db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
			'${B_PolicyConfirmNo}'"
		fi
	fi
	
	
	
	#������ͣͣʻ
	PolicyConfirmNo1=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "PolicyConfirmNo1��${PolicyConfirmNo1}"
	#����ɵķָ���
	OLD_IFS="$IFS"
	#�ָ������óɿո�
	IFS=" "
	array1=($PolicyConfirmNo1)
	#���ԭ���ķָ���
	IFS="$OLD_IFS"
	for X_PolicyConfirmNo in ${array1[@]}
	do
		#������ͣʻ����
		X_StopTravelType=`db2 -x  "select StopTravelType from CACMain_NCP where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
		X_StopTravelType=`echo ${X_StopTravelType} | tr -d ' '`
		
		X_StopTravelType1=`db2 -x  "select StopTravelType from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
		X_StopTravelType1=`echo ${X_StopTravelType1} | tr -d ' '`
		
		if [ -n "${X_StopTravelType}" ] 
		then
		
			#������ͣʻ����
			X_StopTraStartDate=`db2 -x  "select DATE(StopTraStartDate) from CACMain_NCP where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			#������ͣʻֹ��
			X_StopTravelEndDate=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			StartDate3=`date -d "${X_StopTraStartDate}" +%s`
			EndDate3=`date -d "${X_StopTravelEndDate}" +%s`
			if [ ${StartDate3} -ge ${t1} ] && [ ${t2} -ge ${StartDate3} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate}ͣʻֹ��${X_StopTravelEndDate}', Flag = '0'
				where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			elif [ ${EndDate3} -ge ${t1} ] && [ ${t2} -ge ${EndDate3} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate}ͣʻֹ��${X_StopTravelEndDate}', Flag = '0'
				where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			else [ ${StartDate3} -lt ${t1} ] && [ ${t2} -gt ${EndDate3} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate}ͣʻֹ��${X_StopTravelEndDate}', Flag = '0'
				where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			fi
		fi
		if [ -n "${X_StopTravelType1}" ]
		then
			#����ͣ��ʻ���е�ͣ��ʻ��Ϣ
			#ͣʻ����
			X_StopTraStartDate1=`db2 -x  "select DATE(StopTravelStartDate) from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			echo "X_StopTraStartDate1:${X_StopTraStartDate1}"	
			#ͣʻֹ��	
			X_StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where ConfirmSequenceNo = '${X_PolicyConfirmNo}'"`
			#��������ͣʻ����
			StartDate4=`date -d "${X_StopTraStartDate1}" +%s`
			EndDate4=`date -d "${X_StopTravelEndDate1}" +%s`
			echo "StartDate4:${StartDate4}"
		
			if [ ${StartDate4} -ge ${t1} ] && [ ${t2} -ge ${StartDate4} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate1},ͣʻֹ��${X_StopTravelEndDate1}', Flag = '0' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			elif [ ${EndDate4} -ge ${t1} ] && [ ${t2} -ge ${EndDate4} ]
			then
				db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate1},ͣʻֹ��${X_StopTravelEndDate1}', Flag = '0' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			
			else [ ${StartDate4} -lt ${t1} ] && [ ${t2} -gt ${EndDate4} ]
				db2 "update CACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate1},ͣʻֹ��${X_StopTravelEndDate1}', Flag = '0' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
				db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
				'${B_PolicyConfirmNo}'"
			fi
		fi
	done
	
	
	
	
	
	
	
	#���һ����������Ͷ��ȷ����
	LastX_PolicyConfirmNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}' order by EndDate desc fetch first 1 rows only"`
	echo "${LastX_PolicyConfirmNo}"
	#���һ����������ҵ������
	LastX_BizStatus=`db2 -x  "select BizStatus from CACMain_NCP where ConfirmSequenceNo = '${LastX_PolicyConfirmNo}'"`
	echo "${LastX_BizStatus}"
	
	if [ "${LastX_BizStatus}" != "1" ]
	then
	
		AmendConfirmNo=`db2 -x  "select AmendConfirmNo from CAPHEAD where  ConfirmSequenceNo = '${LastX_PolicyConfirmNo}'"`
		EndorseDate=`db2 -x  "select DATE(EndDate) from CACMain_NCP where  ConfirmSequenceNo = '${LastX_PolicyConfirmNo}'"`
		
		db2 "update CACMain_NCPB set Reason = '6', Desc='�˱���Ͷ��ȷ����${EndorseConfirmNo},�˱���Ч����${EndorseDate}', Flag = '0'
		where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
		db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	fi


	
	#����˳�ӵ�����
	PolicyNo=`db2 -x  "select PolicyNo from CAClaimPolicy_NCP where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	if [ -n "${PolicyNo}" ]
	then
		db2 "update CACMain_NCPB set Reason = '', Desc='',
		Flag = '' where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"
		db2 "update CACMain_NCP set Flag = '' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	fi

	
	#���»������е�������
	Desc=`db2 -x  "select Desc from CACMain_NCPB where ConfirmSequenceNo = '${B_PolicyConfirmNo}'"`
	Desc=`echo ${Desc} | tr -d ' '`
	if[ -z "${Desc}" ]
	then
		db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = 
		'${B_PolicyConfirmNo}'"
	fi
	
done 
 
 
 
 
 
 
 
 
 
 
 
 







	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/7_iaca_dml_dabiao_${times}.log

