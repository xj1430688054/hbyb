#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ�������
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
db2 set schema=${_SCHEMA}

################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############


echo ""
echo "�����뱣�������أ� �������� �������人 ��420100�� ->"|tr -d "\012"
	read _CITYCODE
#_CITYCODE=420100

################�밴��������дsql####################


##���α�����Ͷ��ȷ����IACMain_B
PolicyConfirmNo=`db2 -x  "	select 
								distinct POLICYCONFIRMNO 
							from IACMain_NCPB  
							where reason = '' 
								and flag = '' 
								and  citycode = '${_CITYCODE}'"`

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
db2  "insert into IACMAIN_NCPX ( POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, LASTPOLICONFIRMNO, LASTCITYCODE, FRAMENO, LICENSENO, ENGINENO, LEVEL, FLAG, INPUTDATE) 
	select 
		a.POLICYCONFIRMNO, 
		a.PolicyNo, 
		a.companycode,
		a.CityCode, 
		a.STARTDATE, 
		a.ENDDATE, 
		'${X_PolicyConfirmNo}',
		'${_CITYCODE}',
		a.FRAMENO,
		a.LicenseNo, 
		a.EngineNo,
		'1',
		'',
		sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys, IACMain_NCP a
	where a.LastPoliConfirmNo = '${X_PolicyConfirmNo}' 
	"

done





#######������������������������������
i=1;
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------������-------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
while true
do	
		
		###��ѯ�ڼ��������� ,��������������ʵ�� ���ҹ���һ�ױ�������⡣

		XuPolicyConfirmNo=`db2 -x  "	select 
										a.PolicyConfirmNo 
									from IACMain_NCPX a 
										inner join IACMain_NCP b on a.PolicyConfirmNo  = b.LastPoliConfirmNo 
																	and b.flag = ''  
																	and a.lastcitycode = '${_CITYCODE}' 
																	and a.flag = ''
									where a.level = '${i}'
										  "`
										  
	db2 "update IACMain_NCPX a set flag = '1' where a.flag = '' and lastcitycode = '${_CITYCODE}' "
	echo "��${i}��������${XuPolicyConfirmNo}"
	echo "-----------------------------------------------------------------------"
	
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
	i=$[i+1];
	
	for Xu_PolicyConfirmNo in ${arrays[@]}
	do
	echo "${Xu_PolicyConfirmNo}"
	db2  "insert into IACMAIN_NCPX ( POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, LASTPOLICONFIRMNO, LASTCITYCODE, FRAMENO, LICENSENO, ENGINENO, LEVEL, FLAG, INPUTDATE) 
		select 
			a.POLICYCONFIRMNO, 
			a.PolicyNo, 
			a.companycode,
			a.CityCode, 
			a.STARTDATE, 
			a.ENDDATE, 
			b.LastPoliConfirmNo,
			'${_CITYCODE}',
			a.FRAMENO,
			a.LicenseNo, 
			a.EngineNo,
			'${i}',
			'',
			sys.extracttime
			from (select current timestamp as extracttime from sysibm.sysdummy1) sys, IACMain_NCP a, 
			(select e.LastPoliConfirmNo  from IACMain_NCPX e where e.POLICYCONFIRMNO = '${Xu_PolicyConfirmNo}'  fetch first 1 row only) b
		where a.LASTPOLICONFIRMNO = '${Xu_PolicyConfirmNo}' 
		"

	done


							
										
 
done



db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/6-dml_${times}.log

