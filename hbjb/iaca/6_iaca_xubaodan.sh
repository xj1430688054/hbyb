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
_DBNAME=iaca42db	
	
	
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
echo ""
echo "�����뱣�������أ� �������� �������人 ��420101�� ->"|tr -d "\012"
#	read _ROWS
_CITYCODE=420100


################�밴��������дsql####################

##���α�����Ͷ��ȷ����CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct CONFIRMSEQUENCENO from CACMain_NCPB  where reason = ''and  Flag = '' and flag = '' and citycode = '${_CITYCODE}'"`

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
db2  "insert into CACMAIN_NCPX ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, LASTPOLICYCONFIRMNO, LASTCITYCODE, VIN, LICENSENO, ENGINENO, LEVEL, FLAG, INPUTDATE) 
	select 
		a.CONFIRMSEQUENCENO, 
		a.PolicyNo, 
		a.companycode,
		a.CityCode, 
		a.EFFECTIVEDATE, 
		a.EXPIREDATE, 
		'${X_PolicyConfirmNo}',
		'${_CITYCODE}',
		a.vin,
		a.LicenseNo, 
		a.EngineNo,
		'1',
		'',
		sys.extracttime
		from CACMain_NCP a, (select current timestamp as extracttime from sysibm.sysdummy1) sys
	where a.LastPolicyConfirmNo = '${X_PolicyConfirmNo}' 
	"

done




echo "------------------------------------------------------------------------------"
echo "---------------------��������������--------------------------------------"
echo "---------------------��������������-------------------------------------------"
echo "------------------------------------------------------------------------------"
#######������������������������������
i=1;

while true
do	
		
		###��ѯ�ڼ��������� ,��Ҫ�������ּ���ڼ���
		XuPolicyConfirmNo=`db2 -x  "select 
										a.CONFIRMSEQUENCENO
									from CACMain_NCPX a 
										inner join CACMain_NCP b on a.CONFIRMSEQUENCENO = b.LastPolicyConfirmNo
																	and b.flag = ''  
																	and a.lastcitycode = '${_CITYCODE}' 
																	and a.flag = ''
									where a.level = '${i}'"`
	
	db2 "update CACMain_NCPX a set a.flag = '1' where a.flag = '' and citycode = '${_CITYCODE}' "
	

										
	if [  -z "${XuPolicyConfirmNo}" ]
    then
		break;
    fi
	
	echo "��${i}��������${XuPolicyConfirmNo}"
	echo "-----------------------------------------------------------------------"
	
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
	db2  "insert into CACMAIN_NCPX ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, LASTPOLICYCONFIRMNO, LASTCITYCODE, VIN, LICENSENO, ENGINENO, LEVEL, FLAG, INPUTDATE) 
		select 
			a.CONFIRMSEQUENCENO, 
			a.PolicyNo, 
			a.companycode,
			a.CityCode, 
			a.EFFECTIVEDATE, 
			a.EXPIREDATE, 
			b.LastPolicyConfirmNo,
			'${_CITYCODE}',
			a.vin,
			a.LicenseNo, 
			a.EngineNo,
			'${i}', 
			'',
			sys.extracttime
			from (select current timestamp as extracttime from sysibm.sysdummy1) sys , CACMain_NCP a,
			(select e.LastPolicyConfirmNo  from CACMain_NCPX e where e.CONFIRMSEQUENCENO = '${Xu_PolicyConfirmNo}'  fetch first 1 row only) b
		where a.LastPolicyConfirmNo = '${Xu_PolicyConfirmNo}' 
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

