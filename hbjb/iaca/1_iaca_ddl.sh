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
echo "请输入表空间 ->"|tr -d "\012"
	read _TBSDATA
#_TBSDATA=tbsdata

echo ""
echo "请输入索引空间 ->"|tr -d "\012"
	read _TBSINDEX
#_TBSINDEX=tbsindex

################请按照需求书写sql####################

echo "==============================================="
echo "创建CACMain_NCP-疫情期全量本保单信息表"
echo "==============================================="
db2 "create table CACMain_NCP
(
	ConfirmSequenceNo VARCHAR(50) NOT NULL,
	PolicyNo      VARCHAR(50) ,
	CompanyCode VARCHAR(8) ,
	CityCode          VARCHAR(10) ,
	EffectiveDate   TIMESTAMP ,
	ExpireDate         TIMESTAMP ,
	StopTravelType	VARCHAR(1),
	StopTraStratDate	TIMESTAMP ,
	StopTravelEndDate	TIMESTAMP ,
	BizStatus	VARCHAR(1),
	LastPolicyConfirmNo	VARCHAR(50),
	Vin 	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo	VARCHAR(50),
	Flag	VARCHAR(1),
	InputDate	TIMESTAMP ,
	UpdateTime	TIMESTAMP ,
   CONSTRAINT P_CACMain_NCP PRIMARY KEY (ConfirmSequenceNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="




echo "==============================================="
echo "创建CACMain_NCP-LastPolicyConfirmNo索引"
echo "==============================================="
db2 "create index IDX_CACMain_NCP_02 on CACMain_NCP (
   LastPolicyConfirmNo           ASC
)"
echo "==============================================="







echo "==============================================="
echo "创建CACMain_NCPB-疫情期本保单信息表"
echo "==============================================="
db2 "create table CACMain_NCPB
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
   Reason varchar(1),
   desc varchar(2000),
   Flag	VARCHAR(1),
   InputDate TIMESTAMP ,
   CONSTRAINT P_CACMain_NCPB PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "创建CACMain_NCPB-ConfirmSequenceNo索引"
echo "==============================================="
db2 "create index IDX_CACMain_NCPB_01 on CACMain_NCPB (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "创建CACMain_NCPX-疫情期续保保单信息表"
echo "==============================================="
db2 "create table CACMain_NCPX
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) NOT NULL,
   PolicyNo      VARCHAR(50) ,
   CompanyCode VARCHAR(8) ,
   CityCode          VARCHAR(10) ,
   EffectiveDate TIMESTAMP ,
   ExpireDate        TIMESTAMP ,
   LastPolicyConfirmNo VARCHAR(50),
   LastCityCode varchar(10),
   Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   level INTEGER  ,
   Flag varchar(1) ,
   InputDate TIMESTAMP ,
   CONSTRAINT P_CACMain_NCPX PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "创建CACMain_NCPX-ConfirmSequenceNo索引"
echo "==============================================="
db2 "create index IDX_CACMain_NCPX_01 on CACMain_NCPX (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="

echo "==============================================="
echo "创建CACMain_NCPX-LastPoliConfirmNo索引"
echo "==============================================="
db2 "create index IDX_CACMain_NCPX_02 on CACMain_NCPX (
   LastPolicyConfirmNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "创建CACMain_NCPPostpone-疫情期顺延保险信息表"
echo "==============================================="
db2 "create table CACMain_NCPPostpone
(
   SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
   ConfirmSequenceNo VARCHAR(50) not null,
   PolicyNo VARCHAR(50),
   CompanyCode VARCHAR(8) ,
   EffectiveDate TIMESTAMP,
   ExpireDate TIMESTAMP,
   AfterExpireDate   TIMESTAMP,
   NCPStartDate TIMESTAMP,
   NCPEndDate TIMESTAMP,
   NCPValidDate INTEGER,
   PostponeDay  INTEGER,
   CityCode          VARCHAR(10) ,
   LastPolicyConfirmNo   VARCHAR(50),
   Vin   VARCHAR(50),
   LicenseNo        VARCHAR(15),
   EngineNo          VARCHAR(50),
   BusinessType              VARCHAR(1),
   InputDate    TIMESTAMP,
   UpdateTime  TIMESTAMP,
   Flag varchar(1),
   ValidStatus VARCHAR(1),
   CONSTRAINT P_CACMain_NCPPostpone PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "创建CACMain_NCPPostpone-ConfirmSequenceNo索引"
echo "==============================================="
db2 "create index IDX_CACMain_NCPPostpone_01 on CACMain_NCPPostpone (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="

echo "==============================================="
echo "创建CACMain_NCPPostpone-LastPolicyConfirmNo索引"
echo "==============================================="
db2 "create index CACMain_NCPPostpone_02 on CACMain_NCPPostpone (
   LastPolicyConfirmNo           ASC
)"
echo "==============================================="



