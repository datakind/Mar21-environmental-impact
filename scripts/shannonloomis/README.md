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
4. Create site info table
	- Create table with name, address, etc. by property ID so it can be taken out of existing tables but used for future data joins
5. Split data by phase
	- Break up into different assessment/cleanup phases
	- Keep only relevant data for phase


## General Cleanup
From initial `munging/cleanup.R` script from the DataDive.


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

The script also parses the description field for "other" contaminants. In some cases, these are redundant to the boolean contaminant fields (e.g. lead), but some are new (e.g. landfill). This categorization is subject to change based on future EDA and subject expert knowledge.