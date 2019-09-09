*Create patient lists;

data patient;
	set raw.extract_patient (keep=patid gender yob deathdate tod toreason);
	format sex best8.;
	if gender = 1 then sex = 1;
	else if gender = 2 then sex = 2;
	else if gender = 3 then sex = 9;
	else sex = 0;
	format startage1 best8.;
	format startage2 best8.;
	startage1 = 2014 - yob;
	startage2 = 2015 - yob;
run;

data IMD; 
	set RAW.PATIENT_IMD2015_17_150R;
run;

data practice;
	set raw.extract_practice;
run;

data death;
	set raw.death_patient_17_150r;
run;

*Merge datasets onto patients file;
proc sql;
	create table patimdprac as	
		select patient.*, practice.pracid, region, imd2015_10 as imd, dod from	
			patient left join imd on imd.patid=patient.patid
					left join practice on practice.pracid=imd.pracid
					left join death on death.patid=patient.patid ;
quit;

*Make edits to data;
data patientmerge; 
	set patimdprac(keep=patid sex startage1 startage2 deathdate tod toreason pracid region imd dod);
		if dod=. then dod=deathdate;
		yeardied = year(intnx('YEAR.4',dod,0));
		yeartrans = year(intnx('YEAR.4',tod,0));
		if toreason=1 then yeartrans = . ; *don't want to record transfer out year if the reason was death;
run;


data rev.patient1415 (keep=patid sex startage imd pracid region yeardied yeartrans died); 
	set patientmerge;
	rename startage1=startage;
	if yeardied=2014 then died=1;
	else died=0;
	if yeardied=. then yeardied=9999; *use high number so we can use this field in 'where' conditions;
	if yeartrans=. then yeartrans=9999; *use high number so we can use this field in 'where' conditions;
run;

data rev.patient1516 (keep=patid sex startage imd pracid region yeardied yeartrans died); 
	set patientmerge;
	rename startage2=startage;
	if yeardied=2015 then died=1;
	else died=0;
	if yeardied=. then yeardied=9999; *use high number so we can use this field in 'where' conditions;
	if yeartrans=. then yeartrans=9999; *use high number so we can use this field in 'where' conditions;
run;