echo "==============================================="
echo "创建CACCoverage_NCPPostpone-疫情期顺延险种信息表"
echo "==============================================="
db2 "create table CACCoverage_NCPPostpone
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
	ConfirmSequenceNo VARCHAR(50) not null,
	CompanyCode VARCHAR(8) ,
	CoverageCode VARCHAR(10),
    EffectiveDate  TIMESTAMP,
	ExpireDate        TIMESTAMP ,
	AfterExpireDate TIMESTAMP,
    InputDate TIMESTAMP ,
	UpdateTime TIMESTAMP,
	ValidStatus VARCHAR(1),
   CONSTRAINT P_CACCoverage_NCPPostpone PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "创建CACCoverage_NCPPostpone-ConfirmSequenceNo索引"
echo "==============================================="
db2 "create index IDX_CACCoverage_NCPPostpone_01 on CACCoverage_NCPPostpone (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "创建CAClaimPolicy_NCP-理赔后需延期保单表"
echo "==============================================="
db2 "create table CAClaimPolicy_NCP
(
	ConfirmSequenceNo 	VARCHAR(50) not null,
	PolicyNo	VARCHAR(50),
	Vin	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo 	VARCHAR(50),
	ClaimSequenceNo	VARCHAR(50),
	RegistNo	VARCHAR(50),
	DamageDate	TIMESTAMP ,
	AccidentCause	VARCHAR(2000),
	Desc	VARCHAR(2000),
	InputDate	TIMESTAMP ,
   CONSTRAINT P_CAClaimPolicy_NCP PRIMARY KEY (ConfirmSequenceNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="




echo "==============================================="
echo "创建KSCMain_NCP-跨省续保保单表"
echo "==============================================="
db2 "create table KSCMain_NCP
(
	SerialNo                  INTEGER   NOT NULL  ,
	Extractiontime            TIMESTAMP,
	gid                       VARCHAR(32),
	vin                       VARCHAR(50),
	AREACODE                  VARCHAR(10),
	COMPANYCODE               VARCHAR(10),
	PLATSUBTYPE               VARCHAR(4),
	CONFIRMSEQUENCENO         VARCHAR(50),
	CONFIRMDATE               TIMESTAMP,
	EFFECTIVEDATE             TIMESTAMP,
	EXPIREDATE                TIMESTAMP,
	AREACODE_1                VARCHAR(10),
	COMPANYCODE_1             VARCHAR(10),
	PLATSUBTYPE_1             VARCHAR(4),
	CONFIRMSEQUENCENO_1       VARCHAR(50),
	CONFIRMDATE_1             TIMESTAMP,
	EFFECTIVEDATE_1           TIMESTAMP,
	EXPIREDATE_1              TIMESTAMP,
   CONSTRAINT P_KSCMain_NCP PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "创建KSCMain_NCP-CONFIRMDATE索引"
echo "==============================================="
db2 "create index IDX_KSCACMain_NCP_01 on KSCMain_NCP (
   CONFIRMSEQUENCENO           ASC
)"
echo "==============================================="

echo "==============================================="
echo "创建KSCMain_NCP-CONFIRMSEQUENCENO_1索引"
echo "==============================================="
db2 "create index IDX_KSCACMain_NCP_02 on KSCMain_NCP (
   CONFIRMSEQUENCENO_1           ASC
)"
echo "==============================================="




echo "==============================================="
echo "KSClaim_NCP-跨省理赔表"
echo "==============================================="
db2 "create table KSClaim_NCP
(
	SerialNo	INTEGER  not null ,
	Extractiontime	TIMESTAMP,
	gid	VARCHAR(32),
	vin	VARCHAR(50),
	CONFIRMSEQUENCENO	VARCHAR(50),
	CLAIMSEQUENCENO	VARCHAR(50),
	PLATSUBTYPE	VARCHAR(4),
	AREACODE	VARCHAR(10),
	COMPANYCODE	VARCHAR(10),
	CLAIMNOTIFYNO	VARCHAR(50),
	LOSSTIME	TIMESTAMP,
	CONFIRMDATE	TIMESTAMP,
	EFFECTIVEDATE	TIMESTAMP,
	EXPIREDATE	TIMESTAMP,
   CONSTRAINT P_KSClaim_NCP PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "创建KSClaim_NCP-VIN索引"
echo "==============================================="
db2 "create index IDX_KSClaim_NCP_01 on KSClaim_NCP (
   vin           ASC
)"
echo "==============================================="

echo "==============================================="
echo "创建KSClaim_NCP-CONFIRMSEQUENCENO索引"
echo "==============================================="
db2 "create index IDX_KSClaim_NCP_02 on KSClaim_NCP (
   CONFIRMSEQUENCENO           ASC
)"
echo "==============================================="














db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

