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
_DBNAME=iaci42db	
	
	
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
echo "请输入疫情开始日期（范例： 2020-01-23） ->"|tr -d "\012"
#	read _CLOSINGDATA
_STARTDATA=2020-01-23

echo "请输入疫情截止日期（范例： 2020-04-05） ->"|tr -d "\012"
#	read _CLOSINGDATA
_CLOSINGDATA=2020-04-05

echo ""
echo "请输入本次处理的数量 （范例：500000） ->"|tr -d "\012"
#	read _ROWS
_ROWS=500000

echo ""
echo "请输入保单归属地， （范例， 假设是武汉 ：420101） ->"|tr -d "\012"
#	read _ROWS
_CITYCODE=420100

################请按照需求书写sql####################



 db2 "  insert into IACMAIN_NCPB ( POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, FRAMENO, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
		select 
			a.POLICYCONFIRMNO,
			a.POLICYNO,
			a.COMPANYCODE,
			a.CITYCODE,
			a.STARTDATE,
			a.ENDDATE,
			a.FRAMENO,
			a.LICENSENO,
			a.ENGINENO,
			'2',
			'',
			'',
			'',
			sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys  , IACMain_NCP a
		left join IACMain_NCP b on a.LastPoliConfirmNo = b.POLICYCONFIRMNO
		where a.Flag = '0' 
			and a.STARTDATE > '${_STARTDATA}' 
			and a.CITYCODE = '${_CITYCODE}'
			
		

		
		"


db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

