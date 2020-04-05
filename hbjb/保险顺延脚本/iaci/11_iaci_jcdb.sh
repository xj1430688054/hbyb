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

				LastPoliConfirmNo=`db2 -x  "select LastPoliConfirmNo from IACMain_NCP where PolicyConfirmNo = '${1}'"`
				LastPoliConfirmNo=`echo ${LastPoliConfirmNo} | tr -d ' '`
				echo "LastPoliConfirmNo:${LastPoliConfirmNo}"
				if [ -z "${LastPoliConfirmNo}" ]
				then					
					db2 "update IACMain_NCP set Flag = '1' where PolicyConfirmNo = '${1}'"
					continue
				else
					db2 "update IACMain_NCP set Flag = '1' where PolicyConfirmNo = '${LastPoliConfirmNo}'"
					funWithParam ${LastPoliConfirmNo}
				fi
			}

PolicyConfirmNo=`db2 -x  "select PolicyConfirmNo from IAPolicyNoPost_NCP "`	
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array1=($PolicyConfirmNo)
#变成原来的分隔符
IFS="$OLD_IFS"	
for PolicyConfirmNo1 in ${array1[@]}	
do
	db2 "update IACMain_NCP set Flag = '1' where PolicyConfirmNo = '${PolicyConfirmNo1}'"
	funWithParam ${PolicyConfirmNo1}	
done


	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

