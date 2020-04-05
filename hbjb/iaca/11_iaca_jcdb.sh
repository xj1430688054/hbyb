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

	
echo ""    
echo "请输入数据库用户 ->"|tr -d "\012"
    read _DBUSER

	
echo ""    	
echo "请输入数据库用户密码 ->"|tr -d "\012"
    read _PWD

	
echo ""    
echo "请输入schema名 ->"|tr -d "\012"
    read _SCHEMA


db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
echo  "connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}"
db2 set schema=${_SCHEMA}







function funWithParam (){

				LastPolicyConfirmNo=`db2 -x  "select LastPolicyConfirmNo from CACMain_NCP where ConfirmSequenceNo = '${1}'"`
				LastPolicyConfirmNo=`echo ${LastPolicyConfirmNo} | tr -d ' '`
				echo "LastPolicyConfirmNo:${LastPolicyConfirmNo}"
				if [ -z "${LastPolicyConfirmNo}" ]
				then					
					db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = '${1}'"
					continue
				else
					db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = '${LastPolicyConfirmNo}'"
					funWithParam ${LastPolicyConfirmNo}
				fi
			}

ConfirmSequenceNo=`db2 -x  "select ConfirmSequenceNo from CAPolicyNoPost_NCP "`	
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array1=($ConfirmSequenceNo)
#变成原来的分隔符
IFS="$OLD_IFS"	
for ConfirmSequenceNo1 in ${array1[@]}	
do
	db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = '${ConfirmSequenceNo1}'"
	funWithParam ${ConfirmSequenceNo1}	
done


	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

