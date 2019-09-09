*Merge all costs together;

data _null_;
	%let patient = patient&hrgyear.;
	%let ipcost = apc_cost_&hrgyear.;
	%let aecost = ae_cost_&hrgyear.;
	%let opcost = op_cost_&hrgyear.;
	%let pccost = pccost_&hrgyear.;
	%let therapy = therapy_&hrgyear.;
	%let finalcosts = finalcosts_&hrgyear.;
run;

*Join the tables all onto the patient data;
proc sql; *this code does lead to irrelevant warnings relating to the multiple instances of patid returned;
	create table allcosts1 as
		select &patient..*, &ipcost..*, &aecost..attends as aeatts, &aecost..totcost as aetotcost, 
			&opcost..attends as opatts, &opcost..totcost as optotcost, &pccost..pcontacts, &pccost..pcost as ptotcost,
			&therapy..*, &therapy..totcost as drugtotcost, morbidities&year..*
			from rev.&patient left join rev.&ipcost on &patient..patid=&ipcost..patid
				left join rev.&aecost on &patient..patid=&aecost..patid
				left join rev.&opcost on &patient..patid=&opcost..patid
				left join rev.&pccost on &patient..patid=&pccost..patid
				left join rev.&therapy on &patient..patid=&therapy..patid
				left join multimor.morbidities&year. on &patient..patid=morbidities&year..patid;
quit;

*Create total cost variable;
data allcosts2; *drop any intersex cases;
	set allcosts1(rename=(totcost=apctotcost));
	format finalcost BEST32.;
	finalcost =  sum(apctotcost, aetotcost, optotcost, ptotcost, drugtotcost);
	format age_cat $5.;
	age_cat = 'NA';
	if startage < 5 then age_cat = '0-4';
	else if startage >= 5 and startage < 10 then age_cat = '5-9';
	else if startage >= 10 and startage < 15 then age_cat = '10-14';
	else if startage >= 15 and startage < 20 then age_cat = '15-19';
	else if startage >= 20 and startage < 25 then age_cat = '20-24';
	else if startage >= 25 and startage < 30 then age_cat = '25-29';
	else if startage >= 30 and startage < 35 then age_cat = '30-34';
	else if startage >= 35 and startage < 40 then age_cat = '35-39';
	else if startage >= 40 and startage < 45 then age_cat = '40-44';
	else if startage >= 45 and startage < 50 then age_cat = '45-49';
	else if startage >= 50 and startage < 55 then age_cat = '50-54';
	else if startage >= 55 and startage < 60 then age_cat = '55-59';
	else if startage >= 60 and startage < 65 then age_cat = '60-64';
	else if startage >= 65 and startage < 70 then age_cat = '65-69';
	else if startage >= 70 and startage < 75 then age_cat = '70-74';
	else if startage >= 75 and startage < 80 then age_cat = '75-79';
	else if startage >= 80 and startage < 85 then age_cat = '80-84';
	else if startage >= 85 and startage < 90 then age_cat = '85-89';
	else if startage >= 90 and startage < 95 then age_cat = '90-94';
	else if startage >= 95 and startage < 100 then age_cat = '95-99';
	else if startage >= 100 then age_cat = '100+';
	format sex2 $6.;
	if sex = 1 then sex2 = 'male';
	else if sex=2 then sex2 = 'female';
	else sex2='other';
run;

*Create top 5% indicator;
PROC RANK DATA=allcosts2 OUT=percentile TIEs=high GROUPS=100;
	VAR finalcost;
	RANKS fcperc;
RUN;

data finalcosts;
	set percentile;
	FORMAT top5 $10.;
	IF fcperc>=95 THEN top5 ='top 5%';
	ELSE top5 = 'bottom 95%';
	DROP sex;
	RENAME sex2 = sex;
run;

data rev.&finalcosts;
	set finalcosts;
run;

*Export csv;
proc export data=finalcosts dbms=csv 
	file="&rev_path.&finalcosts..csv" replace;
run;

