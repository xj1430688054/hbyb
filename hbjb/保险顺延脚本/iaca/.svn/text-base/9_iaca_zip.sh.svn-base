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
db2 set schema=${_SCHEMA}

echo ""
echo "请输入路径(例：/home/instiaci/IACA/) ->"|tr -d "\012"
    read _DATAPATH	

echo ""
echo "请输入开始时间(例：2020-03-23 12:00:00) ->"|tr -d "\012"
    read _DATETIME	


echo ""
echo "请输入保险公司代码(例：PAIC PICC ABIC(用空格隔开)) ->"|tr -d "\012"
    read _COMPANY	
	
echo ""
echo "请输入密码配置文件路劲(例：/home/instiaci/xj/pass.txt) ->"|tr -d "\012"
    read _PASSPATH	
#_PASSPATH=/home/instiaci/xj/pass.txt

################以上部分不允许修改        ###############
################以下脚本，根据实际情况修改###############
#参数名以下划线开始，以下部分开发人员可自行修改，并可以添加需要的参数

#当前时间
date1=$(date +"%Y%m%d%H%M%S")

 if [ ! -d ${_DATAPATH} ]; 
 then 
 mkdir -p ${_DATAPATH} 
 fi 




for company in ${_COMPANY}
do

_DATAPATH1=${_DATAPATH}"Data/"${date1}"/"${company}"/"
_DATAPATH2=${_DATAPATH}"Data/"${date1}"/"
echo "${_DATAPATH1}"

if [ ! -d ${_DATAPATH1} ]; 
 then 
 mkdir -p ${_DATAPATH1} 
 fi 

			

			b=""
			i=1;
			function funWithParam (){
			echo "n:$1"
				a=""
				CoverageCode=`db2 -x  "select CoverageCode from CACCoverage_NCPPostpone where ConfirmSequenceNo= '${1}'"`
				OLD_IFS="$IFS"
				#分隔符设置成空格
				IFS=" "
				array1=($CoverageCode)
				#变成原来的分隔符
				IFS="$OLD_IFS"
				for CoverageCode1 in ${array1[@]}
				do
					Z_CoverageCode=${CoverageCode1}","
					a=${a}${Z_CoverageCode}
				done
				echo "a:${a}"
				c=${#a} 
				a=${a: start :c-1}
				echo "a:${a}"
				b=${a}
			}

ConfirmSequenceNo=`db2 -x  "select ConfirmSequenceNo from CACMain_NCPPostpone where UpdateTime > '${_DATETIME}' and flag = ''"`	
OLD_IFS="$IFS"
#分隔符设置成空格
IFS=" "
array2=($ConfirmSequenceNo)
#变成原来的分隔符
IFS="$OLD_IFS"	
for ConfirmSequenceNo1 in ${array2[@]}	
do
	i=${i+1}
	echo "i:${i}"
	funWithParam ${ConfirmSequenceNo1}
	
		db2 "EXPORT TO ${_DATAPATH1}IACA_${company}_${date1}_${i}_1.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH1}IACA_${company}${date1}_${i}_1.log\
		select b.ConfirmSequenceNo, b.PolicyNo, b.CityCode, to_char(TIMESTAMP(b.EffectiveDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(b.ExpireDate),'YYYY-MM-DD HH24:MI:SS'), b.LicenseNo,b.Vin, b.EngineNo, a.PolicyNo,to_char(TIMESTAMP(a.AfterExpireDate),'YYYY-MM-DD HH24:MI:SS'), a.NCPValidDate, a.PostponeDay, to_char(TIMESTAMP(a.NCPStartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(a.NCPEndDate),'YYYY-MM-DD HH24:MI:SS'), '${b}'
			from CACMain_NCPPostpone a,CACMain_NCPB b
			where a.LastPoliCYConfirmNo is not null and b.ConfirmSequenceNo = a.LastPoliCYConfirmNo and a.CompanyCode = '${company}' and a.ConfirmSequenceNo = '${ConfirmSequenceNo1}'
		union
		select ConfirmSequenceNo, PolicyNo, CityCode, to_char(TIMESTAMP(EffectiveDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(ExpireDate),'YYYY-MM-DD HH24:MI:SS'), LicenseNo,Vin, EngineNo, PolicyNo, to_char(TIMESTAMP(AfterExpireDate),'YYYY-MM-DD HH24:MI:SS'), NCPValidDate, PostponeDay, to_char(TIMESTAMP(NCPStartDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(NCPEndDate),'YYYY-MM-DD HH24:MI:SS'), '${b}'
			from CACMain_NCPPostpone
			where (LastPoliCYConfirmNo is null or LastPoliCYConfirmNo='') and ConfirmSequenceNo = '${ConfirmSequenceNo1}' and CompanyCode = '${company}'"			
done

cd  ${_DATAPATH1}
cat IACA_${company}_${date1}_*_1.txt >> IACA_${company}_${date1}_01.txt

rm -rf 	IACA_${company}_${date1}_*_1.txt		


db2 "EXPORT TO ${_DATAPATH1}IACA_${company}_${date1}_02.txt of DEL modified by codepage=1208 COLDEL| NOCHARDEL STRIPLZEROS MESSAGES ${_DATAPATH1}IACA_${company}_${date1}_02.log\
			select a.LastPolicyConfirmNo, a.ConfirmSequenceNo, a.PolicyNo, a.CityCode, to_char(TIMESTAMP(a.EffectiveDate),'YYYY-MM-DD HH24:MI:SS'), to_char(TIMESTAMP(a.ExpireDate),'YYYY-MM-DD HH24:MI:SS')
			from CACMain_NCPX a, CACMain_NCPPostpone b
			where b.LastPolicyConfirmNo is not null and a.LastPolicyConfirmNo = b.LastPolicyConfirmNo and b.CompanyCode = '${company}'"			
		
			
done




#把密码存入map中

declare -A map=();
 while read line
do	
	 key=`echo ${line} | cut -d " " -f1`
    value=`echo ${line} | cut -d " " -f2`
	if [  -z "$key" ]
    then
		echo ""
	else
		if [  -z "$value" ]
		then
			echo ""
		else
			map["${key}"]="${value}"
		fi
    fi

done < ${_PASSPATH}


#######开始进行吧压缩包加密
cd ${_DATAPATH2}
filelist=$(ls)
for file in $filelist
do
	if [ -d $file ]
	then
	   
	#echo "请输入${file}的密码 ->"|tr -d "\012"
   # read _PASS
   
	
	#echo "${file} 12346" >> ${_PASSPATH}
	
	zip -rP  ${map[${file}]}  ${file}.zip  ${file}
	#echo "zip -rP  ${map[${file}]}}  ${file}.zip  ${file}"
	fi
done


	
	


################请按照需求书写sql####################

db2 terminate

echo "结束时间"
date
echo "==============================================="
}			
			
times=`date +%s`
main | tee -a Log/9-dml_${times}.log

