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
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数
################以下脚本，根据实际情况修改###############
echo "请输入表空间 ->"|tr -d "\012"
#	read _TBSDATA
_TBSDATA=tbsdata

echo ""
echo "请输入索引空间 ->"|tr -d "\012"
#	read _TBSINDEX
_TBSINDEX=tbsindex

################请按照需求书写sql####################

echo "==============================================="
echo "创建CACMain_A表"
echo "==============================================="
db2 "create table CACMain_A
(
	SerialNo INTEGER  NOT NULL,
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CityCode          VARCHAR(10) ,
   companycode VARCHAR(8) ,
   StartDate  TIMESTAMP ,
     EndDate        TIMESTAMP ,
    Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   Reason VARCHAR(1),
   InputDate TIMESTAMP 
   CONSTRAINT P_CACMain_A PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "创建CACMain_B表"
echo "==============================================="
db2 "create table CACMain_B
(
	SerialNo INTEGER  NOT NULL,
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CityCode          VARCHAR(10) ,
   companycode VARCHAR(8) ,
   EffectiveDate TIMESTAMP ,
     ExpireDate       TIMESTAMP ,
    Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   CONSTRAINT P_CACMain_B PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "创建CACMain_X表"
echo "==============================================="
db2 "create table CACMain_X
(
	SerialNo INTEGER  NOT NULL,
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CityCode          VARCHAR(10) ,
   EffectiveDate TIMESTAMP ,
   ExpireDate        TIMESTAMP ,
   companycode VARCHAR(8) ,
   LastPoliConfirmNo VARCHAR(50),
    Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   CONSTRAINT P_CACMain_X PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "创建CAPostponeMain表"
echo "==============================================="
db2 "create table CAPostponeMain
(
	SerialNo INTEGER  NOT NULL,
   PostponeConfirmSequenceNo VARCHAR(50) not null,
   PostponePolicyNo VARCHAR(50),
   PostponeEffectiveDate TIMESTAMP,
   companycode VARCHAR(8) ,
   PostponeExpireDate TIMESTAMP,
   AfterPostponeExpireDate TIMESTAMP,
   PostponeDay INTEGER ,
   ConfirmSequenceNo VARCHAR(50) ,
   PolicyNo      VARCHAR(50) ,
   ExpireDate        TIMESTAMP ,
   CityCode          VARCHAR(10) ,
   Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   CONSTRAINT P_CAPostponeMain PRIMARY KEY (INTEGER)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="



echo "==============================================="
echo "创建CAPostponeCoverage表"
echo "==============================================="
db2 "create table CAPostponeCoverage
(
	SerialNo INTEGER  NOT NULL,
   ConfirmSequenceNo VARCHAR(50) not null,
   companycode VARCHAR(8) ,
   CoverageCode VARCHAR(10),
   ExpireDate        TIMESTAMP ,
   EffectiveDate  TIMESTAMP,
   AfterExpireDate TIMESTAMP,
   BusinessType              VARCHAR(1),
   UpdateTime TIMESTAMP,
   InputDate TIMESTAMP ,
   ValidStatus VARCHAR(1),
   CONSTRAINT P_CAPostponeCoverage PRIMARY KEY (INTEGER)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="











db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

