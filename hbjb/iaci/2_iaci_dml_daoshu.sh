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
#_DBNAME=iaci42db	
	
	
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
echo "请输入疫情开始日期（范例： 2020-01-23） ->"|tr -d "\012"
	read _STARTDATA
#_STARTDATA=2020-01-23


####取出当前的提数时间



_INPUTTIME=`db2 -x "select to_char(current timestamp,'yyyy-mm-dd hh24:mi:ss') from sysibm.dual"`




################请按照需求书写sql####################

####数据量可能大，。。执行之间可能很大,  
######假设当前保单的对应的批单中对应多条EndorseType为2的状况的数据时， 会发送sql错误，主键重复
echo "==============================================="
db2 "
insert into IACMain_NCP(POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, STOPTRAVELTYPE, STOPTRASTARTDATE, STOPTRAVELENDDATE, BIZSTATUS, LASTPOLICONFIRMNO, FRAMENO, LICENSENO, ENGINENO, FLAG, INPUTDATE, UPDATETIME)

 select 
		a.POLICYCONFIRMNO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.STARTDATE,
		(case 
			when c.PolicyConfirmNo is not null   then c.ValidDate 
			when c.PolicyConfirmNo is  null then a.enddate 
		end ) enddate,
		a.STOPTRAVELTYPE,
		a.STOPTRASTARTDATE,
		a.STOPTRAVELENDDATE,
		a.BIZSTATUS,
		a.LASTPOLICONFIRMNO,
		b.FRAMENO,
		b.LICENSENO,
		b.ENGINENO,
		'',
		'${_INPUTTIME}', 
		null 
	 from  iacmain a
	 inner join IATCItemCar b on a.POLICYCONFIRMNO=b.POLICYCONFIRMNO
	 left join iaphead c on c.PolicyConfirmNo=a.POLICYCONFIRMNO and c.EndorseType = '2' 
	where ( a.ENDDATE > '${_STARTDATA}'  and c.PolicyConfirmNo is null )
		or (a.ENDDATE > '${_STARTDATA}'  and c.ValidDate > '${_STARTDATA}' )
		and  a.ValidStatus ='1'
	 
	 "


db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-dml_${times}.log

