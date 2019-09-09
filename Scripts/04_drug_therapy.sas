*This consists of three code sections;
	*1) Mapping the Gemscript code to the DMD codes;
	*2) Attaching the costs to the mapping files;
	*3) Calculating the costs;


/******************* MAP GEMSCRIPT TO DMD CODE ********************/

proc freq data=raw.extract_therapy noprint; 
	tables prodcode / out=prodfreq; 
	where eventdate>='01apr2014'd and eventdate<'1apr2016'd;
run;

data product1;
	set lookup.product (keep = prodcode gemscriptcode productname drugsubstance bnfcode bnfchapter);
	where prodcode>=2; *remove the codes used for blank/unknown categories;
	gemscriptcode = tranwrd(gemscriptcode,"!",""); *remove any exclamations in codes, so the table matches the gem_map table below;
	gemcode = input(gemscriptcode, 8.); *all codes are a maximum of 8 digits long;
run;

*Maps Gemscript code to DMD code - Provided by INPS (makers of Vision software);
data gem_map; 
	set lookup.gem_dnd_map;
	rename gemscript_drug_code = gemcode;
run;

*Join gem_map table and counts of drugs in extract_therapy (from prodfreq) on to product table;
proc sql;
	create table product2 as select product1.gemcode, product1.prodcode, productname, drugsubstance, bnfcode, bnfchapter, dmd_drug_name, dmd_code, count 
	from product1 left join gem_map on product1.gemcode = gem_map.gemcode
					left join prodfreq on product1.prodcode=prodfreq.prodcode;
quit;

*Check names of drugs match and set any missing counts to zero - where names don't match, it is just because of spellings;
data product3;
	set product2;
	if count=. then count=0;
	format namematch 1.;
	if productname=dmd_drug_name then namematch=1;
run;

*Pull in all the INPS reference tables for different drugs categorisations - VMP VMPP AMP AMPP;
data amp;
	set lookup.amp_parta (keep=apid rename=(apid=dmd_code));
	source=input("amp", $4.);
run;
data ampp;
	set lookup.ampp_parta (keep=appid rename=(appid=dmd_code));
	source=input("ampp", $4.);
run;
data vmp;
	set lookup.vmp_parta (keep=vpid rename=(vpid=dmd_code));
	source=input("vmp", $4.);
run;
data vmpp;
	set lookup.vmpp (keep=vppid rename=(vppid=dmd_code));
	source=input("vmpp", $4.);
run;

*Append them all together;
data drugrefs;
	set amp ampp vmp vmpp;
run;

*Join the drugrefs sources onto the product table;
proc sql;
	create table product4 as
	select product3.*, source from 
	product3 left join drugrefs on product3.dmd_code=drugrefs.dmd_code;
quit;

*Check the numbers of extract_therapy records with references;
proc sql;
	create table drugsummary as
	select source, sum(count) as therapies
	from product4 group by source;
quit;


/******************* ATTACH COSTS TO MAPPING FILE ********************/


*Pull in reference table containing prices - VMPP;
data prices;
	set lookup.vmpp (keep=vppid vpid nm price qtyval);
	unitprice=input(price/qtyval, best32.); *need to make sure we are using a unit price rather than a pack price;
run;

*Pull in AMP to VMP reference file;
data ampvmp;
	set lookup.amp_parta (keep=apid vpid nm);
run;

*Create average price at VMP level from VMPP table;
proc sql;
	create table avprices1 as
	select vpid, mean(unitprice) as avprice, std(unitprice) as stdev
	from prices where unitprice ne . and vpid ne . group by vpid;
quit;

*Create average price at AMP level from VMPP table;
proc sql;
	create table avprices2 as
	select apid, mean(unitprice) as avprice, std(unitprice) as stdev
	from prices left join ampvmp on prices.vpid=ampvmp.vpid
	where unitprice ne . and apid ne . group by apid;
quit;

*Merge the prices back onto the products table - <<< This is the key table for pricing the records >>>;
proc sql;
	create table product5 as 
	select product4.*, case when avprices1.avprice =. then avprices2.avprice else avprices1.avprice end as price 
	from product4 left join avprices1 on avprices1.vpid=dmd_code
					left join avprices2 on avprices2.apid=dmd_code
	order by count desc;
quit;

*Set flag to identify those which have been priced;
data product6;
	set product5;
	priced=1;
	if price=. then priced=0;
run;

*Check how many extract_therapy records have been priced;
proc sql;
	create table checkpricing as
	select priced, sum(count) as pricedrecs from product6
	group by priced;
quit;


/******************* THERAPY COSTING ********************/

*Set cohort;
data cohort;
	set rev.&cohort.;
run;

*Pull in 'extract_therapy' data;
data therapy1; 
	set raw.extract_therapy;
	where eventdate>=&startdate. and eventdate<&enddate. ;
run;

*Join on average prices and bnf chapters, inflate the price (from 2016/17 prices) by the GDP deflator (0.97847625) to get price in 2015/16 prices;
*GDP deflators are sourced from National Statistics: www.gov.uk/government/statistics/gdp-deflators-at-market-prices-and-money-gdp-march-2018-quarterly-national-accounts ;
proc sql;
	create table therapy2 as 
	select pracid, therapy1.*, round(bnfcodes.bnf/1000000,1) as bnfchapter, drugsubstance, (price/100) * qty * 0.97847625 as totprice /*price is originally in pence*/
	from therapy1 left join product5 on therapy1.prodcode=product5.prodcode
					left join lookup.bnfcodes on therapy1.bnfcode=bnfcodes.bnfcode
						left join cohort on therapy1.patid=cohort.patid;
quit;

*Check bnf chapters;
proc freq data=therapy2;
	tables bnfchapter / missing;
run;

*Check costing success;
proc sql;
	create table drugcheck as
	select case when totprice>0 then 1 else 0 end as costed  from therapy2;
quit;

proc sql;
	create table drugcheck1 as
	select costed, count(*) from drugcheck group by costed;
quit;


*Remove any records that are not priced so prices are consistent with therapy record counts;
data therapy3;
	set therapy2;
	if bnfchapter<1 or bnfchapter>15 then bnfchapter=.; *set any invalid bnfchapters to missing;
	where totprice ne . ;
run;

*Count up prescriptions and costs by patid;
proc sql;
	create table temp1 as 
		select patid, count(patid) as therapyrec, count(distinct bnfchapter) as bnfchap, 
			count(distinct drugsubstance) as drug, sum(totprice) as cost from therapy3 
				group by patid; 
quit;

*Join onto cohort data, and set missings to zero;
proc sql;
	create table rev.therapy_&hrgyear as
		select cohort.patid, case when therapyrec=. then therapyrec=0 else therapyrec end as therapyrecs,
			case when bnfchap=. then bnfchap=0 else bnfchap end as bnfchaps, 
			case when drug=. then drug=0 else drug end as drugs,
			case when cost=. then cost=0 else cost end as totcost 
				from cohort left join temp1 on cohort.patid=temp1.patid;
quit;





