#!/usr/bin/env bash



main()
{
echo "��ʼʱ��"
date
#########################################################
#���ܣ���������
##########################################################

echo "���������ݿ��� ->"|tr -d "\012"
    read _DBNAME

	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
    read _DBUSER

	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
    read _PWD

	
echo ""    
echo "������schema�� ->"|tr -d "\012"
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
#�ָ������óɿո�
IFS=" "
array1=($PolicyConfirmNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"	
for PolicyConfirmNo1 in ${array1[@]}	
do
	db2 "update IACMain_NCP set Flag = '1' where PolicyConfirmNo = '${PolicyConfirmNo1}'"
	funWithParam ${PolicyConfirmNo1}	
done


	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

