# Note: Requires munging/cleanup.R to be run first

# This script takes dataset geo_clean and splits it into 3 subsets, Assessment,
# Cleanup, and Redevelopment to remove duplication
# Since geo_clean comes at the source funding level, this script also aggregates
# each subset to get the total cost per property ID and grant ID


#------------------------------------------------------------------------------
# Libraries
#------------------------------------------------------------------------------
library(tidyverse)


#------------------------------------------------------------------------------
# Issues identified 
#------------------------------------------------------------------------------

# A brownfield can be identified by the ACRES_Property_ID
#   Note: There can be up to 5 grant recipients per ACRES_Property_ID and 
#   Assessment Start Date

# There are duplicate rows where ACRES_Property_ID is repeating
# Data is at the ACRES_Property_ID, (other location identifiers) Phase, 
#   Src_of_Redev_Funding, Source_of_Cleanup_Funding level, Source of Redev 
#   Funding level


# Example: 

geo_clean %>% 
  filter(
    ACRES_Property_ID == 16088 
  ) %>%
  select(
    ACRES_Property_ID,
    contains("Assessment"),
    contains("Cleanup"),
    contains("Redev")
  ) %>%
  arrange(Assessment_Start_Date) 

# Additionally, many ACRES_Property_ID have had multiple phases on different
# Dates (841 have had more than 4 phases)
geo_clean %>% 
  group_by(ACRES_Property_ID) %>% 
  summarize(cnt = n_distinct(Assessment_Phase, Assessment_Start_Date)) %>% 
  arrange(desc(cnt))

geo_clean %>% 
  group_by(ACRES_Property_ID) %>% 
  summarize(cnt = n_distinct(Assessment_Phase, Assessment_Start_Date)) %>% 
  filter(cnt > 4) %>%
  nrow


# Some cases where Cleanup / Redevelopment start date is less than Assessment
# start date, Shannon suggested this may be because some projects only apply for
# cleanup / redevelopment funding and have gotten their assessment from another
# place
geo_clean %>%
  filter(
    grepl("Phase", Assessment_Phase)
    & Cleanup_Start_Date < Assessment_Start_Date
    | Redevelopment_Start_Date < Assessment_Start_Date) %>%
  select(
    ACRES_Property_ID,
    Assessment_Start_Date,
    Cleanup_Start_Date
  ) %>%
  distinct 


# Another thing that needs to be investigated more are Assessment phases with 
# funding less than 1000. One theory is that costs are being split across 
# multiple ACRES_Property_IDs that have the same location description 
# (see Grant_Recipient = Missouri Department of Natural Resources for an 
# example).  Additionally, there are also some rows where 
# assessment funding for Phase 1 is equal to 1

geo_clean %>%
  filter(
    grepl("Phase I", Assessment_Phase) 
    & Amt_of_Assessment_Funding < 1000
  ) %>% distinct


geo_clean %>%
  filter(
    grepl("Phase I", Assessment_Phase) 
    & Amt_of_Assessment_Funding == 1
  ) %>% distinct %>% dim



#------------------------------------------------------------------------------
# Add contaminant groupings
#------------------------------------------------------------------------------

# Cntmnt Fnd: Cadmium, Ctrl Sbstncs, Copper, Iron, Pesticides,Ctl_Sbstncs 
# were all NA and so were removed
metals_found = c("Arsenic", "Chromium", "Lead", "Other_Metals",
           "Mercury", "Nickel", "Selenium")
other_found = c("Other", "Unknown")
pah_svocs_found = c("PAHs", "SVOCs")


df <- geo_clean %>%
  mutate_at(vars(matches("Cntmnt|Media")), ~ ifelse(.x == "Y", 1, 0)) %>%
  mutate(
    Cntmnt_Fnd_Metal = pmax(!!as.symbol(paste0("Cntmnt_Fnd_", metals)), na.rm = T),
    Cntmnt_Fnd_Other = pmax(!!as.symbol(paste0("Cntmnt_Fnd_", other_found)), na.rm = T),
    Cntmnt_Fnd_PAH_SVOC = pmax(!!as.symbol(paste0("Cntmnt_Fnd_", pah_svocs_found)), na.rm = T)
    )
  
  

