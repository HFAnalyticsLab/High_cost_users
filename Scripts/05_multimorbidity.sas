*Multimorbidty using the Cambridge Multimorbidity Index (37 chronic conditions from Cassell et al. (2017));

*This consists of two code sections;
	*1) Data prep;
	*2) Processing;

%let cohortlist = 2014 2015; *list of variables from cohort dataset (which identify the different cohorts) sent to macro;
%let excludedeaths = no ; *control whether you want to return results excluding those patients who died during the follow-up (flagged in 'cohorts', see prep);

/******************* DATA PREP ********************/

*1 - Import CPRDCAM data;

*Medcodes;
proc import datafile="&cprdcam_path.medcodes.csv" dbms=csv 
	out=medcodes replace;
	guessingrows=100000;
run;

*Prodcodes;
proc import datafile="&cprdcam_path.prodcodes.csv" dbms=csv 
	out=prodcodes replace;
	guessingrows=100000;
run;

*The following columns were added in to the 'descriptions' table (G:\Projects\P036 Costing model CPRD\CPRDCAM\descriptions.csv),
by hand in Excel, based on the 'Usage Definition' field, and saved as 'edited_descriptions.csv';

/*
Field		Value	Description
-----		-----	-----------
read		1		specified read codes ever
read		2		specified read codes first recorded in last 5 years
read		3		specified read codes in the last year
prod		1		4 prescriptions in the last year
prod		2		any prescriptions in the last year
prod		3		any prescriptions ever
logic		AND		whether conditions need to be combined using AND logic
logic		OR		whether conditions need to be combined using OR logic
warning		yes		identifies morbidity codings that are particularly challenging
*/

*NB: The long text fields (Provenance, Links, Citations) were also deleted from the 'edited_descriptions.csv' table so that it would read into SAS without any problems;

*Import edited descriptions table;
proc import datafile="&cprdcam_path.edited_descriptions.csv" dbms=csv
	out=desc_edit(rename=('CONDITION.CODE'n=Condition)) replace;
	guessingrows=100000;
run;

*Get one logic rule per condition from desc_edit (so that joining logic on in processing does not create duplicate records);
proc sql;
	create table logicrules as 
		select Condition, logic, count(*) as count from desc_edit
			group by Condition, logic;
quit;


*2 - Sort and import clinical data, which contains patients' medcodes;

*Sort by eventdate;
proc sort data=raw.extract_clinical; 
	by eventdate;
run;

*Pull in data and add rownum to order dataset and deal with any eventdate ties later on;
data pre_clinical1 (keep=patid eventdate medcode rownum);
	set raw.extract_clinical;
	rownum=_n_;
	where eventdate ne .;
run;


*3 - Import therapy data, which contains patients' prodcodes;

*Pull in data;
data pre_therapy1 (keep=patid eventdate prodcode);
	set raw.extract_therapy;
	where eventdate ne .;
run;


*4 - Import test data, which contains patients' eGFR test values - used in the chronic kidney disease (CKD) condition;
*(Read Code ever recorded OR if the best (highest value) of the last 2 eGFR readings is < 60 mL/min);

*Pull in only the eGFR test values  (466 is the enttype code for eGFR);
data eGFR (keep=patid eventdate enttype data1-data7);
	set raw.extract_test;
	where enttype=466 AND data2 ne . AND eventdate ne . ;
run;


*5 - Sort out HCU England cohort data to identify each cohort;

*Pull in data and add variables: cohort startdate and year identifier;
data cohorts (keep = patid sex startage imd region died startdate year);
	set rev.patient1415;
	format startdate ddmmyy10.; startdate='01apr2014'd;
	format year 4.; year=2014;
run;

data cohort2 (keep = patid sex startage imd region died startdate year);
	set rev.patient1516;
	format startdate ddmmyy10.; startdate='01apr2015'd;
	format year 4.; year=2015;
run;

*Join the cohort data sets together;
proc append base=cohorts data=cohort2;
run;


/******************* DATA PROCESSING ********************/

