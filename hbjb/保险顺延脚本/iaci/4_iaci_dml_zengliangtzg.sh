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



echo ""
echo "�������ϴ�����ʱ�� ->"| tr -d "\012"
	read _LASTDATE
#_LASTDATE='2020-02-02'
#PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain c1��IAPHEAD c2,IACMain_NCP c3 where c1.PolicyConfirmNo = c2.PolicyConfirmNo and c2.PolicyConfirmNo = c3.PolicyConfirmNo and c1.InputDate > ${_LASTDATE}`
#���»�����������
echo "������������"
db2 "MERGE
into IACMain_NCP a using (
select 
    c5.PolicyNo ,
    c5.COMPANYCODE,
    c5.CITYCODE,
    c5.StartDate,
    c5.EndDate,
    c5.StopTravelType,
    c5.StopTraStartDate,
    c5.StopTravelEndDate,
    c5.BIZSTATUS,
    c5.LastPoliConfirmNo,
    c6.FrameNo,
    c6.LICENSENO,
    c6.ENGINENO,
    sys.extracttime,
    c5.PolicyConfirmNo 
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys,
		(select c4.PolicyConfirmNo from IACMAIN c3,IACMain_NCP c4 
		where c3.InputDate  > '${_LASTDATE}' 
		and c3.UnderwriteReason  != '3' 
		and c3.PolicyConfirmNo   = c4.PolicyConfirmNo  
		and c4.Flag = ''
		and c3.EndorseTimes > 0
			union
		select c1.PolicyConfirmNo from IAPHead c1, IACMain_NCP c2 where c1.PolicyConfirmNo   = c2.POLICYCONFIRMNO  
		and c1.CONFIRMDATE > '${_LASTDATE}' and c1.EndorseType != '2' and c2.Flag != '1')c7,
	IACMAIN c5 inner join IATCItemCar c6 on c5.PolicyConfirmNo  = c6.PolicyConfirmNo 
			where c5.PolicyConfirmNo   = c7.PolicyConfirmNo
)c10 on a.PolicyConfirmNo  = c10.PolicyConfirmNo
	when MATCHed then update set 
					a.PolicyNo = c10.PolicyNo,
					a.CompanyCode  = c10.CompanyCode  ,
					a.CityCode = c10.CityCode ,
					a.StartDate  =c10.StartDate  ,
					a.EndDate  = c10.EndDate ,
					a.StopTravelType = c10.StopTravelType,
					a.StopTraStartDate =c10.StopTraStartDate,
					a.StopTravelEndDate = c10.StopTravelEndDate,
					a.BizStatus= c10.BizStatus,
					a.LastPoliConfirmNo = c10.LastPoliConfirmNo,
					a.FrameNo  = c10.FrameNo , 
					a.LicenseNo  = c10.LicenseNo ,
					a.EngineNo  = c10.EngineNo ,
					a.UpdateTime = c10.extracttime
"

#���������˱�����
echo "���������˱�����"
db2 "MERGE
into IACMain_NCP a using (
select 
    c5.PolicyNo ,
    c5.COMPANYCODE,
    c5.CITYCODE,
    c5.StartDate,  
    c7.VALIDDATE,
    c5.StopTravelType,
    c5.StopTraStartDate,
    c5.StopTravelEndDate,
    c5.BIZSTATUS,
    c5.LastPoliConfirmNo,
    c6.FrameNo,
    c6.LICENSENO,
    c6.ENGINENO,
    sys.extracttime,
   c5.PolicyConfirmNo 
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys,		
		(select c1.PolicyConfirmNo,c1.VALIDDATE from IAPHead c1, IACMain_NCP c2 where c1.PolicyConfirmNo   = c2.POLICYCONFIRMNO  
		and c1.CONFIRMDATE > '${_LASTDATE}' and c1.EndorseType = '2' and c2.Flag != '1')c7,
	IACMAIN c5 inner join IATCItemCar c6 on c5.PolicyConfirmNo  = c6.PolicyConfirmNo 
			where c5.PolicyConfirmNo   = c7.PolicyConfirmNo
)c10 on a.PolicyConfirmNo  = c10.PolicyConfirmNo
	when MATCHed then update set 
					a.PolicyNo = c10.PolicyNo,
					a.CompanyCode  = c10.CompanyCode  ,
					a.CityCode = c10.CityCode ,
					a.StartDate  =c10.StartDate  ,
					a.EndDate  = c10.VALIDDATE ,
					a.StopTravelType = c10.StopTravelType,
					a.StopTraStartDate =c10.StopTraStartDate,
					a.StopTravelEndDate = c10.StopTravelEndDate,
					a.BizStatus= c10.BizStatus,
					a.LastPoliConfirmNo = c10.LastPoliConfirmNo,
					a.FrameNo  = c10.FrameNo , 
					a.LicenseNo  = c10.LicenseNo ,
					a.EngineNo  = c10.EngineNo ,
					a.UpdateTime = c10.extracttime
"


#����Ͷ������
echo "����Ͷ������"
db2 "
insert into IACMain_NCP(PolicyConfirmNo, PolicyNo, companycode, CityCode,STARTDATE, ENDDATE, StopTravelType,StopTraStartDate,StopTravelEndDate,BizStatus, LastPoliConfirmNo,FrameNo, LicenseNo, EngineNo, Flag,InputDate)
select 
		a.PolicyConfirmNo,
		a.PolicyNo,
		a.companycode,
		a.CityCode,
		a.STARTDATE,
		a.ENDDATE,
		a.StopTravelType,
		a.StopTraStartDate,
		a.StopTravelEndDate,
		a.BizStatus,
		a.LastPoliConfirmNo,
		b.FrameNo,
		b.LicenseNo,
		b.EngineNo,
		'',
		sys.extracttime
	from IACMain a 
	inner join IATCItemCar b on a.PolicyConfirmNo = b.PolicyConfirmNo,
	(select current timestamp as extracttime from sysibm.sysdummy1) sys
	where a.InputDate >= '${_LASTDATE}'
		and a.ValidStatus ='1'
		and a.UnderwriteReason  != '3' 
		and a.PolicyConfirmNo not in (select PolicyConfirmNo from IACMain_NCP)
"
#���´��
echo "���´��"
db2 "
MERGE into IACMain_NCP c using (
        select c1.POLICYCONFIRMNO from 
         IACMAIN c1 INNER JOIN IACMAIN c2 ON c2.POLICYCONFIRMNO = c1.LASTPOLICONFIRMNO
          where c1.INPUTDATE > '${_LASTDATE}' and c2.UNDERWRITEREASON = '1'
        ) d 
        on c.POLICYCONFIRMNO = d.POLICYCONFIRMNO
when MATCHed then 
update SET c.Flag = '1'

"

################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4_iaci_dml_zengliang_${times}.log

