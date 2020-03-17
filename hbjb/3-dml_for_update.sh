#!/usr/bin/env bash



main()
{
echo "开始时间"
date
#########################################################
#功能：更新数据
##########################################################

echo "请输入数据库名 ->"|tr -d "\012"
  #  read _DBNAME
 _DBNAME=iaca51db 
	
echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
 #   read _DBUSER
_DBUSER=intiaci
 
echo ""    	
echo "请输入数据库用户密码 ->"|tr -d "\012"
 #   read _PWD
 _PWD=password
	
echo ""    
echo "请输入schema名 ->"|tr -d "\012"
  #  read _SCHEMA
  _SCHEMA=instiaci

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

	

################以上部分不允许修改        ###############
_AREACODE=`db2 -x  "select PARAMETERVALUE from IADsysConfig where PARAMETERCODE = 'AreaCode'"`
_AREACODE=`echo ${_AREACODE} | tr -d ' '`
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数

## insert into INSTIACI.CADSYSCONFIG (PARAMETERCODE, PARAMETERTYPE, COMPANYCODE, PARAMETERVALUE, AREACODE, PARAMETERDESC, REMARK, VALIDSTATUS) values ('ClosingDate', '00', 'ALL', '2020-03-38', '510000', '疫情截止日期', '', '1');

## 获取疫情截止日期
_CLOSINGDAT=`db2 -x "select parametervalue from cadsysconfig where cadsysconfig.PARAMETERCODE = 'ClosingDate'"`

###把有效的投保确认码删选出来

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



##本次保单的投保确认码CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct PolicyConfirmNo from CACMain_B"`

echo ${PolicyConfirmNo}
echo "${PolicyConfirmNo}"
echo "本次保单的续保保单"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($PolicyConfirmNo)
#变成原来的分隔符
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


	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

