*Identifying and costing primary care contacts;

*Create temporary cohort;
data cohort;
	set rev.&cohort.;
run;


*Pull in consultation data for relevant dates (NB: up to one year follow-up, so dates go to 2016);
data consult1; 
	set  raw.extract_consultation(KEEP=patid consid constype eventdate staffid sysdate duration);
	where eventdate >= &startdate. and eventdate < &enddate.;
run;

*Pull in staff data;
data staff;
	set raw.extract_staff;
run;

*Pull in reference tables for consultation types and roles;
data cot; 
	set lookup.cot;
run;
data rol;
	set lookup.rol;
run;

*Merge all together;
proc sql;
	create table consult2 as
		select consult1.*, cot.Code as ctype, 'Consultation Type'n, rol.Code as rtype, 'Role Of Staff'n
			from consult1 inner join cohort on consult1.patid = cohort.patid
				left join cot on consult1.constype = cot.Code
				left join staff on consult1.staffid = staff.staffid
				left join rol on staff.role = rol.Code;
quit;

*Flag which cohort the consultation is relevant to and the consultation type 
and role of the staff member (see lists of codes below);
data consult3; 
	set consult2;
	format gp 1.; format nurs 1.; format clin 1.; format keepcon 1.;
	if ctype in (1,3,6,7,9,11,18,48,27,28,30,31,32,50,10,21,33,55) then keepcon=1; *there is no variation in cost by consultation type - only by role;
	if keepcon=1 and rtype in (1,2,3,4,7,8,10,47,50,53) then gp=1; else gp=0;
	if keepcon=1 and rtype in (11,54) then nurs=1; else nurs=0;
	if keepcon=1 and rtype in (26,33) then clin=1; else clin=0;
	if duration = 0 then duration = 0.5; *Use minimum duration of half a minute;
	if duration > 60 then duration = 60; *Use maximum duration of one hour; 
run;

/*
Face to face consultation codes:	Home consultation codes:		Telephone consultation codes:
--------------------------------	------------------------		-----------------------------
Clinic,1,							Home Visit,27,					Telephone call from a patient,10,
Follow-up/routine visit,3,			Hotel Visit,28,					Telephone call to a patient,21,
Night visit , practice,6,			Nursing Home Visit,30,			Triage,33,
Out of hours, Practice,7,			Residential Home Visit,31,		Telephone Consultation,55,
Surgery consultation,9,				Twilight Visit,32,
Acute visit,11,						Night Visit,50,
Emergency Consultation,18,
Initial Post Discharge Review,48,

GP codes from rol:				Nurse codes from rol:				Other clinician codes from rol:
------------------				---------------------				-------------------------------
Senior Partner,1,				Practice Nurse,11,					Physiotherapist,26,
Partner,2,						Other Nursing & Midwifery,54		Other Health Care Professional,33
Assistant,3,
Associate,4, 
Locum,7,
GP Registrar,8,
Sole Practitioner,10,
Salaried Partner,47,
GP Retainer,50,
Other Students,53
*/


*Check which consultations have not been coded;
proc sql;
	create table concheck as 
	select keepcon, 'Consultation Type'n, 'Role Of Staff'n, count(*) as freq from consult3
	group by keepcon, 'Consultation Type'n, 'Role Of Staff'n
	order by freq desc;
quit;

proc sql;
	create table concheck2 as 
	select keepcon, nurs, clin, gp, count(*) as freq from consult3
	group by keepcon, nurs, clin, gp
	order by freq desc;
quit;



*Create table of costs by patid and staff role. Costs are in 2015/16 prices so no adjustment needed. Costs taken from PSSRU.;
proc sql;
	create table consult4 as 
	select patid, gp * duration * 3.80 as gpcost, nurs * duration * 0.93333 as nurscost, clin * duration * 0.93333 as clincost
	from consult3 where (gp=1 or nurs=1 or clin=1) order by patid;
quit;

*Create summary of costs and contacts by patient;
proc sql;
	create table consult5 as 
	select patid, count(patid) as contacts, sum(gpcost + nurscost + clincost) as cost
	from consult4 group by patid;
quit;

*Join onto cohort so that all patients are included;
proc sql;
	create table rev.pccost_&hrgyear as
		select cohort.patid, case when contacts=. then contacts=0 else contacts end as pcontacts, 
			case when cost=. then cost=0 else cost end as pcost
				from cohort left join consult5 on cohort.patid=consult5.patid;
quit;


