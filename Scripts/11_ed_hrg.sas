*Prepare A&E data for HRG goup;

*Get A&E attendances data from raw files;
proc sql;
	create table attendances1 as
		select patid, aekey, aepatgroup, aearrivalmode,	aeattenddisp, aedepttype, arrivaldate, 
			year(arrivaldate) as year, month(arrivaldate) as month, &year as HES_yr
				from raw.hesae_attendance_17_150r
					where ((year(arrivaldate) in (&endyear.) and month(arrivaldate) in (1,2,3))
						OR (year(arrivaldate) in (&year.) and month(arrivaldate) in (4,5,6,7,8,9,10,11,12)));
run;

*Add age column from saved patient data;
proc sql;
	create table attendances2 as
		select attendances1.*, startage as age
			from rev.&cohort. inner join attendances1 on &cohort..patid = attendances1.patid;
run;

*Get investigation data;
proc sql;
	create table investigation1 as
		select patid, aekey, invest2 
			from raw.hesae_investigation_17_150r
				order by patid, aekey, invest_order;
run;

*Transpose data;
proc transpose data=investigation1 out=invest_final(drop=_NAME_) prefix=inv_ ;
	by patid aekey;
	var invest2;
run;

*Get treatment data from raw file;
proc sql;
	create table treat as
		select patid, aekey, treat3
			from raw.hesae_treatment_17_150r
				order by patid, aekey, treat_order;
run;

*Transpose data;
proc transpose data=treat out=treat_final(drop=_NAME_) prefix=treat_ ;
	by patid aekey;
	var treat3;
run;

*Join together attendances, investigations and treatments, add patid-aekey unique identifier and save to folder;
proc sql;
	create table rev.ae_data&year. as
		select *, catx("-",attendances2.patid,attendances2.aekey) as patidaekey
			from attendances2 left join invest_final on attendances2.patid = invest_final.patid and attendances2.aekey = invest_final.aekey
				left join treat_final on attendances2.patid = treat_final.patid and attendances2.aekey = treat_final.aekey;
run;


*Set up data table for grouper, add identifying field (patid-aekey);
proc sql;
	create table ae_hrg as
		select age,	aepatgroup as AEPATIENTGROUP,
			inv_1 as INV_01, inv_2 as INV_02, inv_3 as INV_03, inv_4 as INV_04, inv_5 as INV_05, inv_6 as INV_06,
			inv_7 as INV_07, inv_8 as INV_08, inv_9 as INV_09, inv_10 as INV_10, inv_11 as INV_11, inv_12 as INV_12,
				treat_1 as TREAT_01, treat_2 as TREAT_02, treat_3 as TREAT_03, treat_4 as TREAT_04, treat_5 as TREAT_05, treat_6 as TREAT_06,
				treat_7 as TREAT_07, treat_8 as TREAT_08, treat_9 as TREAT_09, treat_10 as TREAT_10, treat_11 as TREAT_11, treat_12 as TREAT_12,
					patidaekey as dummy_field
						from rev.ae_data&year.;
run;

proc export data=ae_hrg outfile="&rev_path.AE_HRG&year..csv"	dbms=csv replace;
run;


*RUN THE HRG GROUPER FOR A&E USING THE ABOVE FILE;