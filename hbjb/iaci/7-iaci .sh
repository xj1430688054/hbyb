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
echo "���������鿪ʼ���� ->"|tr -d "\012"
    read _VirusStartDate	
echo ""
echo "����������������� ->"|tr -d "\012"
    read _VirusEndDate		

################���ϲ��ֲ������޸�        ###############
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���



#�ж�·���Ƿ����
 if [ ! -d ${_DATAPATH} ]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 
 
 ##��������Ͷ��ȷ���� ���ϱ�־ �͵���
PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPB where flag = ''"`
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
	##��������
	StartDate=`db2 -x  "select DATE(StartDate) from IACMain_NCPB where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "${StartDate}"
	##����ֹ��
	EndtDate=`db2 -x  "select DATE(EndtDate) from IACMain_NCPB where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	StartDate1=`date -d "${StartDate}" +%s`
	echo "${StartDate1}"
	EndDate1=`date -d "${EndDate}" +%s`
	echo "${EndDate1}"
	
	#ҵ��״̬
	BizStatus=`db2 -x  "select BizStatus from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	echo "${BizStatus}"	
	
	echo "StopTravelEndDate:${StopTravelEndDate}"	
	#���鿪ʼʱ��
	t1=`date -d "${_VirusStartDate}" +%s`
	echo "t1:${t1}"	
	#�������ʱ��
	t2=`date -d "${_VirusEndDate}" +%s`
	echo "t2:${t2}"	
	
	#ͣʻ����1
	StopTravelType1=`db2 -x  "select StopTravelType from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
	StopTravelType1=`echo ${StopTravelType1} | tr -d ' '`
	echo "StopTravelType1:${StopTravelType1}"	
	
	
	
	
	#������ͣʻ
	if [ -n "${StopTravelType1}" ] 
	then 
		#ͣʻ����
		StopTraStartDate1=`db2 -x  "select DATE(StopTraStartDate) from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		echo "StopTraStartDate1:${StopTraStartDate1}"	
		#ͣʻֹ��	
		StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from IACMain_NCP where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		#��������ͣʻ����
		StartDate1=`date -d "${StopTraStartDate1}" +%s`
		echo "StartDate1:${StartDate1}"
	
	
		if [ ${StartDate1} -gt ${t1} ] && [ ${t2} -gt ${StartDate1} ]
		then
			db2 "update IACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTraStartDate},ͣʻֹ��${StopTravelEndDate}', Flag = '0' where PolicyConfirmNo = 
			'${B_PolicyConfirmNo}'"
		fi
	else
		#����ͣ��ʻ���е�ͣ��ʻ��Ϣ
		#ͣʻ����
		StopTravelStartDate2=`db2 -x  "select DATE(StopTravelStartDate) from IACStopRecover where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		echo "StopTravelStartDate2:${StopTravelStartDate2}"	
		#ͣʻֹ��	
		StopTravelEndDate2=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where PolicyConfirmNo = '${B_PolicyConfirmNo}'"`
		#��������ͣʻ����
		StartDate2=`date -d "${StopTravelStartDate2}" +%s`
		echo "StartDate2:${StartDate2}"
		
		if [ ${StartDate2} -gt ${t1} ] && [ ${t2} -gt ${StartDate2} ]
		then
			db2 "update IACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${StopTravelStartDate2},ͣʻֹ��${StopTravelEndDate2}', Flag = '0' where PolicyConfirmNo = 
			'${B_PolicyConfirmNo}'"
		fi
	fi
	
	
	
	#������ͣͣʻ
	PolicyConfirmNo1=`db2 -x  "select PolicyConfirmNo from IACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
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
		X_StopTravelType=`db2 -x  "select StopTravelType from IACMain_NCP where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
		X_StopTravelType=`echo ${X_StopTravelType} | tr -d ' '`
		if [ -n "${X_StopTravelType}" ] 
		then
		
			#������ͣʻ����
			X_StopTraStartDate=`db2 -x  "select DATE(StopTraStartDate) from IACMain_NCP where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			#������ͣʻֹ��
			X_StopTravelEndDate=`db2 -x  "select DATE(StopTravelEndDate) from IACMain_NCP where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			StartDate3=`date -d "${X_StopTraStartDate}" +%s`
			if [ ${StartDate3} -gt ${t1} ] && [ ${t2} -gt ${StartDate3} ]
			then
				db2 "update IACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate}ͣʻֹ��${X_StopTravelEndDate}', Flag = '0'
				where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
			fi
		else
			#����ͣ��ʻ���е�ͣ��ʻ��Ϣ
			#ͣʻ����
			X_StopTraStartDate1=`db2 -x  "select DATE(StopTravelStartDate) from IACStopRecover where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			echo "X_StopTraStartDate1:${X_StopTraStartDate1}"	
			#ͣʻֹ��	
			X_StopTravelEndDate1=`db2 -x  "select DATE(StopTravelEndDate) from IACStopRecover where PolicyConfirmNo = '${X_PolicyConfirmNo}'"`
			#��������ͣʻ����
			StartDate4=`date -d "${X_StopTravelEndDate1}" +%s`
			echo "StartDate4:${StartDate4}"
		
			if [ ${StartDate4} -gt ${t1} ] && [ ${t2} -gt ${StartDate4} ]
			then
				db2 "update IACMain_NCPB set Reason = '3', Desc='ͣʻ:ͣʻ����${X_StopTraStartDate1},ͣʻֹ��${X_StopTravelEndDate1}', Flag = '0' where PolicyConfirmNo = 
				'${B_PolicyConfirmNo}'"
			fi
		fi
	done
	
	
	
	
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
	
		db2 "update IACMain_NCPB set Reason = '5', Desc='��ʡ����:��������${KS_AreaCode}��������˾${KS_CompanyCode}��Ͷ��ȷ����${KSX_PolicyConfirmNo}', Flag = '0'
		where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
	done
	
	#��������������ʡ����
	PolicyConfirmNo2=`db2 -x  "select PolicyConfirmNo from IACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
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
	
			db2 "update IACMain_NCPB set Reason = '5', Desc='��ʡ����:��������${KS_AreaCode}��������˾${KS_CompanyCode}��Ͷ��ȷ����${KSX_PolicyConfirmNo}', Flag = '0'
			where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
		done	
	done
	
	
	
	
	#���һ����������Ͷ��ȷ����
	LastX_PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPX where LastPoliConfirmNo = '${B_PolicyConfirmNo}' order by EndDate desc fetch first 1 rows only"`
	echo "${LastX_PolicyConfirmNo}"
	#���һ����������ҵ������
	LastX_BizStatus=`db2 -x  "select BizStatus from IACMain_NCP where PolicyConfirmNo = '${LastX_PolicyConfirmNo}'"`
	echo "${LastX_BizStatus}"
	
	if [ "${LastX_BizStatus}" != "1" ]
	then
	
		EndorseConfirmNo=`db2 -x  "select EndorseConfirmNo from IAPHEAD where  PolicyConfirmNo = '${LastX_PolicyConfirmNo}'"`
		EndorseDate=`db2 -x  "select DATE(EndDate) from IACMain_NCP where  PolicyConfirmNo = '${LastX_PolicyConfirmNo}'"`
		
		db2 "update IACMain_NCPB set Reason = '6', Desc='�˱���Ͷ��ȷ����${EndorseConfirmNo},�˱���Ч����${EndorseDate}', Flag = '0'
		where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
	fi






	#��ʡ�Ϳ�ʡ����
	#Vin��
	Vin=`db2 -x  "select vin from IACMain_NCP where LastPoliConfirmNo = '${B_PolicyConfirmNo}'"`
	
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
			db2 "update IACMain_NCPB set Reason = '4', Desc='����:�������${KSL_AreaCode},���⹫˾${KSL_CompanyCode},�������${KSL_ClaimQueryNo},����ʱ��${KSL_DamageDate}',
			Flag = '0' where PolicyConfirmNo = '${B_PolicyConfirmNo}'"
		fi
	
	done
	

	
done 
 
 
 
 
 
 
 
 
 
 
 
 







	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

