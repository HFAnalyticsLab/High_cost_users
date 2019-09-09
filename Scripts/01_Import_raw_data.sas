*Code to import raw text files and save as single SAS datasets;
*Be warned - it can take a long time to run! - See note on Test files in the proc import below;

*Import original CPRD datasets;
%macro readin(datasets, numfileslist);

%do i = 1 %to %sysfunc(countw(&datasets.)); *for each data set...;
	%let dataset = %scan(&datasets., &i.); *extract current data set;
	%let numfiles = %scan(&numfileslist., &i.); *extract number of files for current data set from list;
	%let path = &path_cprd;

	%if &dataset = Therapy %then %let path = &path_therapy; *deal with different text file location for Therapy;
	
	%do j=1 %to &numfiles; *for each file... import the data;
		proc import datafile = "&path.17_150R_Extract_&dataset._00&j..txt" dbms=tab out=data&j replace ; 
			guessingrows=100000; 
			*Note: Test was problematic because of varying formats of very sparse data in particular variables;
			*As a result, Test was imported using the Stat/Transfer programme to save time (but this code could be used overnight with guessingrows set to max);
		run;
	%end;

	data raw.extract_&dataset.; *save the data to the raw folder;
		set data1-data&numfiles.;
	run;

%end;

%mend readin;
%readin(&datasets, &numfileslist);


*Join together the Test files imported with Stat/Transfer;
data raw.extract_test;
	set testdata.test1-testdata.test6;
run;


*Import linked HES and miscellaneous data;
*----------------------------------------;
/*
misc: patient_imd2015_17_150R death_patient_17_150R
A&E: hesae_attendance_17_150r hesae_investigation_17_150r hesae_treatment_17_150r
APC: hes_episode_17_150r hes_ccare_17_150r hes_procedures_epi_17_150r hes_diagnosis_epi_17_150r
OP: hesop_appointment_17_150r hesop_clinical_17_150r

*Note: hesop_clinical_17_150r was problematic, and so imported separately using Stat/Transfer;
*/

*Set constants;
%let datasets = patient_imd2015_17_150R death_patient_17_150R hesae_attendance_17_150r hesae_investigation_17_150r hesae_treatment_17_150r 
	hes_episodes_17_150r hes_ccare_17_150r hes_procedures_epi_17_150r hes_diagnosis_epi_17_150r 
	hesop_appointment_17_150r ;

*Import original HES datasets;
%macro readin(datasets);

	%do i = 1 %to %sysfunc(countw(&datasets.)); *for each data set...;

		%let dataset = %scan(&datasets., &i.); *extract current data set;
		%let path = &path_linked;
	
		proc import datafile="&path.&dataset..txt" dbms=tab out=raw.&dataset. replace ; 
			guessingrows=100000;
			*Note: hesop_clinical_17_150r was problematic, and so imported separately using Stat/Transfer;
		run;

	%end;

%mend readin;
%readin(&datasets);

