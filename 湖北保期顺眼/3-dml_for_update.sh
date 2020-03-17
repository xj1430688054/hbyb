#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ���������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
  #  read _DBNAME
 _DBNAME=iaca51db 
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
 #   read _DBUSER
_DBUSER=intiaci
 
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
_AREACODE=`db2 -x  "select PARAMETERVALUE from IADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���

## insert into INSTIACI.CADSYSCONFIG (PARAMETERCODE, PARAMETERTYPE, COMPANYCODE, PARAMETERVALUE, AREACODE, PARAMETERDESC, REMARK, VALIDSTATUS) values ('ClosingDate', '00', 'ALL', '2020-03-38', '510000', '�����ֹ����', '', '1');

## ��ȡ�����ֹ����
_CLOSINGDAT=`db2 -x "select parametervalue from cadsysconfig where cadsysconfig.PARAMETERCODE = 'ClosingDate'"`

###����Ч��Ͷ��ȷ����ɾѡ����

db2 "
insert into CACMain_B(ConfirmSequenceNo, PolicyNo, companycode, CityCode, EffectiveDate, ExpireDate, Vin, LicenseNo, EngineNo, BusinessType)
	select 
		a.ConfirmSequenceNo ,
		a.PolicyNo,
		a.companycode,
		a.CityCode,
		a.EffectiveDate,
		a.ExpireDate,
		b.Vin,
		b.LicenseNo,
		b.EngineNo,
		'3'
	from cacmain a 
	inner join CACVehicle b on a.ConfirmSequenceNo = b.ConfirmSequenceNo
	where a.EffectiveDate <= '2020-01-23 00:00:00' 
		and a.ExpireDate > '${_CLOSINGDAT}'
		and a.ValidStatus ='1'
		and (values days(date(a.ExpireDate))- days(date(a.EffectiveDate)))>30
		and a.StopTravelType != '1' 

	
"



##���α�����Ͷ��ȷ����CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct PolicyConfirmNo from CACMain_B"`

echo ${PolicyConfirmNo}
echo "${PolicyConfirmNo}"
echo "���α�������������"
#����ɵķָ���
OLD_IFS="$IFS"
#�ָ������óɿո�
IFS=" "
array=($PolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"

for X_PolicyConfirmNo in ${array[@]}
do
db2 "insert into CACMain_B(PolicyConfirmNo,PolicyNo,companycode,CityCode,EFFECTIVEDATE,EXPIREDATE,LastPoliConfirmNo,VIN,LicenseNo,EngineNo,BusinessType)
	select 
		a.PolicyConfirmNo, 
		a.PolicyNo, 
		a.companycode,
		a.CityCode, 
		a.StartDate, 
		a.EndDate, 
		a.LastPoliConfirmNo,
		b.FrameNo,
		b.LicenseNo, 
		b.EngineNo,
		'3' 
		from iacmain a,IATCItemCar b
	where a.LastPoliConfirmNo = '${X_PolicyConfirmNo}' 
	and a.PolicyConfirmNo = b.PolicyConfirmNo"
 



db2 "
insert into CACCOVERAGE_B (ConfirmSequenceNo, PolicyNo, companycode, CityCode, COMCOVERAGECODE,COMCOVERAGENAME, EffectiveDate, ExpireDate,BusinessType)
	select 
		a.ConfirmSequenceNo ,
		a.PolicyNo,
		a.companycode,
		a.CityCode,
		b.ComCoverageCode ,
		b.ComCoverageName ,
		b.EffectiveDate,
		b.ExpireDate,
		'3'
	from cacmain a 
	inner join CACCOVERAGE b on a.ConfirmSequenceNo = b.ConfirmSequenceNo
	where b.ConfirmSequenceNo = '${X_PolicyConfirmNo}'

	
"
done


	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

