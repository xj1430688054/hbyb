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
#_STARTDATA=2020-05-20

echo "请输入疫情截止日期（范例： 2020-04-05） ->"|tr -d "\012"
	read _CLOSINGDATA
#_CLOSINGDATA=2022-04-05

echo ""
echo "请输入本次处理的数量 （范例：500000） ->"|tr -d "\012"
	read _ROWS
#_ROWS=500000

echo ""
echo "请输入保单归属地， （范例， 假设是武汉 ：420100） ->"|tr -d "\012"
	read _CITYCODE
#_CITYCODE=420300



################请按照需求书写sql####################
_NOFLAG=`db2 -x "select count(*) from iacmain_ncp where flag = ''"`
_NOFLAG1=`db2 -x "select count(*) from iacmain_ncp where flag = '' and citycode = '${_CITYCODE}'"`
echo "当前省需要处理的数量是 : ${_ROWS}"
echo "当前省总共未处理的数量是： ${_NOFLAG}"

PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCP where citycode = '${_CITYCODE}' and flag = '' order by startDate fetch first ${_ROWS} rows only"`
echo "${PolicyConfirmNo}"
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array=($PolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"
for B_PolicyConfirmNo in ${array[@]}
do

db2 "insert into IACMAIN_NCPB(POLICYCONFIRMNO, POLICYNO, COMPANYCODE, CITYCODE, STARTDATE, ENDDATE, FRAMENO, LICENSENO, ENGINENO, BUSINESSTYPE, REASON, DESC, FLAG, INPUTDATE)
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
			(case
				when a.startDate < '${_STARTDATA}' and a.endDate < '${_CLOSINGDATA}'	then 1
				when a.startDate > '${_STARTDATA}' and a.startDate < '${_CLOSINGDATA}'	then 2
				when a.startDate < '${_STARTDATA}' and a.endDate > '${_CLOSINGDATA}'	then 3	
			 end	
			),
			'',
			'',
			'',
			CURRENT TIMESTAMP
		from IACMain_NCP a left join IACMain_NCP b on a.LastPoliConfirmNo = b.PolicyConfirmNo
		where
			a.startDate < '${_CLOSINGDATA}' and
			((((values days(date(b.endDate))- days(date(b.startDate))) <= 30 or b.BizStatus != '1') and b.Flag = '1' ) or 
			(a.LastPoliConfirmNo = ''or a.LastPoliConfirmNo is null)) and a.POLICYCONFIRMNO = '${B_PolicyConfirmNo}'"

done


#短期单
ShortPolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IACMain_NCPB where citycode = '${_CITYCODE}' and flag = '' and (
								values days(date(endDate))- days(date(startDate))) < 30"`
echo "${ShortPolicyConfirmNo}"								
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array1=($ShortPolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"
for Short_PolicyConfirmNo in ${array1[@]}
do
	db2 "update IACMain_NCPB  set  Reason = '1', Desc='短期单', Flag = '0'  where PolicyConfirmNo = '${Short_PolicyConfirmNo}'"
	db2 "update IACMain_NCP set flag = '1' where PolicyConfirmNo = '${Short_PolicyConfirmNo}'"
done

 
#退保
EndorPolicyConfirmNo=`db2 -x  "select a.PolicyConfirmNo from IACMain_NCPB a, IACMain_NCP b where a.citycode = '${_CITYCODE}' and a.flag = '' and b.bizstatus != '1' 
								and a.PolicyConfirmNo = b.PolicyConfirmNo"`
echo "${EndorPolicyConfirmNo}"								
#保存旧的分隔符
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array2=($EndorPolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"
for Endor_PolicyConfirmNo in ${array2[@]}
do
	EndorseConfirmNo=`db2 -x  "select EndorseConfirmNo from IAPHEAD where  PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"`
	EndorseDate=`db2 -x  "select EndDate from IACMain_NCP where  PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"`

	
	db2 "update IACMain_NCPB  set  Reason = '2', Desc='退保确认码：${EndorseConfirmNo},退保生效日期：${EndorseDate}', Flag = '0'  where PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"
	db2 "update IACMain_NCP set flag = '1' where PolicyConfirmNo = '${Endor_PolicyConfirmNo}'"
done





db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

