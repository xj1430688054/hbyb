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
_DBNAME=iaca42db	
	
	
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

##假设跨疫情期间的保单存在两种保单续保 主键？

##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量
##########条件 地市 数量

 db2 "  insert into CACMain_NCPB ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, VIN, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
		select 
		a.CONFIRMSEQUENCENO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.EFFECTIVEDATE,
		a.EXPIREDATE,
		a.VIN,
		a.LICENSENO,
		a.ENGINENO,
		'3',
		'',
		'',
		'0',
		sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys  , CACMain_NCP a
		left join CACMain_NCP b on a.CONFIRMSEQUENCENO = b.LASTPOLICYCONFIRMNO
		where a.Flag = '0' and a.EFFECTIVEDATE <  '2020-01-23' and 
		a.EXPIREDATE  > '2020-04-01' and ( b.EXPIREDATE >   '2020-04-01' or b.EXPIREDATE is null)

		
		"


db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

