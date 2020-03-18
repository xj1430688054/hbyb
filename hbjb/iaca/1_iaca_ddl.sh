#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ�������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
  #  read _DBNAME
_DBNAME=iaca51db	
	
	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
 #   read _DBUSER
_DBUSER=instiaci
	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
 #   read _PWD
_PWD=password
	
echo ""    
echo "������schema�� ->"|tr -d "\012"
  #  read _SCHEMA
_SCHEMA=instiaci

db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}

################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
echo "�������ռ� ->"|tr -d "\012"
#	read _TBSDATA
_TBSDATA=tbsdata

echo ""
echo "�����������ռ� ->"|tr -d "\012"
#	read _TBSINDEX
_TBSINDEX=tbsindex

################�밴��������дsql####################

echo "==============================================="
echo "����CACMain_A-������ȫ����������Ϣ��"
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
echo "����CACMain_B-��������Ϣ��"
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
echo "����CACMain_X-����������Ϣ��"
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
    InputDate TIMESTAMP ,��
   CONSTRAINT P_CACMain_X PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="


echo "==============================================="
echo "����CAPostponeMain-˳�ӱ�����Ϣ��"
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
echo "����CAPostponeCoverage-˳��������Ϣ��"
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






echo "��������"
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

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

