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
_LASTDATE=`db2 -x "select a.INPUTDATE  from cacmain_ncp a  order by a.INPUTDATE desc    fetch first 1 row only"`



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
		current timestamp , 
		null
	 from   cacmain a
	 inner join CACVehicle b on a.CONFIRMSEQUENCENO=b.CONFIRMSEQUENCENO
								and a.ValidStatus ='1'
								and a.ConfirmDate  >= '${_LASTDATE}'
	 left join cacmain_ncp c on a.LASTPOLICYCONFIRMNO = c.CONFIRMSEQUENCENO
							and c.flag = '1'

	 "

	 

echo "------------------------------------------------------------"
echo "------------------------------------------------------------"
echo "-------��ȡ����ȷ����ʱ�����ϴκ�Ĳ�����-------------------"
echo "------------------------------------------------------------"
echo "------------------------------------------------------------"

db2 "update cacmain_ncp d
		set ( 
			a.POLICYNO, 
			a.COMPANYCODE, 
			a.CITYCODE, 
			a.EFFECTIVEDATE, 
			a.EXPIREDATE, 
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
					current timestamp , 
				from   cacmain a 
				inner join CACVehicle b on a.CONFIRMSEQUENCENO = b.CONFIRMSEQUENCENO 
				inner join cacmain_ncp e on a.CONFIRMSEQUENCENO = e.CONFIRMSEQUENCENO and e.flag = ''
				inner join caphead f on f.CONFIRMSEQUENCENO = a.CONFIRMSEQUENCENO and f.confirmdate >= '${_LASTDATE}'
				where a.CONFIRMSEQUENCENO = d.CONFIRMSEQUENCENO				"



db2 terminate

echo "����ʱ��"
date
echo "==============================================="
}
times=`date +%s`
main | tee -a Log/4_iaca_dml_zengliang_${times}.log

