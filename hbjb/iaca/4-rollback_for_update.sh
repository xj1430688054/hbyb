#!/usr/bin/env bash


main()
{
echo "开始时间"
date
#########################################################
#功能：回退操作
##########################################################

echo "请输入数据库名 ->"|tr -d "\012"
  #  read _DBNAME
 _DBNAME=iaca51db 
	
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
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数

#db2 "drop table CACMain_B"
#db2 "drop table CACMain_X"
#db2 "drop table CAPostponeMain"
#db2 "drop table CACCoverage_B"
#db2 "drop table CACCoverage_X"

db2 "drop table CACMain_A"
db2 "drop table CACMain_B"
db2 "drop table CACMain_X"
db2 "drop table CAPostponeMain"
db2 "drop table CAPostponeCoverage"



#db2 "drop table CACCoverage_X"

db2 "drop index  IDX_CACMain_A _01"
db2 "drop index IDX_CACMain_B _01"
db2 "drop index IDX_CACMain_X _01"
db2 "drop index IDX_CACMain_X _02"
db2 "drop index IDX_CAPostponeMain _01 "
db2 "drop index IDX_CAPostponeCoverage _01 "






################请按照需求书写rollback 的相关sql####################


db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4-rollback_${times}.log

