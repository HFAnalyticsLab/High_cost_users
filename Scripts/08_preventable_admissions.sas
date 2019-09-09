*Identifying preventable admissions, as per Carey et al (2017);

*Use spell primary diagnosis ICD-10 codes to identify preventable admissions;
data prevadm1; 
	set rev.apc_data&year.;

	format angina best3.;
	if SpellPDiag =: 'I20' then angina = 1;
else if SpellPDiag =: 'I240' then angina = 1;
else if SpellPDiag =: 'I249' then angina = 1;
else if SpellPDiag =: 'I248' then angina = 1;
else angina = 0;
 
	format aspiration best3.;	
	if SpellPDiag =: 'J690' then aspiration = 1;
else if SpellPDiag =: 'J698' then aspiration = 1;
else aspiration = 0;

	format asthma best3.;	
	if SpellPDiag =: 'J45' then asthma = 1;
else if SpellPDiag =: 'J46' then asthma = 1;
else asthma = 0;

	format cellulitis best3.;	
	if SpellPDiag =: 'L03' then cellulitis = 1;
else if SpellPDiag =: 'L04' then cellulitis = 1;
else if SpellPDiag =: 'L08' then cellulitis = 1;
else if SpellPDiag =: 'L88' then cellulitis = 1;
else if SpellPDiag =: 'L980' then cellulitis = 1;
else if SpellPDiag =: 'L983' then cellulitis = 1;
else cellulitis = 0;

	format chf best3.;
	if SpellPDiag =: 'I110' then chf = 1;
else if SpellPDiag =: 'I50' then chf = 1;
else if SpellPDiag =: 'J81' then chf = 1;
else chf = 0;

	format constipation best3.;
	if SpellPDiag =: 'K590' then constipation = 1;
else constipation = 0;

	format epilepsy best3.;
	if SpellPDiag =: 'G40' then epilepsy = 1;
else if SpellPDiag =: 'G41' then epilepsy = 1;
else if SpellPDiag =: 'R56' then epilepsy = 1;
else if SpellPDiag =: 'O15' then epilepsy = 1;
else epilepsy = 0;

	format copd best3.;
	if SpellPDiag =: 'J41' then copd = 1;
else if SpellPDiag =: 'J42' then copd = 1;
else if SpellPDiag =: 'J43' then copd = 1;
else if SpellPDiag =: 'J44' then copd = 1;
else if SpellPDiag =: 'J47' then copd = 1;
else copd = 0;

	format dehy best3.;
	if SpellPDiag =: 'E86' then dehy = 1;
else if SpellPDiag =: 'K522' then dehy = 1;
else if SpellPDiag =: 'K528' then dehy = 1;
else if SpellPDiag =: 'K529' then dehy = 1;
else dehy = 0;

	format dental best3.;
	if SpellPDiag =: 'A690' then dental = 1;
else if SpellPDiag =: 'K02' then dental = 1;
else if SpellPDiag =: 'K03' then dental = 1;
else if SpellPDiag =: 'K04' then dental = 1;
else if SpellPDiag =: 'K05' then dental = 1;
else if SpellPDiag =: 'K06' then dental = 1;
else if SpellPDiag =: 'K08' then dental = 1;
else if SpellPDiag =: 'K098' then dental = 1;
else if SpellPDiag =: 'K099' then dental = 1;
else if SpellPDiag =: 'K12' then dental = 1;
else if SpellPDiag =: 'K13' then dental = 1;
else dental = 0;

	format dia best3.;
	if SpellPDiag =: 'E100' then dia = 1;
