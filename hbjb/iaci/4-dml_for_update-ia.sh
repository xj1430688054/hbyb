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
#_DBNAME=iaci42db	
	
	
echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
    read _DBUSER
#_DBUSER=instiaci
	
echo ""    	
echo "请输入数据库用户密码 ->"|tr -d "\012"
    read _PWD
#_PWD=password
	
echo ""    
echo "请输入schema名 ->"|tr -d "\012"
    read _SCHEMA
#_SCHEMA=instiaci
	
db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}


################以上部分不允许修改        ###############
_AREACODE=`db2 -x  "select PARAMETERVALUE from IADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数
_CLOSINGDAT=`db2 -x "select parametervalue from iadsysconfig where PARAMETERCODE = 'ClosingDate'"`
_CLOSINGDAT=`echo ${_CLOSINGDAT} | tr -d ' '`


echo ""
echo "请输入上次提数时间 ->"| tr -d "\012"
#	read _LASTDATE
_LASTDATE='2020-02-02'
#PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain c1，IAPHEAD c2,IACMain_NCP c3 where c1.PolicyConfirmNo = c2.PolicyConfirmNo and c2.PolicyConfirmNo = c3.PolicyConfirmNo and c1.InputDate > ${_LASTDATE}`
#更新基础保单数据
echo "本次保单"
db2 "MERGE
into IACMain_NCP a using (
select 
    c5.PolicyNo ,
    c5.COMPANYCODE,
    c5.CITYCODE,
    c5.StartDate,
    case when c7.Flag = '2' 
    then c7.EndDate
    else c5.EndDate
    end as EndDate,
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
		(select c4.PolicyConfirmNo,c3.ENDDATE,Flag  from IACMAIN c3,IACMain_NCP c4 
		where c3.InputDate  > '${_LASTDATE}' 
		and c3.UnderwriteReason  != '3' 
		and c3.PolicyConfirmNo   = c4.PolicyConfirmNo  
		and c4.Flag = ''
			union
		select c1.PolicyConfirmNo  ,c1.ValidDate ,c1.EndorseType from IAPHead c1, IACMain_NCP c2 where c1.PolicyConfirmNo   = c2.POLICYCONFIRMNO  
		and c1.CONFIRMDATE > '${_LASTDATE}' )c7,
	IACMAIN c5 left join IATCItemCar c6 on c5.PolicyConfirmNo  = c6.PolicyConfirmNo 
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
#更新投保数据
db2 "
insert into IACMain_NCP(PolicyConfirmNo, PolicyNo, companycode, CityCode, STARTDATE, ENDDATE, FrameNo, LicenseNo, EngineNo, Flag,InputDate)
select 
		a.PolicyConfirmNo ,
		a.PolicyNo,
		a.companycode,
		a.CityCode,
		a.STARTDATE,
		a.ENDDATE,
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


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

