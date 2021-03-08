/*

Header:
This script is written in SAS.  I tried to use SQL statements whenever possible to make the code more translatable.
Part 1 consists of data prep tasks.
Part 2 consists of actual modelling.

For the model, the target is the Sum of Cleanup Costs.

The Sum of Cleanup Costs is calculated on the dataset, after filtering and aggregating near-duplicate rows.

Filtering:
The following rows were removed -
1.  'Type of Brownfields Grant' contains "BCRLF"
2.  'Amount of Cleanup Funding' less than or equal to 0 
3.  'Cleanup Completion Date' is not populated
4.  'ACRES Cleaned Up' is not populated

De-dupping and aggregating was done by:
1.  Identifying rows where the 'ACRES Property ID' and 'Cleanup Completion Date' are the same.  It is assumed that this is for the same cleanup event.
2.  De-dup where 'ACRES Property ID', 'Cleanup Completion Date', and 'Amount of Cleanup Funding' are exactly the same.  It's assumed these are duplicates.
3.  Aggregate rows pertaining to the same Cleanup Event by:

	summing 'Amount of Cleanup Funding' as a new variable: sum_cleanup_funding
	averaging 'ACRES Cleaned Up' as new variable: avg_acres_cleaned
	averaging 'Acreage and Greenspace Created'n) as new variable: avg__acres_grn_created

*/

/* PART 1: DATA PREP AND CLEANUP */

/* initializing libraries */
cas &sysuserid.;
caslib;
caslib _ALL_ assign;
libname &sysuserid. cas;

/* import the data after saving it as an Excel file which helps with resolving the line breaks within ields */
proc import datafile="/smc/warehouse/default/ashmui/brownfields/brownfields_data_with_county_geoid.xls" out=work.brownfields1 replace dbms=xls;
	getnames=yes;
	guessingrows=yes;
run;

/*
cleanup the data according to answers provided in the Q&A doc
https://docs.google.com/document/d/1PYkD7cZoJtuoAs657n7u1fZ7xADjy9ORu-LBJsUGGB8/edit?pli=1#heading=h.dkoh5dv6dy3l
*/

/* From Shannon: BCRLF is a special type of grant that’s specific to a locality.  */
/* Segment out BCRLF grants into its own category before performing any analyses. They are of interest, but should be handled separately. */
/* create an indicator called ind_BCRLF for these types of grants */
data work.brownfields2;
	set work.brownfields1;
	if index('Type of Brownfields Grant'n,"BCRLF")>0 then ind_BCRLF=1;
	else ind_BCRLF=0;
run;

/* for simplicity, de-dup the rows assuming they are duplicates if the cleanup complete date and the amount of cleanup funding are exactly the same */
/* we will just take one of them */
/* also, only select variables of interest for predictive modeling to further simplify*/
/* filter data as well */
/* 'Amount of Cleanup Funding'n> 0 and 'Cleanup Completion Date'n ne . and ind_bcrlf=0 and 'ACRES Cleaned Up'n>0 */

proc sql;
	create table work.brownfields3 as
	select distinct
 'ACRES Property ID'n
