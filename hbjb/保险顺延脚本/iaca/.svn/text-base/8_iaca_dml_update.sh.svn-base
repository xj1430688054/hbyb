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

echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
    read _DBUSER
	
echo ""    	
echo "请输入数据库用户密码 ->"|tr -d "\012"
    read _PWD
	
echo ""    
echo "请输入schema名 ->"|tr -d "\012"
    read _SCHEMA

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}


################以上部分不允许修改        ###############
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数


#更新险种信息表
#db2 "merge into CACCoverage a using 
#			(select ConfirmSequenceNo,CoverageCode,AfterExpireDate from CACCoverage_NCPPostpone) b 
#				on (a.ConfirmSequenceNo = b.ConfirmSequenceNo 
#				and a.CoverageCode = b.CoverageCode)  
#				when MATCHED then update  set ExpireDate = b.AfterExpireDate
#				else ignore
#"
db2 "merge into CACCoverage a using 
			(select c1.ConfirmSequenceNo,c1.CoverageCode,c1.AfterExpireDate from 
			CACCoverage_NCPPostpone  c1 inner join CACMain_NCPPostpone c2 
			on c1.ConfirmSequenceNo = c2.ConfirmSequenceNo where c2.Flag != '1') b 
				on (a.ConfirmSequenceNo = b.ConfirmSequenceNo 
				and a.CoverageCode = b.CoverageCode)  
				when MATCHED then update  set ExpireDate = b.AfterExpireDate
				else ignore
"
#
##更新承保表数据
#db2 "merge into CACMAIN a 
#		using  (select ConfirmSequenceNo  from CACCoverage_NCPPostpone where CACCoverage_NCPPostpone.Flag != '1') b 
#		on a.ConfirmSequenceNo = b.ConfirmSequenceNo 
#		when matched 
#			then update set ExpireDate = b.AfterExpireDate ,a.UnderwriteReason = '3'
#			else ignore
#"

#更新承保表数据
db2 "merge into CACMAIN a 
		using  (select ConfirmSequenceNo , AfterExpireDate from CACMain_NCPPostpone where CACMain_NCPPostpone.Flag != '1') b 
		on a.ConfirmSequenceNo = b.ConfirmSequenceNo 
		when matched 
			then update set ExpireDate = b.AfterExpireDate ,a.UnderwriteReason = '3'
			else ignore
"


#更新基础数据表中续保单的状态
#续保保单投保确认码	
X_PolicyConfirmNo=`db2 -x  "select c1.CONFIRMSEQUENCENO from CACMain_NCP c1 ,CACMain_NCPX c2 where c1.CONFIRMSEQUENCENO = c2.LASTPOLICYCONFIRMNO and c1.Flag != '1' "`
echo "${X_PolicyConfirmNo}"
echo "投保确认码"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($X_PolicyConfirmNo)
#变成原来的分隔符
IFS="2020/3/16"
#更新基础数据表中续保单信息
for NCPX_PolicyConfirmNo in ${array[@]}
do
echo "更新基础数据表中续保单信息 ：投保确认码为====${X_PolicyConfirmNo}"
db2 "update CACMain_NCP set  Flag = '1' where  ConfirmSequenceNo = '${X_PolicyConfirmNo}'"
 
done	

#获取投保确认码
CONFIRMSEQUENCENO=`db2 -x  "select CONFIRMSEQUENCENO from CACMain_NCPPostpone where LastPolicyConfirmNo = '' and CACMain_NCPPostpone.Flag != '1'
union select LastPolicyConfirmNo as  CONFIRMSEQUENCENO from CACMain_NCPPostpone where LastPolicyConfirmNo != '' and CACMain_NCPPostpone.Flag != '1'"`

echo "${CONFIRMSEQUENCENO}"
echo "投保确认码"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($CONFIRMSEQUENCENO)
#变成原来的分隔符
IFS="2020/3/16"
#更新基础数据表中本保单信息
for NCP_CONFIRMSEQUENCENO in ${array[@]}
do
echo "更新基础数据表中本报单、顺延保单、本报单信息表  投保确认码为：${NCP_CONFIRMSEQUENCENO}"
db2 "update CACMain_NCP set  Flag = '1' where   CONFIRMSEQUENCENO = '${NCP_CONFIRMSEQUENCENO}'"
#更新顺延保单表数据
db2 "update CACMain_NCPPostpone set  Flag = '1' where   CONFIRMSEQUENCENO = '${NCP_CONFIRMSEQUENCENO}'"
#更新本报单数据
db2 "update CACMain_NCPB set Flag = '1' where   CONFIRMSEQUENCENO = '${NCP_CONFIRMSEQUENCENO}' "
done	




################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/8_iaca_dml_update_${times}.log

