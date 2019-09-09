*Allocate libnames;
libname raw "...\SAS\Data\raw\"; *raw imported data;
libname testdata "...\SAS\Data\raw\test\"; *test data;
libname rev "...\SAS\Data\revised\"; *revised data;
libname multimor "...\SAS\Data\revised\multimorbidity\"; *multimorbidity data;
libname lookup "...\lookup\"; *lookup files;

*Set path files to save results;
data _null_;
	%let rev_path = ...\SAS\Data\revised\; *revised data;
	%let cprdcam_path = ...\CPRDCAM\;
	%let hrg_path = ...\SAS\Data\revised\Grouper results\;
	%let costs_path = ...\HES\HRG reference costs\;
run;

*Set path files for raw data;
data _null_;
	%let datasets = Clinical Consultation Patient Practice Staff Therapy; *actual names of original data sets (exluding any common parts);
	%let numfileslist = 6 6 1 1 1 7; *number of original data files for each data set;
	%let path_cprd = ...\17_150R\Data\CPRD GOLD Data\; *Set file path for raw data;
	%let path_therapy = ...\17_150R\Data\CPRD GOLD Data\17_150_rextract_therapy_files\; *Set file path for raw data;
	%let path_linked = ...\17_150R\Data\Linked Data\; *Set file path for raw data;
run;

*Setting variables;
data _null_;
	%let cohort = patient1415;
	%let startdate = '01apr2014'd;
	%let enddate = '01apr2015'd;
	%let year = 2014;
	%let hrgyear = 1415;
	%let endyear = 2015;
	%let convey_cost = 233.020000687171; *1415 reference cost for A&E conveyance = £233.02;
run;