,'Cleanup Completion Date'n 
,'Amount of Cleanup Funding'n
,'2010 # Below Poverty'n
,'2010 # Low Income'n
,'2010 # Unemployed'n
,'2010 # Vacant Housing'n
,'2010 % Below Poverty'n
,'2010 % Low Income'n
,'2010 % Unemployed'n
,'2010 % Vacant Housing'n
,'2010 Median Income'n
,'ACRES Cleaned Up'n
,'Acreage and Greenspace Created'n
,'Cntmnt Clnd Up-Arsenic'n
,'Cntmnt Clnd Up-Asbestos'n
,'Cntmnt Clnd Up-Cadmium'n
,'Cntmnt Clnd Up-Chromium'n
,'Cntmnt Clnd Up-Copper'n
,'Cntmnt Clnd Up-Ctrl Sbstncs'n
,'Cntmnt Clnd Up-Iron'n
,'Cntmnt Clnd Up-Lead'n
,'Cntmnt Clnd Up-Mercury'n
,'Cntmnt Clnd Up-Nickel'n
,'Cntmnt Clnd Up-None'n
,'Cntmnt Clnd Up-Other'n
,'Cntmnt Clnd Up-Other (Descr)'n
,'Cntmnt Clnd Up-Other Metals'n
,'Cntmnt Clnd Up-PAHs'n
,'Cntmnt Clnd Up-PCBs'n
,'Cntmnt Clnd Up-Pesticides'n
,'Cntmnt Clnd Up-Petroleum'n
,'Cntmnt Clnd Up-SVOCs'n
,'Cntmnt Clnd Up-Selenium'n
,'Cntmnt Clnd Up-Unknown'n
,'Cntmnt Clnd Up-VOCs'n
,'Cntmnt Fnd-Arsenic'n
,'Cntmnt Fnd-Asbestos'n
,'Cntmnt Fnd-Cadmium'n
,'Cntmnt Fnd-Chromium'n
,'Cntmnt Fnd-Copper'n
,'Cntmnt Fnd-Ctrl Sbstncs'n
,'Cntmnt Fnd-Iron'n
,'Cntmnt Fnd-Lead'n
,'Cntmnt Fnd-Mercury'n
,'Cntmnt Fnd-Nickel'n
,'Cntmnt Fnd-None'n
,'Cntmnt Fnd-Other'n
,'Cntmnt Fnd-Other Metals'n
,'Cntmnt Fnd-PAHs'n
,'Cntmnt Fnd-PCBs'n
,'Cntmnt Fnd-Pesticides'n
,'Cntmnt Fnd-Petroleum'n
,'Cntmnt Fnd-SVOCs'n
,'Cntmnt Fnd-Selenium'n
,'Cntmnt Fnd-Unknown'n
,'Cntmnt Fnd-VOCs'n
,'Did Ownership Change'n
,'EPA Region'n
,'IC Catgry-Enfrcmnt/Prmt Tools'n
,'IC Catgry-Govmntal Ctrls'n
,'IC Catgry-Informational Dev'n
,'IC Catgry-Proprietary Ctrls'n
,'ICs in Place?'n
,'Institutional Ctrl (ICs) Req?'n
,'Media Affected-Air'n
,'Media Affected-Bldg Materials'n
,'Media Affected-Drnking Water'n
,'Media Affected-Ground Water'n
,'Media Affected-Indoor Air'n
,'Media Affected-Sediments'n
,'Media Affected-Soil'n
,'Media Affected-Surface Water'n
,'Media Affected-Unknown'n
,'Media Clnd Up-Air'n
,'Media Clnd Up-Bldg Materials'n
,'Media Clnd Up-Drnking Water'n
,'Media Clnd Up-Ground Water'n
,'Media Clnd Up-Indoor Air'n
,'Media Clnd Up-Sediments'n
,'Media Clnd Up-Soil'n
,'Media Clnd Up-Surface Water'n
,'Media Clnd Up-Unknown'n
,'Other Media Ind'n
,'Ownership Entity'n
,'Past Use: Commercial (arces)'n
,'Past Use: Greenspace (arces)'n
,'Past Use: Industrial (arces)'n
,'Past Use: Multistory (arces)'n
,'Past Use: Residential (arces)'n
,'Photographs are available'n
,'Property Size'n
,'Radius'n
,'Ready For Reuse Ind'n
,'SFLLP fact into the ownership'n
from work.brownfields2 (where=('Amount of Cleanup Funding'n>0 and 'Cleanup Completion Date'n ne . and ind_bcrlf=0 and 'ACRES Cleaned Up'n>0))
;
quit;

/* aggregate by cleanup complete date (take the sum) */
proc sql;
	create table work.brownfields4 as
	select distinct sum('Amount of Cleanup Funding'n) as sum_cleanup_funding
	,'Cleanup Completion Date'n
	,avg('ACRES Cleaned Up'n) as avg_acres_cleaned label='ACRES Cleaned Up'
	,avg('Acreage and Greenspace Created'n) as avg_acres_grn_created label= 'Avg Acreage and Greenspace Created'
	,*
	from work.brownfields3
	group by 'ACRES Property ID'n, 'Cleanup Completion Date'n
;
quit;

/* drop the granular variables that have since been aggregated: 'Amount of Cleanup Funding'n , 'ACRES Cleaned Up'n , 'Acreage and Greenspace Created'n*/
proc sql;
	create table work.brownfields as
	select distinct
	sum_cleanup_funding label='Amount of Cleanup Funding'
	,'Cleanup Completion Date'n
	,*
	from work.brownfields4(drop='Amount of Cleanup Funding'n 'ACRES Cleaned Up'n 'Acreage and Greenspace Created'n)
	group by 'ACRES Property ID'n,'Cleanup Completion Date'n
	order by 'ACRES Property ID'n
;
quit;

/* just double-checking for dups.  if returns 0 rows then dedupping was successful */
proc sql;
	create table dups as
	select count(*) as count
	,sum_cleanup_funding label="Total Cleanup Funding ($)"
	,'Cleanup Completion Date'n
	,'ACRES Property ID'n
	,*
	from work.brownfields
	group by 'ACRES Property ID'n,'Cleanup Completion Date'n
	having calculated count > 1
