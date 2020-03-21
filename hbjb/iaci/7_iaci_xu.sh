#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ�������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
  #  read _DBNAME
_DBNAME=iaci42db	
	
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
 #   read _DBUSER
_DBUSER=instiaci
	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
 #   read _PWD
_PWD=password
	
echo ""    
echo "������schema�� ->"|tr -d "\012"
  #  read _SCHEMA
_SCHEMA=instiaci

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
echo "�������ռ� ->"|tr -d "\012"
#	read _TBSDATA
_TBSDATA=tbsdata

echo ""
echo "�����������ռ� ->"|tr -d "\012"
#	read _TBSINDEX
_TBSINDEX=tbsindex

################�밴��������дsql####################


##���α�����Ͷ��ȷ����IACMain_B
PolicyConfirmNo=`db2 -x  "select distinct POLICYCONFIRMNO from IACMain_NCPB"`

echo "${PolicyConfirmNo}"
echo "���α�������������"
##����ɵķָ���
OLD_IFS="$IFS"
##�ָ������óɿո�
IFS=" "
array=($PolicyConfirmNo)
##���ԭ���ķָ���
IFS="$OLD_IFS"



####��������������ѯ�鱨��
for X_PolicyConfirmNo in ${array[@]}
do
echo "${X_PolicyConfirmNo}"
db2  "insert into IACMAIN_NCPX ( POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, LASTPOLICONFIRMNO, FRAMENO, LICENSENO, ENGINENO, INPUTDATE) 
	select 
		a.POLICYCONFIRMNO, 
		a.PolicyNo, 
		a.companycode,
		a.CityCode, 
		a.STARTDATE, 
		a.ENDDATE, 
		'${X_PolicyConfirmNo}',
		a.FRAMENO,
		a.LicenseNo, 
		a.EngineNo,
		sys.extracttime
		from IACMain_NCP a, (select current timestamp as extracttime from sysibm.sysdummy1) sys
	where a.LastPoliConfirmNo = '${X_PolicyConfirmNo}' 
	"

done





#######������������������������������
i=0;
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------������-------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
while true
do	
		i=$[i+1];
		###��ѯ�ڼ��������� ,��Ҫ�������ּ���ڼ���
		XuPolicyConfirmNo=`db2 -x  "	select 
										a.PolicyConfirmNo 
									from IACMain_NCPX a 
										inner join IACMain_NCP b on a.PolicyConfirmNo  = b.LastPoliConfirmNo"`
	echo	${XuPolicyConfirmNo}
	
	if [  -z "$XuPolicyConfirmNo" ]
    then
		break;
    fi
	
	##����ɵķָ���
	OLD_IFS="$IFS"
	##�ָ������óɿո�
	IFS=" "
	arrays=($XuPolicyConfirmNo)
	##���ԭ���ķָ���
	IFS="$OLD_IFS"
	
	for Xu_PolicyConfirmNo in ${array[@]}
	do
	echo "${X_PolicyConfirmNo}"
	db2  "insert into IACMAIN_NCPX ( POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, LASTPOLICONFIRMNO, FRAMENO, LICENSENO, ENGINENO, INPUTDATE) 
		select 
			a.POLICYCONFIRMNO, 
			a.PolicyNo, 
			a.companycode,
			a.CityCode, 
			a.STARTDATE, 
			a.ENDDATE, 
			b.LastPoliConfirmNo,
			a.FRAMENO,
			a.LicenseNo, 
			a.EngineNo,
			sys.extracttime
			from IACMain_NCP a, (select current timestamp as extracttime from sysibm.sysdummy1) sys
			left join IACMain_NCPX b on a.POLICYCONFIRMNO = b.POLICYCONFIRMNO
		where a.LASTPOLICONFIRMNO = '${X_PolicyConfirmNo}' 
		"

	done


							
										
 
done



db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

