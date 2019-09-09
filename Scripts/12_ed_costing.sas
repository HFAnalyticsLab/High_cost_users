*AFTER RUNNING HRG GROUER - Import resulting csv from HRG grouper and cost;

*Import grouper results;
proc import datafile="&hrg_path.AE_&year._grouper_results_attend.csv" dbms=csv
	out=grouper_results(rename=(dummy_field=patidaekey)) replace;
	guessingrows=100000;
run;

*Import cost reference file;
*NHS Improvement Reference Costs from improvement.nhs.uk/resources/reference-costs/;

proc import datafile="&costs_path.em_hrg_&hrgyear._costs.csv" dbms=csv
	out=refcosts(rename=('Currency Code'n=em_hrg)) replace;
run;

*Join grouper results and reference costs onto AE data;
proc sql;
	create table hrg1 as
		select ae_data&year..*, grouper_results.em_hrg, refcosts.* 
			from rev.ae_data&year. inner join grouper_results on ae_data&year..patidaekey=grouper_results.patidaekey
				left join refcosts on refcosts.em_hrg=grouper_results.em_hrg
					order by patid, ae_data&year..patidaekey;
quit;

*Add variables to identify admission and ambulance arrival;
data hrg2;
	set hrg1;
		format ambulance 1.; format admission 1.;
		if aearrivalmode=1 then ambulance=1; else ambulance=0;
		if aeattenddisp=1 then admission=1; else admission=0;
run;

*Cost the A&E records according to department, admission and ambulance arrival;
data aecost1;
	set hrg2;
	format cost best32.;
	if aedepttype=1 and admission=0 then cost=(Type_01_NON_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=1 and admission=1 then cost=(Type_01_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=2 and admission=0 then cost=(Type_02_NON_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=2 and admission=1 then cost=(Type_02_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=3 and admission=0 then cost=(Type_03_NON_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=3 and admission=1 then cost=(Type_03_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=4 and admission=0 then cost=(Type_04_NON_admitted_COST + (ambulance * &convey_cost.));
	else if aedepttype=4 and admission=1 then cost=(Type_04_admitted_COST + (ambulance * &convey_cost.));
	else cost=.;
run;

*Check how many records have been costed;
proc sql;
	create table costcheck as
		select case when cost>0 then 1 else 0 end as costed from aecost1 group by costed;
quit;

proc sql;
	create table costcheck1 as
		select costed, count(*) from costcheck group by costed;
quit;

*Summarise costs and attendances (retain only costed records);
proc sql;
	create table aecost2 as
		select patid, count(*) as attendances, sum(cost) as sumcost 
			from aecost1 where cost>0 group by patid;
run;

*Join costs and attendances onto cohort data, inflate to 2015/16 prices and save to folder;
proc sql;
	create table rev.ae_cost_&hrgyear. as	
		select &cohort..patid, 
			case when attendances =. then attendances=0 else attendances end as attends, 
			case when sumcost =. then sumcost=0 else sumcost end as totcost 
				from rev.&cohort. left join aecost2 on &cohort..patid=aecost2.patid;
quit;
