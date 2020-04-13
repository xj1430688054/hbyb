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
#_DBNAME=iaca42db	
echo ""    
echo "���������ݿ��û� ->"|tr -d "\012"
    read _DBUSER
#_DBUSER=instiaci	
echo ""    	
echo "���������ݿ��û����� ->"|tr -d "\012"
    read _PWD
#_PWD=password	
echo ""    
echo "������schema�� ->"|tr -d "\012"
    read _SCHEMA
#_SCHEMA=instiaci


db2 connect to ${_DBNAME} user ${_DBUSER}   using ${_PWD}
db2 set schema=${_SCHEMA}


################���ϲ��ֲ������޸�        ###############
#���������»��߿�ʼ�����²��ֿ�����Ա�������޸ģ������������Ҫ�Ĳ���
################���½ű�������ʵ������޸�###############
####ȡ��������������������ʱ��
#_LASTDATE=`db2 -x "select a.INPUTDATE  from cacmain_ncp a  order by a.INPUTDATE desc    fetch first 1 row only"`

echo ""    
echo "�������ϴ�����ʱ�䣨���� 2020-01-23 12:00:00  �� ->"|tr -d "\012"
    read _LASTDATE

####ȡ����ǰ������ʱ��
_INPUTTIME=`db2 -x "select to_char(current timestamp,'yyyy-mm-dd hh24:mi:ss') from sysibm.dual"`

################�밴��������дsql####################


echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------��ȡͶ��ȷ�������ϴ���������º��-------------------"
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
echo "-------��ȡ����ȷ����ʱ�����ϴκ�Ĳ�����-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

PPOLICYCONFIRMNOS=`db2 -x "select distinct CONFIRMSEQUENCENO  from CAPHead where confirmdate >= '${_LASTDATE}' "`

echo "${PPOLICYCONFIRMNOS}"
##����ɵķָ���
OLD_IFS="$IFS"
##�ָ������óɿո�
IFS=" "
array=($PPOLICYCONFIRMNOS)
##���ԭ���ķָ���
IFS="$OLD_IFS"

###��������������ѯ�鱨��
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

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4_iaca_dml_zengliang_${times}.log

