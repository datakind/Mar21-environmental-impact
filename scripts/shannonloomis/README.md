# ACRES Database Cleanup

## General Workflow

The `acres_cleanup.R` script is the main script to run, which calls other scripts that perform specific cleanup tasks.  The overall logic/workflow of the scripts is:

1. General Cleanup 
	- Format column names, data types, etc.
2. Parse Text
	- Clean description history
	- Parse grant recipient type (??)
3. Combine Similar Fields
	- Parse "other" contaminant description into high level fields
	- Combine contaminants that are similar
4. Split data by phase
	- Create table with name, address, etc. by property ID so it can be taken out of existing tables but used for future data joins
	- Break up into different assessment/cleanup phases
	- Keep only relevant data for phase


## General Cleanup
From initial `munging/cleanup.R` script from the DataDive.

Added adjusted values of cleanup and assessment costs.  Monthly CPI values were taken from FRED (https://fred.stlouisfed.org/series/CPIAUCSL) on 6/14/2021. Code averages CPI on an annual basis, normalizes to the most recent full year, and adjusts assessment and cleanup costs by respective start years.


## Parse Description History
Starting with `lamiaz/former_use_keyword_extraction.R` code.  First pass looks like a lot of the boolean fields match up with description history, so the starting logic is relatively sound.  Seeing some exceptions, so work should be done to improve this to the extent possible.

Will need to add additional fields:
- Dry cleaner - these hold a lot of chemicals and are often contaminated; seeing reference to "laundry" as well
- Gas station - also see reference to "filling station"; any reference to "petroleum" or "underground storage tank" should be lumped in with this too; potentially just call it "storage_tank" (this is what we do for our other tools)
- Community spaces (church, community center, etc.) - potential to combine with school field??

Noted misspellings:
- wharehouse

Potential enhancement could be found from `joepope44`, but `seeded_lda_output.csv` "top_topics" column values do not match human tagging for the description history field. Could be better if we update the yaml file to be more complete.


## Group Contaminants

There are a large group of contaminants listed in the ACRES database. For brevity, these will be combined into a smaller group of contaminants based on Danielle Getsinger's knowledge of remediation strategies. The cleanup costs of these different contaminants have been corroborated by Annie Tran's boxplot (`cleanup_cost_by_contaminants.png`). 

There is potential information also gleened from the description field for "other" contaminants. Preliminary code has been written and commented out, as it doesn't really pick up the nuances of remediation strategies for some sites (e.g. "lead based paint" has a more similar remediation strategy to asbstos rather than the boolean category "lead" when it is found in soil and groundwater). There could be valuable information stored in this field if someone is interested in doing the work to figure it out.


## Split by Phase

To understand the total cost of cleanup, we need to model the separate phases of clearing a property for redevelopment. The general workflow for this is:
- **Phase I Environmental Assessment** - This is a document review to determine if any current or historical operations in the area may negatively impact the site. If nothing is found during this review, it is possible to clear the site for redevelopment after this phase. For this reason, it is necessary to model both the *cost of a phase I* and the probability the site will *require a phase II*.
- **Phase II Environmental Assessment** - In this step, environmental consultants will sample a site to determine if a site is contaminated and how exensive the contamination might be. Depending on findings, future use plans, and state/federal requirements, the site may or may not need to be cleaned up. For this reason, it is necessary to model both the *cost of a phase II* and the probability the site will *require a cleanup*.
- **Cleanup** - Some sites will need to go through a cleanup phase, either by removal/remediation of the contaminated material (cleanup) or engineering solutions to sequester the contamination (institutional controls). For sites that have reached this stage, we will model the *cost cleanup*.

The entire dataset is broken down into separate datasets based on necessary models. Datasets include:
- cost_phaseI
- req_phaseII
- cost_phaseII
- req_cleanup
- cost_cleanup

Notes on data manipulation:
- Phase II and Supplemental Assessment are considered the same thing, as both are part of the process to determine the severity and extent of contamination
- Institutional Controls and Cleanup are both considered "cleanup", as both of these mechanisms clear a site for redevelopment
- Cleanup Planning is lumped in with cleanup cost for the final model. This causes a bimodal distribution in the data (plans are 10k, cleanup is 100k-1M). It might be worth it to model these steps separately depending on initial findings.


## Additional Data

Additional datasets have been provided that may be predictive for these models. Some have been directly tied to ACRES IDs, while others are provided at a geographic summary level. These can be added to the modeling datasets accordingly.

For ACS data, start with the information provided in the ACRES dataset itself (2010 values within .5 mile radius). If any of these prove indicative, we can make the effort to find these on an annual basis and join them based on the correct assessment/cleanup year. Note that there is a 2 year lag on the release of ACS data, so this will have to be accounted for when joining (e.g. for assessment year of 2008, will need to join to 2006 data to remove look ahead bias).