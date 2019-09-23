# A descriptive analysis of health care use by high cost patients in England

This project analyses the distribution of both primary and seconday health care costs in England. We identified the top 5% of users of health care sercvices by cost, using a large nationally representative sample from the Clinical Practice Research Datalink (CPRD). 

#### Project Status: Completed

## Project Description

Funding increases for the NHS in England have been less than historical norms since 2010, resulting in pressures across the health service. Despite this, there has been little research to understand the distribution and concentration of health care costs across the population. Identifying ‘high cost users’ and examining the way in which they use health care services might help to find initiatives to reduce costs or to improve efficiency.

In this analysis, we identified the top 5% of users of primary and secondary care services by cost, using a large nationally representative sample from an administrative dataset. We analysed administrative data for 299,497 patients in 2014/15 from the Clinical Practice Research Datalink (CPRD) linked to Hospital Episode Statistics (HES). Costs were estimated from utilisation activity across different care settings, alongside GP prescribed drug therapy in primary care. Costs were analysed for the top 5% (‘high cost patients’) and bottom 95% (‘all other patients’), as well as by age, gender, deprivation and multimorbidity.

This analysis was writted up as a working paper (link to follow) and was produced as part of a research project to better understand the characteristics and health care utilisation of high-cost populations across seven countries. The results of the international study are available here: 
Tanke MAC, Feyman Y, Bernal-Delgado E, Deeny SR, Imanaka Y, Jeurissen P, et al. (2019) A challenge to all. A primer on inter-country differences of high-need, high-cost patients. PLoS ONE 14(6): e0217353. [journals.plos.org/plosone/article?id=10.1371/journal.pone.0217353](journals.plos.org/plosone/article?id=10.1371/journal.pone.0217353) 

## Data source

Data used for this analysis were anonymised in line with the ICO’s Anonymisation Code of Practice. The data were accessed in The Health Foundation’s Secure Data Environment, which is a secure data analysis facility (accredited for the ISO27001 information security standard, and recognised for the NHS Digital Data Security and Protection Toolkit). No information that could directly identify a patient or other individual was used.  For ease of undertaking analysis, data objects may have been labelled e.g. ‘patient_ID’.  These do not refer to NHS IDs or other identifiable patient data.

We used data from the Clinical Practice Research Datalink (CPRD) linked to Hospital Episode Statistics (HES). ISAC protocol number [17_150R](https://www.cprd.com/protocol/high-need-patients-chronic-conditions-primary-and-secondary-care-utilisation-and-costs). We also used [NHS reference costs](improvement.nhs.uk/resources/reference-costs/)  and [PSSRU unit costs](www.pssru.ac.uk/project-pages/unit-costs/2015/index.php) to cost the clinical records. Futher detail in the references section below.

## How does it work?

As the data used for this analysis is not publically available, this code cannot be used to replicate the analysis on this dataset. However, the code can be used on other CPRD extracts to cost primary and secondary health care activity. 

### Requirements

These scripts were written in SAS Enterprise Guide Version 7.12 and RStudio Version 1.1.383. 
The following R packages are used: 

* **[haven](https://cran.r-project.org/web/packages/haven/index.html)**
* **[here](https://cran.r-project.org/web/packages/here/index.html)**
* **[tidyverse](https://cran.r-project.org/web/packages/tidyverse/index.html)**
* **[naniar](https://cran.r-project.org/web/packages/naniar/index.html)**

### Getting started

There are 14 SAS scripts (00 - 13) and 1 Rmarkdown file (14). A brief description of each of the scripts is given below:

* **00_libnames** – contains a list of all libnames, file paths and variables for the analysis in SAS. 
* **01_Import_raw_data** – Import CPRD data. 
* **02_patient_list** – Create the patient cohort.
* **03_consultations** – Identify primary care consultations and cost primary care consultations.
* **04_drug_therapy** – Cost primary care prescribed drugs.
* **05_multimorbidity** – Calculate the Cambridge multimorbidity score.
* **06_inpatient_hrg** – Prepare data for the HRG APC grouper. NOTE: APC HRG grouper must be run after this script and before 07.
* **07_inpatient_costing** – Import HRG grouper results and cost inpatient care.
* **08_preventable_admissions** – Identify preventable admissions and associated costs.
* **09_outpatient_hrg** – Prepare data for the HRG NAC grouper. NOTE: NAC HRG grouper must be run after this script and before 10.
* **10_outpatient_costing** – Import HRG grouper results and cost outpatient care.
* **11_ed_hrg** – Prepare data for the HRG A&E grouper. NOTE: A&E HRG grouper must be run after this script and before 12.
* **12_ed_costing** – Import HRG grouper results and cost A&E care.
* **13_merge_costs** – Create a flat file with all associated costs.
* **14_HCU_analysis** – Creates summary tables and graphs for descriptive statistics in R.

Scripts should be run in order (as numbered). The respective HRG grouper needs to be run after script 06, 09 and 11.

## Useful references

1. Curtis L, Burns A. Unit Costs of Health and Social Care 2015. p. 177 & p. 174 Kent: Personal Social Services Research Unit; 2015. [www.pssru.ac.uk/project-pages/unit-costs/2015/index.php](www.pssru.ac.uk/project-pages/unit-costs/2015/index.php). Accessed December 20, 2015

2. NHS Improvement. NHS Reference Costs. [improvement.nhs.uk/resources/reference-costs/](improvement.nhs.uk/resources/reference-costs/). Published 2017. Accessed April 13, 2018.

3. NHS Digital. HRG4+ 2017/18 Reference Costs Grouper. [digital.nhs.uk/services/national-casemix-office/downloads-groupers-and-tools/costing-hrg4-2017-18-reference-costs-grouper](digital.nhs.uk/services/national-casemix-office/downloads-groupers-and-tools/costing-hrg4-2017-18-reference-costs-grouper). Accessed April 12, 2019.

4. Cassell A, Edwards D, Harshfield A, et al. The epidemiology of multimorbidity in primary care: a retrospective cohort study. Br J Gen Pract. 2018;68(669):e245-e251. [doi:10.3399/bjgp18X695465](doi:10.3399/bjgp18X695465)

5. Carey IM, Hosking FJ, Harris T, DeWilde S, Beighton C, Cook DG. An evaluation of the effectiveness of annual health checks and quality of health care for adults with intellectual disability: an observational study using a primary care database. Heal Serv Deliv Res. 2017;5(25):1-170. [doi:10.3310/hsdr05250](doi:10.3310/hsdr05250)

## Authors

* **Will Parry** - [@DrWillParry](https://twitter.com/DrWillParry) - [Dr Will Parry](https://willparry.net/)
* **Kathryn Dreyer** - [@kathrynadreyer](https://twitter.com/kathrynadreyer) - [kathdreyer](https://github.com/kathdreyer)
* **Isaac Barker** - [@isaacbarker](https://twitter.com/isaacbarker)
* **Rocco Friebel** - [@r_friebel](https://twitter.com/r_friebel)

## License

This project is licensed under the [MIT License](https://github.com/HFAnalyticsLab/High_cost_users/blob/master/LICENSE).

## Acknowledgments

This project was inspired by an international collaboration that examined the characteristics and health care utilisation of high-cost populations across seven countries. Further details in the project description.

