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


#更新承保表数据
db2 "merge into IACMAIN a 
		using  (select POLICYCONFIRMNO,EndDate  from IACMain_NCPPostpone where IACMain_NCPPostpone.Flag != '1') b 
		on a.POLICYCONFIRMNO = b.POLICYCONFIRMNO 
		when matched 
			then update set  a.ENDDATE= b.EndDate ,a.UnderwriteReason  = '3'
			else ignore
"

			

#更新基础数据表中续保单的状态
#获取续保保单投保确认码	
X_PolicyConfirmNo=`db2 -x  "select c1.POLICYCONFIRMNO from IACMain_NCP c1, IACMain_NCPX c2 where c1.POLICYCONFIRMNO = c2.LastPoliConfirmNo"`
echo "${X_PolicyConfirmNo}"
echo "投保确认码"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($X_PolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"
#更新基础数据表中本保单信息
for NCPX_PolicyConfirmNo in ${array[@]}
do
db2 "update IACMain_NCP set  Flag = '1' where POLICYCONFIRMNO = '${X_PolicyConfirmNo}'"
 
done	

#获取本报单的投保确认码
PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPPostpone 
	where LastPoliConfirmNo = '' and Flag != '1' 
	union 
	select LastPoliConfirmNo as  PolicyConfirmNo from IACMain_NCPPostpone 
	where LastPoliConfirmNo != '' and Flag != '1'"`


echo "投保确认码"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($PolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"
#更新基础数据表中本保单信息
for NCP_PolicyConfirmNo in ${array[@]}
do
db2 "update IACMain_NCP set  Flag = '1' where   PolicyConfirmNo = '${NCP_PolicyConfirmNo}'"
##更新本保单信息
db2 "update IACMain_NCPB set Flag = '1' where   PolicyConfirmNo = '${NCP_PolicyConfirmNo}'"
#更新顺延保单表数据
db2 "update IACMain_NCPPostpone set  Flag = '1' where   PolicyConfirmNo = '${NCP_PolicyConfirmNo}'"
done	



################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/3-dml_${times}.log

