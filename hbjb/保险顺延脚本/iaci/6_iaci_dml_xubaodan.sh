#!/usr/bin/env bash



main()
{
echo "开始时间"
date
#########################################################
#功能：创建表
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
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数
################以下脚本，根据实际情况修改###############


echo ""
echo "请输入保单归属地， （范例， 假设是武汉 ：420100） ->"|tr -d "\012"
	read _CITYCODE
#_CITYCODE=420100

################请按照需求书写sql####################


##本次保单的投保确认码IACMain_B
PolicyConfirmNo=`db2 -x  "	select 
								distinct POLICYCONFIRMNO 
							from IACMain_NCPB  
							where reason = '' 
								and flag = '' 
								and  citycode = '${_CITYCODE}'"`

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





#######查找续保单的续保单。。。。。。
i=1;
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "----------------------------------------------------续保单-------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo "---------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
while true
do	
		
		###查询第几层续保单 ,假设多个地区并行实行 并且公用一套表会有问题。

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
	echo "第${i}层续保单${XuPolicyConfirmNo}"
	echo "-----------------------------------------------------------------------"
	
	if [  -z "$XuPolicyConfirmNo" ]
    then
		break;
    fi
	
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

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/6-dml_${times}.log