*Process raw data, looping through cohorts, to create multimorbidity tables;
*--------------------------------------------------------------------------;

%macro process(cohortlist);
	
	%if &excludedeaths=yes %then %let deathcond=1; %else %let deathcond=2;
	
	%do i = 1 %to %sysfunc(countw(&cohortlist.)); *for each cohort group;

		%let group = %scan(&cohortlist., &i.); *Store current cohort group in &group. macro variable;
			
			*Read in cohort group and keep and rename variables to give cohort group dataset with only 'patid' and 'startdate' variables;
			data cohort (keep=patid startdate);
				set cohorts;
				where year=&group.;
			run;
		
			*Collate all fields required for sorting out medcodes (inner joins ensure only data for cohort group is returned);
			proc sql;
				create table pre_clinical2 as
					select pre_clinical1.patid, eventdate, rownum, startdate-eventdate as days, condition, medcodes.source, read
						from cohort inner join pre_clinical1 on cohort.patid=pre_clinical1.patid
							inner join medcodes on pre_clinical1.medcode=medcodes.medcode
								inner join desc_edit on medcodes.source=desc_edit.source
									where desc_edit.TYPE="MEDCODES" and startdate-eventdate > 0 
										order by pre_clinical1.patid, source, eventdate, rownum;
			quit;
			
			*Save condition into 'cond' if medcode criteria are met and retain most recent record of condition for each patient;
			proc sql;
				create table medcond as
					select pre_clinical2.* , 
						case when read=1 then condition 
							when read=2 and 0<days<=1826 then condition /*Note: only condition 'CAN' (cancer) has read code criteria=2*/
								when read=3 and 0<days<=365 then condition end as cond
									from pre_clinical2 group by patid, cond having rownum=max(rownum) AND cond<>"";
			quit;


			*Collate all fields required for sorting out prodcodes (inner joins ensure only data for cohort group is returned);
			proc sql;
				create table pre_therapy2 as
					select pre_therapy1.patid, eventdate, startdate-eventdate as days, condition, prodcodes.source, prod
						from cohort inner join pre_therapy1 on cohort.patid=pre_therapy1.patid
							inner join prodcodes on pre_therapy1.prodcode=prodcodes.prodcode
								inner join desc_edit on prodcodes.source=desc_edit.source
									where desc_edit.TYPE="PRODCODES" and startdate-eventdate > 0
										order by pre_therapy1.patid, source, eventdate;
			quit;
			
			*Save condition into 'cond' if prodcode criteria are met ('count' ensures only one row for each existing condition for each patient);
			proc sql;
				create table prodcond as
					select patid, prod, source,
						case when prod=1 and 0<days<=365 then condition 
							when prod=2 and 0<days<=365 then condition 
								when prod=3 then condition end as cond, count(*) as count
									from pre_therapy2 group by patid, prod, source, cond having ((prod=1 and count>=4) or prod=2 or prod=3) and  cond<>"";
			quit;

			*Combine medcond and prodcond tables;
			proc sql;
				create table allconds as 
					select patid, "MEDCODES" as data, cond from medcond 
						union
					select patid, "PRODCODES" as data, cond from prodcond;
			quit;

			*Join on logicrules and count the conditions meeting the rules;
			proc sql;
				create table countconds as
					select patid, cond, logic, count(*) as count
						from allconds inner join logicrules on Condition=cond 
							group by patid, cond, logic having logic<>"AND" or (logic="AND" and count=2);
			quit;


			*Dealing with Painful conditions (PNC), which are treated slightly differently to the rest...;
			*4 or more POM analgesics in last 12 months OR (4 or more specified anti-epileptics in last 12 months in the absence of an epilepsy Read code ever recorded);
			*(Analgesics are in source file PNC004, Anti-epileptics are in source file PNC079, Epilepsy read codes are in sourcefile EPI069);
			proc sql;
				create table pnc as
					select cohort.patid, "PNC" as PNC, count(*) as count
						from cohort left join medcond on cohort.patid=medcond.patid
							left join prodcond on cohort.patid=prodcond.patid
								where prodcond.source="PNC004" or (prodcond.source="PNC079" and medcond.cond<>"EPI")
									group by cohort.patid, pnc;
			quit;


			*Dealing with Chronic kidney disease (CKD), which is also treated slightly differently to the rest...;
			*Read Code ever recorded OR if the best (highest value) of the last 2 eGFR readings is < 60 mL/min;

			*Join eGFR data to cohort data and calculate days between eventdates and cohort start dates;
			proc sql;
				create table eGFR1 as
					select eGFR.patid, eventdate, startdate-eventdate as days, data2
						from eGFR inner join cohort on cohort.patid=eGFR.patid
							where startdate-eventdate>0 order by patid, eventdate desc;
			quit;

			*Add record number to identify last two tests;
			data eGFR2;
				set eGFR1;
				recnum + 1;
				by patid;
				if first.patid then recnum=1;
			run;
			
			*Identify whether both values of last two tests are below the normal range threshold;
			*DN: what about when they only have one test in their history? Currently, these people are not included in the CKD condition;
			*Does it matter that some test values may be very old? Currently, this issue is being ignored;
			proc sql;
				create table ckdtest as
					select patid, "CKD" as cond, count(*) as count 
						from eGFR2 where recnum<=2 and data2<60
							group by patid having count=2;
			quit;
		
			*Join CKD medcodes to test data;
			proc sql;
				create table ckd as
					select cohort.patid, "CKD" as CKD, count(*) as count
						from cohort left join ckdtest on cohort.patid=ckdtest.patid
							left join countconds on cohort.patid=countconds.patid
								where ckdtest.cond="CKD" or countconds.cond ="CKD" 
									group by cohort.patid;
			quit;


			*Join all the results together;
			proc sql;
				create table reslong as
					select patid, cond, logic, count, 1 as flag from countconds where cond<>"PNC" and cond<>"CKD"
						union select patid, "PNC" as cond, "OR" as logic, 1 as count, 1 as flag from pnc
							union select patid, "CKD" as cond, "OR" as logic, 1 as count, 1 as flag from ckd;
			quit;

			*Sort and transpose results;
			proc sort data=reslong;
				by patid;
			run;
			proc transpose data=reslong out=reswide(drop=_NAME_ rename=(patid=patidx)); *rename patid so that there is no warning in proc sql, below;
				var flag;
				id cond;
				by patid;
			run;

			*Ensure all cohort members are included in the output (even those with no identified conditions), and include death indicators;
			proc sql;
				create table reswidefull(drop=patidx) as select patid, reswide.* 
					from cohort left join reswide on cohort.patid=reswide.patidx;
			quit;

			*Fill-in blanks, add counts and save to folder;
			data multimor.morbidities&group.;
				set reswidefull;
				array vals _numeric_;
				do over vals;
					if vals = . then vals = 0;	
				end;
				format mental 2.; format physical 2.; format total 2.;
				mental = sum(ALC, ANO, ANX, DEM, DEP, LEA, OPS, SCZ); *8 mental health and learning disability conditions; 
				physical = sum(AST, ATR, BLI, BRO, CAN, CHD, CKD, CLD, CON, COP, DIB, DIV, EPI, HEF, HEL, HYP, IBD, IBS, MIG, MSC, PNC, PRK, PRO, PSO, PVD, RHE, SIN, STR, THY); *29 physical health conditions;
				total = sum(mental, physical); *37 total health conditions;
			run;
			
			*Create summary statistics and save to folder;
			proc univariate data=multimor.morbidities&group. outtable=multimor.sum&group.(keep=_VAR_ _NOBS_ _MEAN_) noprint ;
				var ALC ANO ANX DEM DEP EPI LEA MIG OPS PRK SCZ AST ATR BLI BRO CAN CHD CKD CLD CON 
					COP DIB DIV HEF HEL HYP IBD IBS MSC PNC PRO PSO PVD RHE SIN STR THY;
			run;
	%end;

%mend process;

%process(&cohortlist.);