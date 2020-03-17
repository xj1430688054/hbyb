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
echo "����CACMain_A��"
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
echo "����CACMain_B��"
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
echo "����CACMain_X��"
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
echo "����CAPostponeMain��"
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
echo "����CAPostponeCoverage��"
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

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

