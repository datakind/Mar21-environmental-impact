# Introduction 
During this DataDive, DataKind volunteers will explore the Assessment, Cleanup and Redevelopment Exchange System (ACRES), an online database for Brownfields Grantees to electronically submit data directly to EPA. Volunteers will explore this data alongside the 2018 5-year American Community Survey (ACS) data in order to derive insights about the demographics and socioeconomic characteristics of counties affected by brownfield cleanups.

Please see the full project brief here: https://docs.google.com/document/d/1zRCGOT8r5V7U36rczUafp7zB-IjJ0j0bNf6xLj0qwnY/edit?pli=1

# Key Questions for the DataDive Event
1. Summarize and/or describe the cost of a brownfield cleanup:
  - By phase (Phase I Assessment, Phase II Assessment, Cleanup and Remediation)
  - By location
  - Over time
  - By demographics
  - By type of redevelopment site (see Question #5)
2. What benchmarks exist in the data; or, in other words, what does a “typical” cleanup look like? What do outliers look like?
3. What similar groupings, or clusters, exist in the ACRES dataset, particularly in relation to the cost of a cleanup? What ACS variables may be related to cleanup cost?
4. What variables in the ACRES dataset are most predictive of the cost of a cleanup? Which can be excluded from the dataset entirely?
5. Using NLP techniques, what information can be gleaned about the type of property being cleaned up from the `Description/History` and `Highlights` fields?
6. How long does it take to complete a Phase I assessment? A Phase II assessment? A cleanup?
7. What proportion of cleanups reach the redevelopment phase? How long does redevelopment take, and what are typical costs?

# Datasets with Suggested Uses
This section gives a very brief overview of the datasets in the `data` folder.

### acs5_data_dictionary.csv
Use this file to find 'human-readable' names for the ACS variables found in the file `national_acs5-2018_census.xlsx`. There are over 1,000 variables in the American Community Survey datasets, but half correspond to count estimates (these end in just 'E', e.g., `DP02_002E`) and half correspond to percentage estimates (these end in 'PE', e.g., `DP02_002PE`). In other words, `DP02_002E` and `DP02_002PE` represent the same information, only in different formats. Hence, depending on whether or not you choose to work with counts or rates in your analysis, it may only be necessary to work with half of these variables.

For more precise definitions of the concepts described in the data dictionary, please see this very thorough documentation provided by the Census Bureau: https://www2.census.gov/programs-surveys/acs/tech_docs/subject_definitions/2019_ACSSubjectDefinitions.pdf

### brownfields_data_with_county_geoid.zip
This compressed file contains the primary dataset for this project, `brownfields_data_with_county_geoid.csv`. In this dataset, each record represents a single brownfield site that applied for (and may or may not have received) an EPA cleanup grant. Sourced from: https://www.epa.gov/cleanups/cleanups-my-community

A (very much still in progress) data dictionary for this data can be found here: https://docs.google.com/spreadsheets/d/1UiT9LWc-eo_WrWR-sL9d3QQ_lY181Mf0xhOZ1TBzMhw/edit#gid=0

### national_acs5-2018_census.xlsx
Use this file to generate county-level summaries of demographic and socioeconomic variables for counties containing brownfields. It may also be useful for modeling the drivers of cleanup costs in these areas. Join this data to the brownfields dataset on the `GEOID` field (you may need to prepend leading zeroes if the GEOID has 4 characters instead of the required 5) and use `acs5_data_dictionary.csv` to decode the ACS variable names.
