*Prepare outpatient data for HRG goup;

*Pull in appointments data;
proc sql;
	create table appointments1 as
		select * from raw.hesop_appointment_17_150r inner join rev.&cohort. on &cohort..patid=hesop_appointment_17_150r.patid
			where HES_yr = &year. and attended not in (0,3); *remove DNAs: 3-DNA, 0-appt.;
run;

*Pull in clinical info;
proc sql;
	create table clinical1 as
		select * from raw.hesop_clinical_17_150r
			where HES_yr = &year.;
run;

*Join it all together and add unique identifier (patidattendkey);
proc sql;
	create table rev.op_data&year. as
		select *, monotonic() as id 
			from appointments1 left join clinical1 on appointments1.patid = clinical1.patid and appointments1.attendkey = clinical1.attendkey;
run;

*Set up table for HRG grouper;
proc sql;
	create table hrg as
		select apptage as STARTAGE, sex as SEX, mainspef as MAINSPEF, tretspef as TRETSPEF, firstatt as FIRSTATT,
			case when opertn_01 = '-' then '' else opertn_01 end as OPER_01,
				opertn_02 as OPER_02, opertn_03 as OPER_03, opertn_04 as OPER_04, opertn_05 as OPER_05, opertn_06 as OPER_06,
				opertn_07 as OPER_07, opertn_08 as OPER_08, opertn_09 as OPER_09, opertn_10 as OPER_10, opertn_11 as OPER_11,
				opertn_12 as OPER_12, id as dummy_field 
					from rev.op_data&year.;
run;

*Export to csv for use in the HRG grouper;
proc export data=hrg outfile="&rev_path.OP_HRG&year..csv" dbms=csv replace;
run;


*RUN THE HRG GROUPER FOR NAC USING THE ABOVE FILE;
