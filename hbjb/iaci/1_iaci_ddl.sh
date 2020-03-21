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
_DBNAME=iaci42db	
	
	
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
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ�������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
echo "��������ռ� ->"|tr -d "\012"
#	read _TBSDATA
_TBSDATA=tbsdata

echo ""
echo "�����������ռ� ->"|tr -d "\012"
#	read _TBSINDEX
_TBSINDEX=tbsindex

################�밴��������дsql####################

echo "==============================================="
echo "����IACMain_NCP-������ȫ����������Ϣ��"
echo "==============================================="
db2 "create table IACMain_NCP
(
	PolicyConfirmNo 	VARCHAR(50) not null,
	PolicyNo	VARCHAR(50),
	CompanyCode 	VARCHAR(8), 
	CityCode 	VARCHAR(10),
	StartDate 	TIMESTAMP ,
	EndDate 	TIMESTAMP ,
	StopTravelType	VARCHAR(1),
	StopTraStartDate	TIMESTAMP ,
	StopTravelEndDate	TIMESTAMP ,
	BizStatus	VARCHAR(1),
	LastPoliConfirmNo	VARCHAR(50),
	FrameNo 	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo 	VARCHAR(50),
	Flag	VARCHAR(1),
	InputDate	TIMESTAMP ,
	UpdateTime	TIMESTAMP ,

   CONSTRAINT P_IACMain_NCP PRIMARY KEY (PolicyConfirmNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="




echo "==============================================="
echo "����IACMain_NCP-LastPoliConfirmNo����"
echo "==============================================="
db2 "create index IDX_IACMain_NCP_01 on IACMain_NCP (
   LastPoliConfirmNo           ASC
)"
echo "==============================================="




echo "==============================================="
echo "����IACMain_NCPB-�����ڱ�������Ϣ��"
echo "==============================================="
db2 "create table IACMain_NCPB
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
	PolicyConfirmNo 	VARCHAR(50),
	PolicyNo	VARCHAR(50),
	CompanyCode 	VARCHAR(8) ,
	CityCode 	VARCHAR(10),
	StartDate 	TIMESTAMP ,
	EndDate 	TIMESTAMP ,
	FrameNo 	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo 	VARCHAR(50),
	BusinessType	VARCHAR(1),
	Reason	VARCHAR(1),
	Desc	VARCHAR(2000),
	Flag	VARCHAR(1),
	InputDate	TIMESTAMP ,
   CONSTRAINT P_IACMain_NCPB PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "����IACMain_NCPB-PolicyConfirmNo����"
echo "==============================================="
db2 "create index IDX_IACMain_NCPB_01 on IACMain_NCPB (
   PolicyConfirmNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "����IACMain_NCPX-����������������Ϣ��"
echo "==============================================="
db2 "create table IACMain_NCPX
(
	SerialNo INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
	PolicyConfirmNo 	VARCHAR(50),
	PolicyNo	VARCHAR(50),
	CompanyCode 	VARCHAR(8) ,
	CityCode 	VARCHAR(10),
	StartDate 	TIMESTAMP ,
	EndDate 	TIMESTAMP ,
	LastPoliConfirmNo	VARCHAR(50),
	FrameNo 	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo 	VARCHAR(50),
	InputDate	TIMESTAMP ,
   CONSTRAINT P_IACMain_NCPX PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "����IACMain_NCPX-PolicyConfirmNo����"
echo "==============================================="
db2 "create index IDX_IACMain_NCPX_01 on IACMain_NCPX (
   PolicyConfirmNo           ASC
)"
echo "==============================================="

echo "==============================================="
echo "����IACMain_NCPX-LastPoliConfirmNo����"
echo "==============================================="
db2 "create index IDX_IACMain_NCPX_02 on IACMain_NCPX (
   LastPoliConfirmNo           ASC
)"
echo "==============================================="


echo "==============================================="
echo "����IACMain_NCPPostpone-������˳�ӱ�����Ϣ��"
echo "==============================================="
db2 "create table IACMain_NCPPostpone
(
	SerialNo	INTEGER  NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1 ),
	PolicyConfirmNo 	VARCHAR(50),
	PolicyNo	VARCHAR(50),
	CompanyCode 	VARCHAR(8) ,
	StartDate	TIMESTAMP,
	EndDate 	TIMESTAMP,
	AfterEndDate 	TIMESTAMP,
	NCPStartDate	TIMESTAMP,
	NCPEndDate	TIMESTAMP,
	NCPValidDate	INTEGER ,
	PostponeDay	INTEGER ,
	CityCode 	VARCHAR(10),
	LastPoliConfirmNo	VARCHAR(50),
	FrameNo 	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo 	VARCHAR(50),
	BusinessType	VARCHAR(1),
	InputDate	TIMESTAMP ,
	UpdateTime	TIMESTAMP ,
	ValidStatus 	VARCHAR(1),
   CONSTRAINT P_IACMain_NCPPostpone PRIMARY KEY (SerialNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="

echo "==============================================="
echo "����IACMain_NCPPostpone-PolicyConfirmNo����"
echo "==============================================="
db2 "create index IDX_IACMain_NCPPostpone_01 on IACMain_NCPPostpone (
   PolicyConfirmNo           ASC
)"
echo "==============================================="

echo "==============================================="
echo "����IACMain_NCPPostpone-LastPolicyConfirmNo����"
echo "==============================================="
db2 "create index IACMain_NCPPostpone_02 on IACMain_NCPPostpone (
   LastPoliConfirmNo           ASC
)"
echo "==============================================="




echo "==============================================="
echo "����IAClaimPolicy_NCP-����������ڱ�����"
echo "==============================================="
db2 "create table IAClaimPolicy_NCP
(
	PolicyConfirmNo 	VARCHAR(50) not null,
	PolicyNo	VARCHAR(50),
	FrameNo 	VARCHAR(50),
	LicenseNo 	VARCHAR(15),
	EngineNo 	VARCHAR(50),
	ClaimQueryNo	VARCHAR(50),
	RegistNo	VARCHAR(50),
	DamageDate	TIMESTAMP ,
	AccidentCause	VARCHAR(2000),
	Desc	VARCHAR(2000),
	InputDate	TIMESTAMP ,
   CONSTRAINT P_IAClaimPolicy_NCP PRIMARY KEY (PolicyConfirmNo)
) IN ${_TBSDATA} INDEX IN ${_TBSINDEX}"
echo "==============================================="












db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log
