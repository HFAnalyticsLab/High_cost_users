*AFTER RUNNING HRG GROUER - Import resulting csv from HRG grouper and cost inpatient spells;

*Import cost reference files;
*NHS Improvement Reference Costs from improvement.nhs.uk/resources/reference-costs/;
*Import Main HRG costs;
proc import datafile="&costs_path.APC_HRG_COSTS_&hrgyear..csv" dbms=csv 
	out=costs(rename=(HRG_Code=SpellHRG)) replace;
	guessingrows=100000;
run;

*Import unbundled costs;
proc import datafile="&costs_path.APC_UNBUND_&hrgyear..csv" dbms=csv
	out=costs_ub replace;
	guessingrows=100000;
run;

*Import grouper results - include first 10 unbundled HRGs;
proc import datafile="&hrg_path.APC_&year._grouper_results_spell.csv" dbms=csv
	out=hrgout1 (rename=(UnbundledHRGs=UnbundledHRG1 var41-var49=UnbundledHRG2-UnbundledHRG10)) replace;
	guessingrows=100000;  
run;

*Edit unbundled HRG codes;
data hrgout2;
	set hrgout1;
	array arr1 UnbundledHRG1-UnbundledHRG10;
	do over arr1;
		arr1=substr(arr1,1,5); *remove and ignore 'multiplied by 1/2/3/etc.' ('*1','*2',etc.) added to end of unbundled HRGs;
		*(this occurs in the data quite a lot for some reason, but almost all values are multiplied by 1);
	end;
run;

*Import first episode of each spell to categorise the spell;
data spell1; 
	set raw.hes_episodes_17_150r(keep=patid spno admidate discharged admimeth classpat eorder);
	where  discharged >= &startdate. AND discharged < &enddate. AND discharged >= admidate AND eorder=1 ;
	admin_cat = input(substr(admimeth, 1, 1), 1.); *extract type of admission from admimeth (input as a numeric format variable);
run;

*Characterise type of admission using admin_cat and classpat;
data spell2 (keep=patid provspno elective emergency day_case reg mat uncat);
	set spell1;
	elective = 0; emergency = 0; day_case = 0;
	reg = 0; mat = 0; uncat = 0;
	if admin_cat = 1 and classpat = 1 then elective=1;
	if admin_cat = 2 and classpat = 1 then emergency = 1;
	if classpat = 2 then day_case = 1;
	if classpat = 3 or classpat = 4 then reg = 1;
	if classpat = 5 or classpat = 8 then mat = 1;
	if sum(elective, emergency, day_case, reg, mat) = 0 then uncat = 1;
	rename spno=provspno;
run;


*Join everything together;
proc sql;
	create table cost1 as 
		select &cohort..patid, spell2.*, hrgout2.*, costs.*, 
			ub1.el_cost as ubc1, ub2.el_cost as ubc2, ub3.el_cost as ubc3, ub4.el_cost as ubc4, ub5.el_cost as ubc5, 
			ub6.el_cost as ubc6, ub7.el_cost as ubc7, ub8.el_cost as ubc8, ub9.el_cost as ubc9, ub10.el_cost as ubc10 
				from rev.&cohort. inner join spell2 on &cohort..patid=spell2.patid
				left join hrgout2 on spell2.provspno=hrgout2.provspno
				left join costs on hrgout2.spellhrg=costs.spellhrg
				left join costs_ub as ub1 on hrgout2.UnbundledHRG1=ub1.HRG_code
				left join costs_ub as ub2 on hrgout2.UnbundledHRG2=ub2.HRG_code
				left join costs_ub as ub3 on hrgout2.UnbundledHRG3=ub3.HRG_code
				left join costs_ub as ub4 on hrgout2.UnbundledHRG4=ub4.HRG_code
				left join costs_ub as ub5 on hrgout2.UnbundledHRG5=ub5.HRG_code
				left join costs_ub as ub6 on hrgout2.UnbundledHRG6=ub6.HRG_code
				left join costs_ub as ub7 on hrgout2.UnbundledHRG7=ub7.HRG_code
				left join costs_ub as ub8 on hrgout2.UnbundledHRG8=ub8.HRG_code
				left join costs_ub as ub9 on hrgout2.UnbundledHRG9=ub9.HRG_code
				left join costs_ub as ub10 on hrgout2.UnbundledHRG10=ub10.HRG_code	;
quit;

*Calculate costs;
data rev.apc_data&year. (keep=patid provspno spellpdiag elective emergency day_case reg mat uncat spelllos cost ubcost costs where=(costs>0)); *exclude any that can't be costed;
	set cost1;
	format cost best32.; format ubcost best32;
	if elective=1 then cost = sum(el_cost , (spellexcessbeddays * el_xs_cost));
	else if emergency=1 and spelllos=0 then cost = sum(nes_cost , (spellexcessbeddays * nel_xs_cost));
	else if emergency=1 and spelllos>0 then cost = sum(nel_cost , (spellexcessbeddays * nel_xs_cost));
	else if day_case=1 then cost = dc_cost;
	else if reg=1 then cost = rp_cost;
	else if mat=1 then cost = matern_cost; *this cost is just the overall average for the HRG (in the "Total HRG's" sheet of the original data);
	else if uncat=1 then cost = matern_cost; *if not categorised, use the overall average cost for the HRG;
	else cost=.;
	ubcost = sum(ubc1, ubc2, ubc3, ubc4, ubc5, ubc6, ubc7, ubc8, ubc9, ubc10);
	costs = sum(cost, ubcost);
	where spellgroupingmethodflag<>"U"; *exclude any where HRG grouping failed;
run;