else if SpellPDiag =: 'E101' then dia = 1;
else if SpellPDiag =: 'E102' then dia = 1;
else if SpellPDiag =: 'E103' then dia = 1;
else if SpellPDiag =: 'E104' then dia = 1;
else if SpellPDiag =: 'E105' then dia = 1;
else if SpellPDiag =: 'E106' then dia = 1;
else if SpellPDiag =: 'E107' then dia = 1;
else if SpellPDiag =: 'E108' then dia = 1;
else if SpellPDiag =: 'E110' then dia = 1;
else if SpellPDiag =: 'E111' then dia = 1;
else if SpellPDiag =: 'E112' then dia = 1;
else if SpellPDiag =: 'E113' then dia = 1;
else if SpellPDiag =: 'E114' then dia = 1;
else if SpellPDiag =: 'E115' then dia = 1;
else if SpellPDiag =: 'E116' then dia = 1;
else if SpellPDiag =: 'E117' then dia = 1;
else if SpellPDiag =: 'E118' then dia = 1;
else if SpellPDiag =: 'E120' then dia = 1;
else if SpellPDiag =: 'E121' then dia = 1;
else if SpellPDiag =: 'E122' then dia = 1;
else if SpellPDiag =: 'E123' then dia = 1;
else if SpellPDiag =: 'E124' then dia = 1;
else if SpellPDiag =: 'E125' then dia = 1;
else if SpellPDiag =: 'E126' then dia = 1;
else if SpellPDiag =: 'E127' then dia = 1;
else if SpellPDiag =: 'E128' then dia = 1;
else if SpellPDiag =: 'E130' then dia = 1;
else if SpellPDiag =: 'E131' then dia = 1;
else if SpellPDiag =: 'E132' then dia = 1;
else if SpellPDiag =: 'E133' then dia = 1;
else if SpellPDiag =: 'E134' then dia = 1;
else if SpellPDiag =: 'E135' then dia = 1;
else if SpellPDiag =: 'E136' then dia = 1;
else if SpellPDiag =: 'E137' then dia = 1;
else if SpellPDiag =: 'E138' then dia = 1;
else if SpellPDiag =: 'E140' then dia = 1;
else if SpellPDiag =: 'E141' then dia = 1;
else if SpellPDiag =: 'E142' then dia = 1;
else if SpellPDiag =: 'E143' then dia = 1;
else if SpellPDiag =: 'E144' then dia = 1;
else if SpellPDiag =: 'E145' then dia = 1;
else if SpellPDiag =: 'E146' then dia = 1;
else if SpellPDiag =: 'E147' then dia = 1;
else if SpellPDiag =: 'E148' then dia = 1;
else dia = 0;

	format ear best3.;
	if SpellPDiag =: 'H66' then ear = 1;
else if SpellPDiag =: 'H67' then ear = 1;
else if SpellPDiag =: 'J02' then ear = 1;
else if SpellPDiag =: 'J03' then ear = 1;
else if SpellPDiag =: 'J06' then ear = 1;
else if SpellPDiag =: 'J312' then ear = 1;
else ear = 0;

	format gangrene best3.;
	if SpellPDiag =: 'R02' then gangrene = 1;
else gangrene = 0;

	format gastro best3.;
	if SpellPDiag =: 'K21' then gastro = 1;
else gastro = 0;

	format hyper best3.;
	if SpellPDiag =: 'I10' then hyper = 1;
else if SpellPDiag =: 'I119' then hyper = 1;
else hyper = 0;

	format anaemia best3.;
	if SpellPDiag =: 'D501' then anaemia = 1;
else if SpellPDiag =: 'D508' then anaemia = 1;
else if SpellPDiag =: 'D509' then anaemia = 1;
else anaemia = 0;

	format influenza best3.;
	if SpellPDiag =: 'J10' then influenza = 1;
else if SpellPDiag =: 'J11' then influenza = 1;
else influenza = 0;

	format nutrition best3.;
	if SpellPDiag =: 'E40' then nutrition = 1;
else if SpellPDiag =: 'E41' then nutrition= 1;
else if SpellPDiag =: 'E42' then nutrition= 1;
else if SpellPDiag =: 'E43' then nutrition= 1;
else if SpellPDiag =: 'E55' then nutrition= 1;
else if SpellPDiag =: 'E643' then nutrition= 1;
else nutrition = 0;


	format pelvic best3.;
	if SpellPDiag =: 'N70' then pelvic = 1;
else if SpellPDiag =: 'N73' then pelvic= 1;
else if SpellPDiag =: 'N74' then pelvic= 1;
else pelvic = 0;

	format ulcer best.3;
	if SpellPDiag =: 'K250' then ulcer = 1;
