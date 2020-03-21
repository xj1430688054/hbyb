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


################请按照需求书写sql####################

##本次保单的投保确认码CACMain_B
PolicyConfirmNo=`db2 -x  "select distinct CONFIRMSEQUENCENO from CACMain_NCPB"`







	
		i=$[i+1];
		###查询第几层续保单 ,需要再条件种加入第几层
		XuPolicyConfirmNo=`db2 -x  "	select 
										a.CONFIRMSEQUENCENO
									from CACMain_NCPX a 
										inner join CACMain_NCP b on a.CONFIRMSEQUENCENO = b.LastPolicyConfirmNo
										"`
	
	while true
	do
	echo "============================="
echo 	"$XuPolicyConfirmNo"
	if [  -z "$XuPolicyConfirmNo" ]
    then
		echo "1111111"
		break;
	else 
		echo "222222"
    fi
	
	echo "-------------------------------------"
	done
	








db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/2-ddl_${times}.log

