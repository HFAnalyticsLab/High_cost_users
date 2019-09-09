*Preparing inpatient data for HRG grouping;

*Pull in raw episodes data;
data episodes1 (keep=patid epikey procodet provspno epiorder classpat admisorc admimeth disdest dismeth epidur mainspef neocare tretspef rehabilitationdays spcdays ID); 
	set raw.hes_episodes_17_150r;
	where  discharged >= &startdate. and discharged < &enddate. and discharged >= admidate;
	retain patid spno epikey eorder classpat admisorc admimeth disdest dismeth epidur mainspef tretspef;
	rename eorder = epiorder;
	rename spno=provspno;
	format procodet $3.; format rehabilitationdays 24.; format spcdays 24.; format neocare 24.;
	procodet = "RJ1"; *Set to random trust because we do not have it - does not affect HRG grouping;
	rehabilitationdays = 0; *We are not analysing rehabilitation;
	if (mainspef = 315 and tretspef = 315) or (mainspef = 950 and tretspef = 315) or (mainspef = 960 and tretspef = 315) then spcdays = epidur; *Palliative care days;
	else spcdays = 0;
	neocare=8; *Neonatal care not relevant for our data, so set to 8 'not applicable';
	ID=catx("-", patid, spno, epikey);
run;


*Pull in raw critical care data;
data critical1 (keep=patid spno epikey criticalcaredays ID);
	set raw.hes_ccare_17_150R ;
	where  discharged >= &startdate. AND discharged < &enddate. AND discharged >= admidate ; *select critical care data based on spell dates;
	format criticalcaredays 24.;
	criticalcaredays = ccdisdate - ccstartdate; *Count up only the critical care days;
	ID=catx("-", patid, spno, epikey);
run;


*Pull in raw procedures data;
data procedures1; 
	set raw.hes_procedures_epi_17_150r;
	where  discharged >= &startdate. AND discharged < &enddate. AND discharged >= admidate ; *select procedures data based on spell dates;
	ID=catx("-", patid, spno, epikey);
run;

*Sort the data, ready for transposing;
proc sort data=procedures1;
	by patid spno epikey p_order;
run;

*Transpose so in wide format for grouper;
proc transpose data=procedures1 out=procedures2 (keep=patid spno epikey ID OPER_1-OPER_9 OPER_10-OPER_12 rename=(OPER_1-OPER_9=OPER_01-OPER_09)) prefix=OPER_;
	by patid spno epikey ID;
	var OPCS;
run;


*Pull in raw diagnosis data and clean up ICD-10 codes;
data diagnoses1; 
	set raw.hes_diagnosis_epi_17_150r;
	ICD2 = Compress(ICD,"."); *remove decimal points from ICD;
	ICDy = Compress(ICDx, ,"p")  ; *remove all punctuation characters from ICDx field;
	ICD3 = cats(ICD2,ICDy,"X"); *add 'X' to code (for when only a 3 character ICD code is present);
	ICD4 = substr(ICD3, 1, 4); *trim it all to 4 characters;
	ID=catx("-", patid, spno, epikey);
run;

*Sort data before transpose;
proc sort data=diagnoses1;
	by patid spno epikey d_order;
run;

*Transpose data;
proc transpose data=diagnoses1 out=diagnoses2(keep=patid spno epikey ID DIAG_1- DIAG_9 DIAG_10-DIAG_14 rename=(DIAG_1-DIAG_9=DIAG_01-DIAG_09)) prefix=DIAG_;
	by patid spno epikey ID;
	var ICD4;
run;

*Join on cohort, critical care, procedures and diagnoses information;
proc sql;
	create table apc1 as
		select * from rev.&cohort.
			inner join episodes1 on &cohort..patid=episodes1.patid
			left join critical1 on episodes1.ID=critical1.ID
			left join procedures2 on episodes1.ID=procedures2.ID
			left join diagnoses2 on episodes1.ID=diagnoses2.ID;
quit;

*Prepare data for grouper;
data apc2(keep=procodet provspno epiorder startage sex classpat admisorc admimeth disdest dismeth epidur mainspef neocare tretspef
		DIAG_01-DIAG_14	OPER_01-OPER_12 CRITICALCAREDAYS REHABILITATIONDAYS SPCDAYS ID); 
	*RETAIN statement is used to ensure the position of variables;
	retain procodet provspno epiorder startage sex classpat admisorc admimeth disdest dismeth epidur mainspef neocare tretspef
		DIAG_01-DIAG_14	OPER_01-OPER_12 CRITICALCAREDAYS REHABILITATIONDAYS SPCDAYS ID;
	set apc1;
	array arr1 criticalcaredays rehabilitationdays spcdays;
	do over arr1;
		if arr1=. then arr1=0; *set any missing values in the day counts to zero;
	end;
run;

*Sort data before saving;
proc sort data=apc2;
	by ID;
run;

*Save dataset which will be fed into the grouper;
proc export data=apc2
	outfile="&rev_path.APC_HRG&year..csv" dbms=csv replace;
run;

*RUN THE HRG GROUPER FOR APC USING THE ABOVE FILE;
