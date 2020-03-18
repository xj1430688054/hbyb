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
echo "创建CACMain_A-疫情期全量本保单信息表"
echo "==============================================="
db2 "create table CACMain_A
(
SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CompanyCode VARCHAR(8) ,
   CityCode          VARCHAR(10) ,
   EffectiveDate   TIMESTAMP ,
    ExpireDate         TIMESTAMP ,
   Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   Reason VARCHAR(1),
   InputDate TIMESTAMP ,
   CONSTRAINT P_CACMain_A PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "创建CACMain_B-本保单信息表"
echo "==============================================="
db2 "create table CACMain_B
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CompanyCode VARCHAR(8) ,
   CityCode          VARCHAR(10) ,
   EffectiveDate TIMESTAMP ,
     ExpireDate       TIMESTAMP ,
    Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   InputDate TIMESTAMP ,
   CONSTRAINT P_CACMain_B PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "创建CACMain_X-续保保单信息表"
echo "==============================================="
db2 "create table CACMain_X
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CompanyCode VARCHAR(8) ,
   CityCode          VARCHAR(10) ,
   EffectiveDate TIMESTAMP ,
   ExpireDate        TIMESTAMP ,
   LastPoliConfirmNo VARCHAR(50),
    Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
    InputDate TIMESTAMP ,，
   CONSTRAINT P_CACMain_X PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "创建CAPostponeMain-顺延保单信息表"
echo "==============================================="
db2 "create table CAPostponeMain
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) not null,
   PolicyNo VARCHAR(50),
   EffectiveDate TIMESTAMP,
   ExpireDate TIMESTAMP,
   AfterExpireDate TIMESTAMP,
   PostponeStartDate TIMESTAMP,
	PostponeEndDate TIMESTAMP,
	PostponeDay INTEGER,
   CompanyCode VARCHAR(8) ,
   CityCode          VARCHAR(10) ,
   LastPolicyConfirmNo   VARCHAR(50),
   Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   InputDate    TIMESTAMP,
	UpdateTime  TIMESTAMP,
	ValidStatus VARCHAR(1),

   CONSTRAINT P_CAPostponeMain PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="



echo "==============================================="
echo "创建CAPostponeCoverage-顺延险种信息表"
echo "==============================================="
db2 "create table CAPostponeCoverage
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) not null,
   CompanyCode VARCHAR(8) ,
   CoverageCode VARCHAR(10),
    EffectiveDate  TIMESTAMP,
   ExpireDate        TIMESTAMP ,
   AfterExpireDate TIMESTAMP,
   BusinessType              VARCHAR(1),
      InputDate TIMESTAMP ,
   UpdateTime TIMESTAMP,
   ValidStatus VARCHAR(1),
   CONSTRAINT P_CAPostponeCoverage PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="






echo "创建索引"
db2 "create index IDX_CACMain_A _01 on CACMain_A (
   ConfirmSequenceNo           ASC
)
"db2 "create index IDX_CACMain_B _01 on CACMain_B (
   ConfirmSequenceNo           ASC
)
"
db2 "create index IDX_CACMain_X _01 on CACMain_X (
   ConfirmSequenceNo           ASC
)
"

db2 "create index IDX_CACMain_X _02 on CACMain_X (
   LastPoliConfirmNo           ASC
)
"

db2 "create index IDX_CAPostponeMain _01 on CAPostponeMain (
   ConfirmSequenceNo           ASC
)
"
db2 "create index IDX_CAPostponeCoverage _01 on CAPostponeCoverage (
   ConfirmSequenceNo           ASC
)
"






db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

