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
####取出基础数据中最后的提数时间
_LASTDATE=`db2 -x "select a.INPUTDATE  from iacmain_ncp a  order by a.INPUTDATE desc    fetch first 1 row only"`



################请按照需求书写sql####################

echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------提取投保确认码在上次提数或更新后的-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

db2 "insert into IACMain_NCP(POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, STOPTRAVELTYPE, STOPTRASTARTDATE, STOPTRAVELENDDATE, BIZSTATUS, LASTPOLICONFIRMNO, FRAMENO, LICENSENO, ENGINENO, FLAG, INPUTDATE, UPDATETIME)
	 select 
		a.POLICYCONFIRMNO,
		a.POLICYNO,
		a.COMPANYCODE,
		a.CITYCODE,
		a.STARTDATE,
		(case 
						when d.PolicyConfirmNo is not null   then d.ValidDate 
						when d.PolicyConfirmNo is  null then a.enddate 
		end ) enddate,
		a.STOPTRAVELTYPE,
		a.STOPTRASTARTDATE,
		a.STOPTRAVELENDDATE,
		a.BIZSTATUS,
		a.LASTPOLICONFIRMNO,
		b.FRAMENO,
		b.LICENSENO,
		b.ENGINENO,
		(case 
			when c.PolicyConfirmNo is not null   then '1'
			when c.PolicyConfirmNo is  null then '' 
		end ) flag,
		current timestamp , 
		null 
	 from    iacmain a
	 inner join IATCItemCar b on a.POLICYCONFIRMNO=b.POLICYCONFIRMNO  
								and a.ValidStatus ='1'
								and a.InputDate >= '${_LASTDATE}'
	  left join iacmain_ncp c on a.LASTPOLICONFIRMNO = c.POLICYCONFIRMNO
							and c.flag = '1'
	 left join iaphead d on d.PolicyConfirmNo=a.POLICYCONFIRMNO 
							and d.EndorseType = '2' 

								
"

echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------提取批改确认码时间在上次后的并处理-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

PPOLICYCONFIRMNOS=`db2 -x "select distinct POLICYCONFIRMNO  from IAPHead where confirmdate >= '${_LASTDATE}' "`

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
#	#判断他的上张是否打过标
#	flag=`db2 -x "select 
#					a.flag 
#				  from iacmain_ncp a
#				  where a.POLICYCONFIRMNO = '${P_PolicyConfirmNo}' "`
#				  
#	if [  -z "$P_PolicyConfirmNo" ]
#   then
	
		####没有打过标
		echo "更新基础数据表"
		db2 "update iacmain_ncp  d 
				set  
					(
						d.POLICYNO, 
						d.COMPANYCODE, 
						d.CITYCODE, 
						d.STARTDATE, 
						d.ENDDATE, 
						d.STOPTRAVELTYPE, 
						d.STOPTRASTARTDATE, 
						d.STOPTRAVELENDDATE, 
						d.BIZSTATUS, 
						d.LASTPOLICONFIRMNO, 
						d.FRAMENO, 
						d.LICENSENO, 
						d.ENGINENO, 
						d.UPDATETIME 
					)
					= 
				(select 
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
					current timestamp 
				from   iacmain a
				inner join IATCItemCar b on a.POLICYCONFIRMNO = b.POLICYCONFIRMNO 
										and a.POLICYCONFIRMNO = '${P_PolicyConfirmNo}'
				inner join iacmain_ncp e on a.POLICYCONFIRMNO = e.POLICYCONFIRMNO 
										and e.flag = ''
				left join iaphead c on c.PolicyConfirmNo=a.POLICYCONFIRMNO and c.EndorseType = '2'
				where a.POLICYCONFIRMNO = d.POLICYCONFIRMNO 
				
				)
					where d.POLICYCONFIRMNO = '${P_PolicyConfirmNo}' 
							and d.flag = ''
				"
		
#	else
		####打过标
	#	echo "${P_PolicyConfirmNo} 的上张已经做过处理， 本次不做处理"
		
  #  fi
				 
done



db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4_iaci_dml_zengliang_${times}.log

