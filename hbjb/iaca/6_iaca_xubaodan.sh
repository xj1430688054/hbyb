#!/usr/bin/env bash



main()
{
echo "开始时间"
date
#########################################################
#功能：创建表
##########################################################

echo "请输入数据库名 ->"|tr -d "\012"
  #  read _DBNAME
_DBNAME=iaca42db	
	
	
echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
 #   read _DBUSER
_DBUSER=instiaci
	
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
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数
################以下脚本，根据实际情况修改###############
echo ""
echo "请输入保单归属地， （范例， 假设是武汉 ：420101） ->"|tr -d "\012"
#	read _ROWS
_CITYCODE=420100


################请按照需求书写sql####################

##本次保单的投保确认码CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct CONFIRMSEQUENCENO from CACMain_NCPB  where reason = ''and  Flag = '' and flag = '' and citycode = '${_CITYCODE}'"`

echo "${PolicyConfirmNo}"
echo "本次保单的续保保单"
##保存旧的分隔符
OLD_IFS="$IFS"
##分隔符设置成空格
IFS=" "
array=($PolicyConfirmNo)
##变成原来的分隔符
IFS="$OLD_IFS"



####遍历本保单，查询虚报单
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
echo "---------------------续保单的续保单--------------------------------------"
echo "---------------------续保单的续保单-------------------------------------------"
echo "------------------------------------------------------------------------------"
#######查找续保单的续保单。。。。。。
i=1;

while true
do	
		
		###查询第几层续保单 ,需要再条件种加入第几层
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
	
	echo "第${i}层续保单${XuPolicyConfirmNo}"
	echo "-----------------------------------------------------------------------"
	
	##保存旧的分隔符
	OLD_IFS="$IFS"
	##分隔符设置成空格
	IFS=" "
	arrays=($XuPolicyConfirmNo)
	##变成原来的分隔符
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

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

