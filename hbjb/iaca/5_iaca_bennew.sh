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

echo "请输入疫情截止日期（范例： 2020-01-23） ->"|tr -d "\012"
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

##假设跨疫情期间的保单存在两种保单续保 主键？

##########数量
_NOFLAG=`db2 -x "select count(*) from cacmain_ncp where flag = ''"`
_NOFLAG1=`db2 -x "select count(*) from cacmain_ncp where flag = '' and citycode = '${_CITYCODE}'"`
echo "当前需要处理的数量是 : ${_ROWS}"
echo "当前省总共未处理的数量是： ${_NOFLAG}"
echo "当前市总共未处理的数量是： ${_NOFLAG}"


####取一定数量的投保确认码,根据起包时间排序
##confirmsequences=`db2 -x "select  CONFIRMSEQUENCENO from cacmain_ncp 
##						where flag = '' and 
##							CITYCODE = '${_CITYCODE}' 
##							order by EFFECTIVEDATE 
##							fetch first ${_ROWS} row only"`
##							
##echo "${confirmsequences}"
##echo "本次保单的续保保单"
####保存旧的分隔符
##OLD_IFS="$IFS"
####分隔符设置成空格
##IFS=" "
##array=($confirmsequences)
####变成原来的分隔符
##IFS="$OLD_IFS"
##
##
##
######遍历保单，查询其中的本保单
##for X_PolicyConfirmNo in ${array[@]}
##do

echo "${X_PolicyConfirmNo}"
db2 "insert into CACMain_NCPB ( CONFIRMSEQUENCENO, POLICYNO, COMPANYCODE, CITYCODE, EFFECTIVEDATE, EXPIREDATE, VIN, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
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
		(case 
			when a.EFFECTIVEDATE <  '${_STARTDATA}' and a.EXPIREDATE  > '${_CLOSINGDATA}' 	then  3
			when a.EFFECTIVEDATE > '${_STARTDATA}' and a.EFFECTIVEDATE < '${_CLOSINGDATA}' 		then 2
			when a.EXPIREDATE > '${_STARTDATA}' and a.EXPIREDATE < '${_CLOSINGDATA}' 		then 1
		end ) enddate,
		'',
		'',
		'',
		sys.extracttime
		from (select current timestamp as extracttime from sysibm.sysdummy1) sys  , CACMain_NCP a
		left join CACMain_NCP b on a.LASTPOLICYCONFIRMNO = b.CONFIRMSEQUENCENO  
									
		where (   (a.EFFECTIVEDATE <  '${_STARTDATA}' and a.EXPIREDATE  > '${_CLOSINGDATA}') 
				or (a.EFFECTIVEDATE  > '${_STARTDATA}' and a.EFFECTIVEDATE < '${_CLOSINGDATA}')
				or (a.EXPIREDATE > '${_STARTDATA}' and a.EXPIREDATE < '${_CLOSINGDATA}') 
			)
									
			and a.Flag = '' 
			and (   b.EXPIREDATE is null  
					or (  b.flag = '1' 
						  and 	( (values days(date(b.ExpireDate))- days(date(b.EffectiveDate)) ) <= 30
								 or b.BizStatus  = '4' 
								)
					   )
				)
			and a.citycode = '${_CITYCODE}'

			fetch first ${_ROWS} row only

"
##			and a.CONFIRMSEQUENCENO = '${X_PolicyConfirmNo} 

####打标
########短期单的投保确认吗
shortconfirmsequences=`db2 -x "select 
									b.CONFIRMSEQUENCENO 
							from cacmain_ncpb b 
							where b.flag = '' 
								and b.CITYCODE = '${_CITYCODE}' 
								and (values days(date(b.ExpireDate))- days(date(b.EffectiveDate)) ) <= 30							
							"`

		


##保存旧的分隔符
OLD_IFS="$IFS"
##分隔符设置成空格
IFS=" "
arrays1=($shortconfirmsequences)
##变成原来的分隔符
IFS="$OLD_IFS"
					
	
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "开始处理短期单子"
echo "${shortconfirmsequences}"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"

for short_PolicyConfirmNo in ${arrays1[@]}
do
	echo "${short_PolicyConfirmNo}"
	db2 "update cacmain_ncpb  set  Reason = '1', Desc='短期单', Flag = '0'  where CONFIRMSEQUENCENO = '${short_PolicyConfirmNo}'"
	db2 "update cacmain_ncp set flag = '0' where CONFIRMSEQUENCENO = '${short_PolicyConfirmNo}'"

done					










####退保的投保确认吗							
endorconfirmsequences=`db2 -x "select 
									a.CONFIRMSEQUENCENO 
							from cacmain_ncpb a
							inner join cacmain_ncp b on a.CONFIRMSEQUENCENO = b.CONFIRMSEQUENCENO 
														and a.CITYCODE = '${_CITYCODE}' 	
														and a.flag = ''
							where 							
							 b.bizstatus = '4'							
							"`


##保存旧的分隔符
OLD_IFS="$IFS"
##分隔符设置成空格
IFS=" "
arrays2=($endorconfirmsequences)	
##变成原来的分隔符
IFS="$OLD_IFS"

echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "开始处理退保单子"
echo "${endorconfirmsequences}"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"
echo "---------------------------------------------"

for endor_PolicyConfirmNo in ${arrays2[@]}
do	
	echo "${endor_PolicyConfirmNo}"
	endorpolicy=`db2 -x "select AmendConfirmNo  from caphead where ConfirmSequenceNo  = '${endor_PolicyConfirmNo}'"`
	validate=`db2 -x "select ValidDate   from caphead where ConfirmSequenceNo  = '${endor_PolicyConfirmNo}'"`
	
	db2 "update cacmain_ncpb  set  Reason = '2', Desc='退保确认码： ${endorpolicy}, 退保生效日期： ${validate}', Flag = '0' where CONFIRMSEQUENCENO = '${endor_PolicyConfirmNo}'"
	db2 "update cacmain_ncp set flag = '0' where CONFIRMSEQUENCENO = '${endor_PolicyConfirmNo}'"
	
done		
							






db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