else if SpellPDiag =: 'K251' then ulcer= 1;
else if SpellPDiag =: 'K252' then ulcer= 1;
else if SpellPDiag =: 'K254' then ulcer= 1;
else if SpellPDiag =: 'K255' then ulcer= 1;
else if SpellPDiag =: 'K256' then ulcer= 1;
else if SpellPDiag =: 'K260' then ulcer= 1;
else if SpellPDiag =: 'K261' then ulcer= 1;
else if SpellPDiag =: 'K262' then ulcer= 1;
else if SpellPDiag =: 'K264' then ulcer= 1;
else if SpellPDiag =: 'K265' then ulcer= 1;
else if SpellPDiag =: 'K266' then ulcer= 1;
else if SpellPDiag =: 'K270' then ulcer= 1;
else if SpellPDiag =: 'K271' then ulcer= 1;
else if SpellPDiag =: 'K272' then ulcer= 1;
else if SpellPDiag =: 'K274' then ulcer= 1;
else if SpellPDiag =: 'K275' then ulcer= 1;
else if SpellPDiag =: 'K276' then ulcer= 1;
else if SpellPDiag =: 'K280' then ulcer= 1;
else if SpellPDiag =: 'K281' then ulcer= 1;
else if SpellPDiag =: 'K282' then ulcer= 1;
else if SpellPDiag =: 'K284' then ulcer= 1;
else if SpellPDiag =: 'K285' then ulcer= 1;
else if SpellPDiag =: 'K286' then ulcer= 1;
else ulcer = 0;

	format pneu best3.;
	if SpellPDiag =: 'J13' then pneu = 1;
else if SpellPDiag =: 'J14' then pneu= 1;
else if SpellPDiag =: 'J153' then pneu= 1;
else if SpellPDiag =: 'J154' then pneu= 1;
else if SpellPDiag =: 'J157' then pneu= 1;
else if SpellPDiag =: 'J159' then pneu= 1;
else if SpellPDiag =: 'J168' then pneu= 1;
else if SpellPDiag =: 'J181' then pneu= 1;
else if SpellPDiag =: 'J188' then pneu= 1;
else if SpellPDiag =: 'J200' then pneu= 1;
else if SpellPDiag =: 'J201' then pneu= 1;
else if SpellPDiag =: 'J202' then pneu= 1;
else if SpellPDiag =: 'J208' then pneu= 1;
else if SpellPDiag =: 'J209' then pneu= 1;
else if SpellPDiag =: 'J22' then pneu= 1;
else pneu = 0;


	format tuber best3.;
	if SpellPDiag =: 'A15' then tuber = 1;
else if SpellPDiag =: 'A16' then tuber= 1;
else if SpellPDiag =: 'A19' then tuber= 1;
else if SpellPDiag =: 'A35' then tuber= 1;
else if SpellPDiag =: 'A36' then tuber= 1;
else if SpellPDiag =: 'A37' then tuber= 1;
else if SpellPDiag =: 'A80' then tuber= 1;
else if SpellPDiag =: 'B05' then tuber= 1;
else if SpellPDiag =: 'B06' then tuber= 1;
else if SpellPDiag =: 'B161' then tuber= 1;
else if SpellPDiag =: 'B169' then tuber= 1;
else if SpellPDiag =: 'B180' then tuber= 1;
else if SpellPDiag =: 'B181' then tuber= 1;
else if SpellPDiag =: 'B26' then tuber= 1;
else if SpellPDiag =: 'G000' then tuber= 1;
else if SpellPDiag =: 'M014' then tuber= 1;
else tuber = 0;

	format uti best3.;
	if SpellPDiag =: 'N10' then uti = 1;
else if SpellPDiag =: 'N11' then uti= 1;
else if SpellPDiag =: 'N12' then uti= 1;
else if SpellPDiag =: 'N136' then uti= 1;
else if SpellPDiag =: 'N390' then uti= 1;
else uti = 0;

	format ACS best3.;
	if angina = 1 then ACS = 1;
