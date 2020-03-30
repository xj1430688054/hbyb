#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ�������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
    read _DBNAME
#_DBNAME=iaca42db	
	
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
    read _DBUSER
#_DBUSER=instiaci
	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
    read _PWD
#_PWD=password
	
echo ""    
echo "������schema�� ->"|tr -d "\012"
    read _SCHEMA
#_SCHEMA=instiaci

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
echo "�������ռ� ->"|tr -d "\012"
	read _TBSDATA
#_TBSDATA=tbsdata

echo ""
echo "�����������ռ� ->"|tr -d "\012"
	read _TBSINDEX
#_TBSINDEX=tbsindex

################�밴��������дsql####################

echo "==============================================="
echo "����CACMain_NCP-������ȫ����������Ϣ��"
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
echo "����CACMain_NCP-LastPolicyConfirmNo����"
echo "==============================================="
db2 "create index IDX_CACMain_NCP_02 on CACMain_NCP (
   LastPolicyConfirmNo           ASC
)"
echo "==============================================="







echo "==============================================="
echo "����CACMain_NCPB-�����ڱ�������Ϣ��"
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
echo "����CACMain_NCPB-ConfirmSequenceNo����"
echo "==============================================="
db2 "create index IDX_CACMain_NCPB_01 on CACMain_NCPB (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "����CACMain_NCPX-����������������Ϣ��"
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
echo "����CACMain_NCPX-ConfirmSequenceNo����"
echo "==============================================="
db2 "create index IDX_CACMain_NCPX_01 on CACMain_NCPX (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="

echo "==============================================="
echo "����CACMain_NCPX-LastPoliConfirmNo����"
echo "==============================================="
db2 "create index IDX_CACMain_NCPX_02 on CACMain_NCPX (
   LastPolicyConfirmNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "����CACMain_NCPPostpone-������˳�ӱ�����Ϣ��"
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
echo "����CACMain_NCPPostpone-ConfirmSequenceNo����"
echo "==============================================="
db2 "create index IDX_CACMain_NCPPostpone_01 on CACMain_NCPPostpone (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="

echo "==============================================="
echo "����CACMain_NCPPostpone-LastPolicyConfirmNo����"
echo "==============================================="
db2 "create index CACMain_NCPPostpone_02 on CACMain_NCPPostpone (
   LastPolicyConfirmNo           ASC
)"
echo "==============================================="



echo "==============================================="
echo "����CACCoverage_NCPPostpone-������˳��������Ϣ��"
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
echo "����CACCoverage_NCPPostpone-ConfirmSequenceNo����"
echo "==============================================="
db2 "create index IDX_CACCoverage_NCPPostpone_01 on CACCoverage_NCPPostpone (
   ConfirmSequenceNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "����CAClaimPolicy_NCP-����������ڱ�����"
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
echo "����KSCMain_NCP-��ʡ����������"
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
echo "����KSCMain_NCP-CONFIRMDATE����"
echo "==============================================="
db2 "create index IDX_KSCACMain_NCP_01 on KSCMain_NCP (
   CONFIRMSEQUENCENO           ASC
)"
echo "==============================================="

echo "==============================================="
echo "����KSCMain_NCP-CONFIRMSEQUENCENO_1����"
echo "==============================================="
db2 "create index IDX_KSCACMain_NCP_02 on KSCMain_NCP (
   CONFIRMSEQUENCENO_1           ASC
)"
echo "==============================================="




echo "==============================================="
echo "KSClaim_NCP-��ʡ�����"
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
echo "����KSClaim_NCP-VIN����"
echo "==============================================="
db2 "create index IDX_KSClaim_NCP_01 on KSClaim_NCP (
   vin           ASC
)"
echo "==============================================="

echo "==============================================="
echo "����KSClaim_NCP-CONFIRMSEQUENCENO����"
echo "==============================================="
db2 "create index IDX_KSClaim_NCP_02 on KSClaim_NCP (
   CONFIRMSEQUENCENO           ASC
)"
echo "==============================================="














db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