#------------------------------------------------------------------------------
# Aggregation to ACRES_Property_ID and Assessment/Cleanup/Redevelopment Funding
#------------------------------------------------------------------------------

#----------------------------
# Assessment
#----------------------------

# Get distinct assessment and related columns
assessment <- df %>%
  select(
    ACRES_Property_ID,
    Grant_ID,
    starts_with("Property"),
    contains("Assessment"),
    contains("Cntmnt_Fnd"),
    contains("Media_Affected"),
    Cleanup_Required
  ) %>%
  distinct


# Get columns to aggregate by
cntmnt_media_cols <- assessment %>%
  select(matches("Cntmnt_Fnd|Media_Affected")) %>%
  colnames

assess_id_cols <- assessment %>%
  select(starts_with("Assessment"), starts_with("Property")) %>%
  colnames

# Aggregate assessment to Property ID, Assessment Phase, Cost level
assessment_agg <- assessment %>%
  group_by_at(vars(one_of(
      "ACRES_Property_ID",
      "Grant_ID",
      assess_id_cols,
      cntmnt_media_cols,
      "Cleanup_Required"
    ))) %>%
  summarize(
    Num_Source_of_Assessment_Funding = n_distinct(Source_of_Assessment_Funding),
    Total_Assessment_Funding = sum(Amt_of_Assessment_Funding, na.rm = T)
  ) 
  

#------------------------------------------------------------------------------
# Cleanup
#------------------------------------------------------------------------------

# Get distinct clean up and related columns
cleanup <- df %>%
  select(
    ACRES_Property_ID,
    Grant_ID,
    starts_with("Property"),
    contains("Clean"),
    contains("Fnd"),
    contains("Cln")
  ) %>% 
  select(-c(
    Cleanup_Required,
    Property_City_clean
  )) %>%
  distinct


# Get columns to aggregate by
cntmnt_media_cols <- cleanup %>%
  select(matches("Fnd|Clnd")) %>%
  colnames

cleanup_id_cols <- cleanup %>%
  select(contains("Cleanup"), starts_with("Property")) %>%
  select(-c(
    Source_of_Cleanup_Funding,
    Entity_Prvding_Cleanup_Funds,
    Amount_of_Cleanup_Funding
  )) %>%
  colnames

# Aggregate cleanup to Property, Grant, cleanup cost level
cleanup_aggr <- cleanup %>%
  group_by_at(vars(one_of(
    "ACRES_Property_ID",
    "Grant_ID",
    cleanup_id_cols,
    cntmnt_media_cols
  ))) %>%
  summarize(
    Num_Source_of_Cleanup_Funding = n_distinct(Source_of_Cleanup_Funding),
    Num_Entity_Prvding_Cleanup_Funds = n_distinct(Entity_Prvding_Cleanup_Funds),
    Total_Cleanup_Funding = sum(Amount_of_Cleanup_Funding, na.rm = T)
  )



#------------------------------------------------------------------------------
# Redevelopment
#------------------------------------------------------------------------------

redev <- df %>%
  select(
    ACRES_Property_ID,
    Grant_ID,
    contains("Redev"),
    starts_with("Property")
  ) %>%
  distinct

# Get columns to aggregate by
property_cols <- redev %>%
  select(starts_with("Property")) %>%
  colnames


redev_agg <- redev %>%
  group_by_at(vars(one_of(
    "ACRES_Property_ID", 
    "Grant_ID",
    property_cols,
    "Redevelopment_Start_Date",
    "Redev_Completion_Date",
    "Num_of_Cleanup_and_Redev_Jobs"
  ))) %>%
  summarize(
    Num_Src_Redev_Funding = n_distinct(Src_of_Redev_Funding, na.rm = T),
    Num_Entity_Prvding_Redev_Funds = n_distinct(Entity_Prvding_Redev_Funds, na.rm = T),
    Total_Redev_Funding = sum(Amount_of_Redev_Funding, na.rm = T)
  )


