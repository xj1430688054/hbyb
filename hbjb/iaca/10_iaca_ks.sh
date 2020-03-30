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
echo "请输入跨省续保单数据文件名称（例: xubao.txt  输入xubao） ->"|tr -d "\012"
	read _XUBAOFILENAME
#_XUBAOFILENAME=xubao

echo ""
echo "请输入跨省续理赔数据文件名称 (例：lipei.txt  输入lipei)->"|tr -d "\012"
	read _CLAIMFILENAME
#_CLAIMFILENAME=lipei

################请按照需求书写sql####################
##当前路劲
DATAPATH=$(cd $(dirname $0); pwd)


echo "清空表"
db2 "delete from KSCMain_NCP"
db2 "delete from KSClaim_NCP"


echo "导入跨省续保数据到临时表..." 
date   
echo "从"${_XUBAOFILENAME}"中提取到PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${_XUBAOFILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${_XUBAOFILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18) 
     MESSAGES  ${_XUBAOFILENAME}.log insert INTO KSCMain_NCP"
echo "导入跨省续保数据结束"
date



echo "导入跨省；理赔数据到临时表..."    
date
echo "从"${_XUBAOFILENAME}"中提取到PRECISIONSCORE......"
db2 "LOAD CLIENT FROM  ${_CLAIMFILENAME}.txt  OF DEL MODIFIED BY DUMPFILE=${DATAPATH}${_CLAIMFILENAME}.txt NOCHARDEL CODEPAGE=1208 COLDEL| METHOD  P (1,2,3,4,5,6,7,8,9,10,11,12,13,14) 
     MESSAGES  ${_CLAIMFILENAME}.log insert INTO KSClaim_NCP"
echo "导入跨省续保数据结束"
date



db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

