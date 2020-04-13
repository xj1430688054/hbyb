#!/usr/bin/env bash



main()
{
echo "开始时间"
date
#########################################################
#功能：更新数据
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
####取出基础数据中最后的提数时间
#_LASTDATE=`db2 -x "select a.INPUTDATE  from cacmain_ncp a  order by a.INPUTDATE desc    fetch first 1 row only"`

echo ""    
echo "请输入上次提数时间（例： 2020-01-23 12:00:00  ） ->"|tr -d "\012"
    read _LASTDATE

####取出当前的提数时间
_INPUTTIME=`db2 -x "select to_char(current timestamp,'yyyy-mm-dd hh24:mi:ss') from sysibm.dual"`

################请按照需求书写sql####################


echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------提取投保确认码在上次提数或更新后的-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

db2 "insert into CACMain_NCP(CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, STOPTRAVELTYPE, STOPTRASTRATDATE, STOPTRAVELENDDATE, BIZSTATUS, LASTPOLICYCONFIRMNO, VIN, LICENSENO, ENGINENO, FLAG, INPUTDATE, UPDATETIME)
     select 
		a.CONFIRMSEQUENCENO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.EFFECTIVEDATE,
		a.EXPIREDATE,
		a.STOPTRAVELTYPE,
		a.STOPTRASTRATDATE,
		a.STOPTRAVELENDDATE,
		a.BIZSTATUS,
		a.LASTPOLICYCONFIRMNO,
		b.VIN,
		b.LICENSENO,
		b.ENGINENO,
		(case 
			when c.CONFIRMSEQUENCENO is not null   then '1'
			when c.CONFIRMSEQUENCENO is  null then '' 
		end ) enddate,
		'${_INPUTTIME}', 
		null
	 from   cacmain a
	 inner join CACVehicle b on a.CONFIRMSEQUENCENO=b.CONFIRMSEQUENCENO
								and a.ValidStatus ='1'
								and a.ConfirmDate  >= '${_LASTDATE}'
	 left join cacmain_ncp c on a.LASTPOLICYCONFIRMNO = c.CONFIRMSEQUENCENO
							and c.flag = '1'
	 left join cacmain_ncp d on d.CONFIRMSEQUENCENO = a.CONFIRMSEQUENCENO
	 where d.CONFIRMSEQUENCENO is null

	 "

	 

echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------提取批改确认码时间在上次后的并处理-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

PPOLICYCONFIRMNOS=`db2 -x "select distinct CONFIRMSEQUENCENO  from CAPHead where confirmdate >= '${_LASTDATE}' "`

echo "${PPOLICYCONFIRMNOS}"
##保存旧的分隔符
OLD_IFS="$IFS"
##分隔符设置成空格
IFS=" "
array=($PPOLICYCONFIRMNOS)
##变成原来的分隔符
IFS="$OLD_IFS"

###遍历本保单，查询虚报单
for P_PolicyConfirmNo in ${array[@]}
do	

	db2 "update cacmain_ncp d
			set ( 
				d.POLICYNO, 
				d.COMPANYCODE, 
				d.CITYCODE, 
				d.EFFECTIVEDATE, 
				d.EXPIREDATE, 
				d.STOPTRAVELTYPE, 
				d.STOPTRASTRATDATE, 
				d.STOPTRAVELENDDATE, 
				d.BIZSTATUS, 
				d.LASTPOLICYCONFIRMNO, 
				d.VIN, 
				d.LICENSENO, 
				d.ENGINENO, 
				d.UPDATETIME
				) = 
				(
					select 
						a.POLICYNO,
						a.COMPANYCODE,
						a.CITYCODE,
						a.EFFECTIVEDATE,
						a.EXPIREDATE,
						a.STOPTRAVELTYPE,
						a.STOPTRASTRATDATE,
						a.STOPTRAVELENDDATE,
						a.BIZSTATUS,
						a.LASTPOLICYCONFIRMNO,
						b.VIN,
						b.LICENSENO,
						b.ENGINENO,
						current timestamp 
					from   cacmain a 
					inner join CACVehicle b on a.CONFIRMSEQUENCENO = b.CONFIRMSEQUENCENO 
											and a.CONFIRMSEQUENCENO  = '${P_PolicyConfirmNo}'
					inner join cacmain_ncp e on a.CONFIRMSEQUENCENO = e.CONFIRMSEQUENCENO and e.flag = ''
					where a.CONFIRMSEQUENCENO = d.CONFIRMSEQUENCENO	
					)
					
					 where  d.CONFIRMSEQUENCENO  = '${P_PolicyConfirmNo}'
							and d.flag = ''
							"

done

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4_iaca_dml_zengliang_${times}.log

