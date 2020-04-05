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
#_DBNAME=iaca42db	
	
	
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
echo "请输入保险公司理赔数据文件名称（txt 格式 例: test.txt  输入test） ->"|tr -d "\012"
	read FILENAME
	
echo "请输入保险公司不延保保单名称数据(txt 格式  例： noyanbao)"
	read NOYANAO

echo "请输入保险公司准备的各种数据的所在路劲（ 例： /home/instiaci/xj/hb/iaci ） ->"|tr -d "\012"
	read DATAPATH



################请按照需求书写sql####################
##当前路劲
#DATAPATH=$(cd $(dirname $0); pwd)

echo "导入数据到临时表..."    
echo "从"${FILENAME}".txt中提取到PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${FILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${FILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11) 
     MESSAGES  ${FILENAME}.log insert INTO CAClaimPolicy_NCP"

echo "修改提数时间为空的更新为当前时间"
db2 "update CAClaimPolicy_NCP set INPUTDATE = TO_CHAR(current timestamp,'YYYY-MM-DD HH24:MI:SS')  where INPUTDATE is null"
	 
	 
echo "导入数据到临时表..."    
echo "从"${NOYANAO}".txt中提取到PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${NOYANAO}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${NOYANAO}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9) 
     MESSAGES  ${NOYANAO}.log insert INTO CAPolicyNoPost_NCP"

echo "修改提数时间为空的更新为当前时间"	 
db2 "update CAPolicyNoPost_NCP set INPUTDATE = TO_CHAR(current timestamp,'YYYY-MM-DD HH24:MI:SS')  where INPUTDATE is null"
	 

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2_iaca_dml_lipei_${times}.log

