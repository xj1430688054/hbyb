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


################�밴��������дsql####################

##���α�����Ͷ��ȷ����CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct CONFIRMSEQUENCENO from CACMain_NCPB"`

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
db2  "insert into CACMAIN_NCPX ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, LASTPOLICONFIRMNO, VIN, LICENSENO, ENGINENO, BUSINESSTYPE, INPUTDATE) 
	select 
		a.CONFIRMSEQUENCENO, 
		a.PolicyNo, 
		a.companycode,
		a.CityCode, 
		a.EFFECTIVEDATE, 
		a.EXPIREDATE, 
		'${X_PolicyConfirmNo}',
		a.vin,
		a.LicenseNo, 
		a.EngineNo,
		'3' ,
		sys.extracttime
		from CACMain_NCP a, (select current timestamp as extracttime from sysibm.sysdummy1) sys
	where a.LastPolicyConfirmNo = '${X_PolicyConfirmNo}' 
	"

done





#######������������������������������
i=0;

while true
do	
		i=$[i+1];
		###��ѯ�ڼ��������� ,��Ҫ�������ּ���ڼ���
		XuPolicyConfirmNo=`db2 -x  "	select 
										a.CONFIRMSEQUENCENO
									from CACMain_NCPX a 
										inner join CACMain_NCP b on a.CONFIRMSEQUENCENO = b.LastPolicyConfirmNo"`
										
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
	db2  "insert into CACMAIN_NCPX ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, LASTPOLICONFIRMNO, VIN, LICENSENO, ENGINENO, BUSINESSTYPE, INPUTDATE) 
		select 
			a.CONFIRMSEQUENCENO, 
			a.PolicyNo, 
			a.companycode,
			a.CityCode, 
			a.EFFECTIVEDATE, 
			a.EXPIREDATE, 
			b.LastPoliConfirmNo,
			a.vin,
			a.LicenseNo, 
			a.EngineNo,
			'3' ,
			sys.extracttime
			from CACMain_NCP a, (select current timestamp as extracttime from sysibm.sysdummy1) sys
			left join CACMain_NCPX b on a.CONFIRMSEQUENCENO = b.CONFIRMSEQUENCENO
		where a.LastPolicyConfirmNo = '${X_PolicyConfirmNo}' 
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

