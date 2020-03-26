#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ���������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
#read _DBNAME
_DBNAME=iaca42db	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
#    read _DBUSER
_DBUSER=instiaci	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
#    read _PWD
_PWD=password	
echo ""    
echo "������schema�� ->"|tr -d "\012"
#    read _SCHEMA
_SCHEMA=instiaci


db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}


################���ϲ��ֲ������޸�        ###############
_AREACODE=`db2 -x  "select PARAMETERVALUE from IADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################���½ű�������ʵ������޸�###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
_CLOSINGDAT=`db2 -x "select parametervalue from iadsysconfig where PARAMETERCODE = 'ClosingDate'"`
_CLOSINGDAT=`echo ${_CLOSINGDAT} | tr -d ' '`


echo ""
echo "�������ϴ�����ʱ�� ->"| tr -d "\012"
#	read _LASTDATE
_LASTDATE='2020-02-02'

#���»���������
echo "--------------------------"
echo "���»���������"
db2 "MERGE
into CACMain_NCP a using (
select 
    c5.POLICYNO,
    c5.COMPANYCODE,
    c5.CITYCODE,
    c5.EFFECTIVEDATE,
    c5.EXPIREDATE,
    c5.STOPTRAVELTYPE,
    c5.STOPTRASTRATDATE,
    c5.StopTravelEndDate,
    c5.BIZSTATUS,
    c5.LASTPOLICYCONFIRMNO,
    c6.Vin,
    c6.LICENSENO,
    c6.ENGINENO,
    sys.extracttime,
   c5.CONFIRMSEQUENCENO
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys,
		(select c4.CONFIRMSEQUENCENO from CACMAIN c3,CACMain_NCP c4 
		where c3.CONFIRMDATE > '${_LASTDATE}' 
		and c3.UnderwriteReason != '3' 
		and c3.CONFIRMSEQUENCENO = c4.CONFIRMSEQUENCENO
		and c4.Flag != '1'
			union
		select c1.CONFIRMSEQUENCENO from CAPHEAD c1 left join CACMain_NCP c2 on c1.CONFIRMSEQUENCENO = c2.CONFIRMSEQUENCENO 
		where c1.CONFIRMDATE > '${_LASTDATE}')c7,
	CACMAIN c5 left join CACVEHICLE c6 on c5.CONFIRMSEQUENCENO = c6.CONFIRMSEQUENCENO
			where c5.CONFIRMSEQUENCENO = c7.CONFIRMSEQUENCENO 
)c10
on a.CONFIRMSEQUENCENO = c10.CONFIRMSEQUENCENO
when MATCHed then update set a.PolicyNo = c10.POLICYNO,
					a.CompanyCode = c10.CompanyCode ,
					a.CityCode = c10.CityCode ,
					a.EffectiveDate =c10.EffectiveDate ,
					a.EXPIREDATE = c10.EXPIREDATE,
					a.STOPTRAVELTYPE = c10.STOPTRAVELTYPE,
					a.STOPTRASTRATDATE =c10.STOPTRASTRATDATE,
					a.StopTravelEndDate = c10.StopTravelEndDate,
					a.BizStatus= c10.BizStatus,
					a.LASTPOLICYCONFIRMNO = c10.LASTPOLICYCONFIRMNO,
					a.Vin = c10.Vin, 
					a.LicenseNo = c10.LICENSENO,
					a.EngineNo = c10.ENGINENO,
					a.UpdateTime = c10.extracttime
"
#���²�������
echo "��Ͷ������"
db2 "
insert into CACMain_NCP(ConfirmSequenceNo, POLICYNO, COMPANYCODE, CityCode, EffectiveDate, ExpireDate,StopTravelType,StopTraStratDate,StopTravelEndDate,BizStatus,LastPolicyConfirmNo, Vin, LicenseNo, EngineNo,FLAG, InputDate)
	select 
		a.ConfirmSequenceNo,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.EFFECTIVEDATE,
		a.EXPIREDATE,
		a.STOPTRAVELTYPE,
		a.STOPTRASTRATDATE,
		a.StopTravelEndDate,
		a.BizStatus,
		a.LastPolicyConfirmNo,
		b.Vin,
		b.LicenseNo,
		b.EngineNo,
		'0',
		sys.extracttime
	from (select current timestamp as extracttime from sysibm.sysdummy1) sys,
	CACMain a 
	inner join CACVehicle b on a.ConfirmSequenceNo = b.ConfirmSequenceNo
	where a.ConfirmDate  > '${_LASTDATE}'
		and a.ValidStatus ='1'
		and a.UnderwriteReason != '3'
		and a.CONFIRMSEQUENCENO not in (select ConfirmSequenceNo from CACMain_NCP) 	
"
################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