;
quit;

/* load dataset into Cloud Analytic Services for advanced analysis */
data casuser.brownfields(promote=yes);
	set work.brownfields;
run;

/* PART 2: GRADIENT BOOSTING ANALYSIS */

/* start gradient boosting analysis */
proc gradboost data=casuser.brownfields;
	target sum_cleanup_funding;
	INPUT 
'2010 # Below Poverty'n
'2010 # Low Income'n
'2010 # Unemployed'n
'2010 # Vacant Housing'n
'2010 % Below Poverty'n
'2010 % Low Income'n
'2010 % Unemployed'n
'2010 % Vacant Housing'n
'2010 Median Income'n
avg_acres_cleaned
avg_acres_grn_created
'Cntmnt Clnd Up-Arsenic'n
'Cntmnt Clnd Up-Asbestos'n
'Cntmnt Clnd Up-Cadmium'n
'Cntmnt Clnd Up-Chromium'n
'Cntmnt Clnd Up-Copper'n
'Cntmnt Clnd Up-Ctrl Sbstncs'n
'Cntmnt Clnd Up-Iron'n
'Cntmnt Clnd Up-Lead'n
'Cntmnt Clnd Up-Mercury'n
'Cntmnt Clnd Up-Nickel'n
'Cntmnt Clnd Up-None'n
'Cntmnt Clnd Up-Other'n
'Cntmnt Clnd Up-Other (Descr)'n
'Cntmnt Clnd Up-Other Metals'n
'Cntmnt Clnd Up-PAHs'n
'Cntmnt Clnd Up-PCBs'n
'Cntmnt Clnd Up-Pesticides'n
'Cntmnt Clnd Up-Petroleum'n
'Cntmnt Clnd Up-SVOCs'n
'Cntmnt Clnd Up-Selenium'n
'Cntmnt Clnd Up-Unknown'n
'Cntmnt Clnd Up-VOCs'n
'Cntmnt Fnd-Arsenic'n
'Cntmnt Fnd-Asbestos'n
'Cntmnt Fnd-Cadmium'n
'Cntmnt Fnd-Chromium'n
'Cntmnt Fnd-Copper'n
'Cntmnt Fnd-Ctrl Sbstncs'n
'Cntmnt Fnd-Iron'n
'Cntmnt Fnd-Lead'n
'Cntmnt Fnd-Mercury'n
'Cntmnt Fnd-Nickel'n
'Cntmnt Fnd-None'n
'Cntmnt Fnd-Other'n
'Cntmnt Fnd-Other Metals'n
'Cntmnt Fnd-PAHs'n
'Cntmnt Fnd-PCBs'n
'Cntmnt Fnd-Pesticides'n
'Cntmnt Fnd-Petroleum'n
'Cntmnt Fnd-SVOCs'n
'Cntmnt Fnd-Selenium'n
'Cntmnt Fnd-Unknown'n
'Cntmnt Fnd-VOCs'n
'Did Ownership Change'n
'EPA Region'n
'IC Catgry-Enfrcmnt/Prmt Tools'n
'IC Catgry-Govmntal Ctrls'n
'IC Catgry-Informational Dev'n
'IC Catgry-Proprietary Ctrls'n
'ICs in Place?'n
'Institutional Ctrl (ICs) Req?'n
'Media Affected-Air'n
'Media Affected-Bldg Materials'n
'Media Affected-Drnking Water'n
'Media Affected-Ground Water'n
'Media Affected-Indoor Air'n
'Media Affected-Sediments'n
'Media Affected-Soil'n
'Media Affected-Surface Water'n
'Media Affected-Unknown'n
'Media Clnd Up-Air'n
'Media Clnd Up-Bldg Materials'n
'Media Clnd Up-Drnking Water'n
'Media Clnd Up-Ground Water'n
'Media Clnd Up-Indoor Air'n
'Media Clnd Up-Sediments'n
'Media Clnd Up-Soil'n
'Media Clnd Up-Surface Water'n
'Media Clnd Up-Unknown'n
'Other Media Ind'n
'Ownership Entity'n
'Past Use: Commercial (arces)'n
'Past Use: Greenspace (arces)'n
'Past Use: Industrial (arces)'n
'Past Use: Multistory (arces)'n
'Past Use: Residential (arces)'n
'Photographs are available'n
'Property Size'n
'Radius'n
'Ready For Reuse Ind'n
'SFLLP fact into the ownership'n
	;
run; 