else if aspiration = 1 then ACS = 1;
else if asthma = 1 then ACS = 1;
else if cellulitis = 1 then ACS = 1;
else if influenza = 1 then ACS = 1;
else if pneu = 1 then ACS = 1;
else if chf = 1 then ACS = 1; 
else if constipation = 1 then ACS = 1;
else if epilepsy = 1 then ACS = 1;
else if copd = 1 then ACS = 1;
else if nutrition = 1 then ACS = 1;
else if uti = 1 then ACS = 1;
else if dehy = 1 then ACS = 1; 
else if dental = 1 then ACS = 1;
else if dia = 1 then ACS = 1;
else if ear = 1 then ACS = 1;
else if pelvic = 1 then ACS = 1;
else if gangrene = 1 then ACS = 1;
else if gastro = 1 then ACS = 1; 
else if hyper = 1 then ACS = 1;
else if anaemia = 1 then ACS = 1;
else if ulcer = 1 then ACS = 1;
else if tuber = 1 then ACS = 1;
else ACS = 0;

	format ACS_acute best3.;
	if aspiration = 1 then ACS_acute = 1;
else if cellulitis = 1 then ACS_acute = 1;
else if constipation = 1 then ACS_acute = 1;
else if dehy = 1 then ACS_acute = 1;
else if dental = 1 then ACS_acute = 1;
else if ear = 1 then ACS_acute = 1;
else if gangrene = 1 then ACS_acute = 1;
else if gastro = 1 then ACS_acute = 1;
else if nutrition = 1 then ACS_acute = 1;
else if pelvic = 1 then ACS_acute = 1;
else if ulcer = 1 then ACS_acute = 1;
else if uti = 1 then ACS_acute = 1;
else if influenza = 1 then ACS_acute = 1;
else if tuber = 1 then ACS_acute = 1;
else if pneu = 1 then ACS_acute = 1;
else ACS_Acute = 0;

	format ACS_chronic best3.;
	if angina = 1 then ACS_chronic = 1;
else if asthma = 1 then ACS_chronic = 1;
else if copd = 1 then ACS_chronic = 1;
else if chf = 1 then ACS_chronic = 1;
else if epilepsy = 1 then ACS_chronic = 1;
else if dia = 1 then ACS_chronic = 1;
else if hyper = 1 then ACS_chronic = 1;
else if anaemia = 1 then ACS_chronic = 1;
else ACS_chronic = 0;

run;


*Create summary dataset with costs and counts for each patient;
proc sql;
create table prevadm2 as
	select patid,
		count(provspno) as spells,
		sum(elective) as elects,
		sum(emergency) as emergs,
		sum(day_case + reg + mat + uncat) as others,
		sum(costs * elective) as elcost,
		sum(costs * emergency) as emcost,
		sum(costs * day_case + costs * reg + costs * mat + costs * uncat) as othcost,
		sum(costs) as totcost,
		sum(SpellLOS) as los,
		sum(SpellLOS) / count(provspno) as avlos,

		sum(angina) as  angina,
		sum(aspiration) as aspiration,
		sum(asthma) as asthma,
		sum(cellulitis) as cellulitis,
		sum(influenza) as influenza,
		sum(pneu) as pneu,
		sum(chf) as chf,
		sum(constipation) as constipation,
		sum(epilepsy) as epilepsy,
		sum(copd) as copd,
		sum(nutrition) as nutrition,
		sum(uti) as uti,
		sum(dehy) as dehy,
		sum(dental) as dental,
		sum(dia) as dia,
		sum(ear) as ear,
		sum(pelvic) as pelvic,
		sum(gangrene) as gangrene,
		sum(gastro) as gastro,
		sum(hyper) as hyper,
		sum(anaemia) as anaemia,
		sum(ulcer) as ulcer,
		sum(tuber) as tuber,
		
		sum(ACS * emergency) as prevadm,
		sum(ACS_chronic * emergency) as prevadmchron,
		sum(ACS_acute * emergency) as prevadmacut ,
		sum(costs * ACS * emergency) as prevcost,
		sum(costs * ACS_chronic * emergency) as prevcostchron,
		sum(costs * ACS_acute * emergency) as prevcostacut
	from prevadm1
		group by patid;
run;

*Join on to cohort so all patients are included;
proc sql;
	create table prevadm3 as
		select &cohort..patid, prevadm2.* from rev.&cohort. left join prevadm2 on &cohort..patid=prevadm2.patid;
run;

*Set any missing values to zero and save to folder;
data rev.apc_cost_&hrgyear.;
	set prevadm3;
	array arr1 spells--prevcostacut;
	do over arr1;
		if arr1=. then arr1=0 ;
	end;
run;

