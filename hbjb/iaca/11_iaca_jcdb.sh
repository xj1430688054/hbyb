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
#�ָ������óɿո�
IFS=" "
array1=($ConfirmSequenceNo)
#���ԭ���ķָ���
IFS="$OLD_IFS"	
for ConfirmSequenceNo1 in ${array1[@]}	
do
	db2 "update CACMain_NCP set Flag = '1' where ConfirmSequenceNo = '${ConfirmSequenceNo1}'"
	funWithParam ${ConfirmSequenceNo1}	
done


	
	


################�밴��������дsql####################

db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

