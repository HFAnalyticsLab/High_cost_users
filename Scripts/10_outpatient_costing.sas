*AFTER RUNNING HRG GROUER - Import resulting csv from HRG grouper and cost;

*Import cost reference files;
*NHS Improvement Reference Costs from improvement.nhs.uk/resources/reference-costs/;

proc import datafile="&costs_path.NAC_CL_HRG_Costs_&hrgyear..csv" dbms=csv 
	out=clcosts replace; 
	guessingrows=100000;
run;

proc import datafile="&costs_path.NAC_NCL_HRG_Costs_&hrgyear..csv" dbms=csv 
	out=nclcosts replace;
	guessingrows=100000;
run;

data prcosts; *this one imports with a different variable format for Spec_Code, so need to harmonise;
	infile "&costs_path.NAC_OPROC_HRG_Costs_&hrgyear..csv" delimiter="," 
		dsd missover firstobs=2;
	input HRG_CODE $ HRG_Description $ Spec_Code $ Spec_Description $ CL_HRG_Cost NCL_HRG_Cost;
run;

proc import datafile="&costs_path.NAC_UNBUNDLED_HRG_Costs_&hrgyear..csv" dbms=csv 
	out=ubcosts replace;
	guessingrows=100000;
run;

*Merge CL and NCL costs together;
proc sort data=clcosts;
	by HRG_CODE Spec_Code;
run;

proc sort data=nclcosts;
	by HRG_CODE Spec_Code;
run;

data refcosts1;
	merge clcosts nclcosts;
	by HRG_CODE Spec_Code;
run;

*Append on PR and UB costs and save to folder;
data rev.op_refcosts&hrgyear.;
	set refcosts1 prcosts ubcosts;
	check=cat(HRG_CODE,Spec_Code); *ensure combinations are unique;
run;


*Import grouper results - renaming unheaded unbundled HRGs (there are different numbers in different years);
proc import datafile="&hrg_path.OP_&year._grouper_results_attend.csv" 
	out=hrgout1(rename=(UnbundledHRGs=UnbundledHRG1 var42-var46=UnbundledHRG2-UnbundledHRG6)) replace;
	guessingrows=100000;
run;

*Add in missing unbundled columns for 2015 grouper results, so later code works;
data hrgout2;
	set hrgout1;
	if &year.=2015 then UnbundledHRG2="";
	if &year.=2015 then UnbundledHRG6="";
run;

*Join necessary characteristics back on from attendances data, and exclude ungrouped (U-error) records;
proc sql; 
	create table hrgout3 as
		select op_data&year..id, patid, stafftyp, hrgout2.*  from	
			rev.op_data&year. inner join hrgout2 on op_data&year..id=hrgout2.dummy_field
				where GroupingMethodFlag <> 'U';
quit;


*Edit HRG grouper output;
*...where GroupingMethod is "G" (Global Exception), the costs come from the unbundled table, which has no Spec_Code, so wipe it for these records;
data hrgout4;
	set hrgout3;
	format Spec_Code $3.;
	if GroupingMethodFlag="G" then Spec_Code = "";
	else Spec_Code=TretSpef;
run;

*Join costs onto HRG grouper output;
*...join for unbundled codes is just on HRG code and there is no price difference between CL and NCL, so just use CL;
proc sql;
	create table costs1 as 
		select hrgout4.*, ref1.CL_HRG_Cost as clcost, ref1.NCL_HRG_Cost as nclcost, 
			ref2.CL_HRG_Cost as ubcost1, ref3.CL_HRG_Cost as ubcost2, ref4.CL_HRG_Cost as ubcost3,
			ref5.CL_HRG_Cost as ubcost4, ref6.CL_HRG_Cost as ubcost5, ref7.CL_HRG_Cost as ubcost6
				from hrgout4 left join rev.op_refcosts&hrgyear. as ref1 on hrgout4.NAC_HRG = ref1.HRG_Code and hrgout4.Spec_Code = ref1.Spec_Code
					left join rev.op_refcosts&hrgyear. as ref2 on hrgout4.UnbundledHRG1 = ref2.HRG_Code
					left join rev.op_refcosts&hrgyear. as ref3 on hrgout4.UnbundledHRG2 = ref3.HRG_Code
					left join rev.op_refcosts&hrgyear. as ref4 on hrgout4.UnbundledHRG3 = ref4.HRG_Code
					left join rev.op_refcosts&hrgyear. as ref5 on hrgout4.UnbundledHRG4 = ref5.HRG_Code
					left join rev.op_refcosts&hrgyear. as ref6 on hrgout4.UnbundledHRG5 = ref6.HRG_Code
					left join rev.op_refcosts&hrgyear. as ref7 on hrgout4.UnbundledHRG6 = ref7.HRG_Code;
quit;

*Calculate costs - main dependent on stafftyp, and then sum up main and unbundled to total;
*...where stafftyp is 99 (unknown) we've assumed consultant - only for stafftyp=4 is non-consultant cost used;
data costs2;
	set costs1;
	format maincost best32.; format totcost best32.;
	if stafftyp=4 then maincost=nclcost;
	else maincost=clcost;
	cost=sum(maincost, ubcost1, ubcost2, ubcost3, ubcost4, ubcost5, ubcost6);
	if cost=. then cost=0;
run;

*Check costing;
*The records which are not costed (in addition to failed HRG codes) are due to there being
no cost data for particular combinations of HRG, specialism and staff type;

proc sql;
	create table costchk1 as
	select case when cost>0 then 1 else 0 end as costed from costs2;
quit;

proc sql;
	create table costchk2 as	
	select costed, count(*) from costchk1 group by costed;
quit;


*Create patient level costs and attendances for only those records where we can cost the attendance;
proc sql;
	create table costs3 as
		select patid, count(*) as attendances, sum(cost) as sumcost 
			from costs2 where cost>0 group by patid;
quit;

*Join onto cohort data and save to folder;
proc sql;
	create table rev.op_cost_&hrgyear. as
		select &cohort..patid, case when attendances=. then 0 else attendances end as attends,
			case when sumcost=. then 0 else sumcost end as totcost 
				from rev.&cohort. left join costs3 on &cohort..patid=costs3.patid;
quit;

