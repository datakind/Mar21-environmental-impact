#*********************
#
# Explore datasets
#
#*********************

library(tidyverse)
library(readxl)

#### 1. acs5 data dictionary ####
# acs : american community survey

acs_dict <- read_csv("./data/acs5_data_dictionary.csv")
dim(acs_dict)
head(acs_dict)

# extract type of variables

acs_dict %>% 
  filter(!str_detect(variable,"PE")) %>% 
  count(concept)

dh_est <- acs_dict %>% 
  filter(!str_detect(variable,"PE") & concept == "ACS DEMOGRAPHIC AND HOUSING ESTIMATES")

house_chr <- acs_dict %>% 
  filter(!str_detect(variable,"PE") & concept == "SELECTED HOUSING CHARACTERISTICS")

econ_chr <- acs_dict %>% 
  filter(!str_detect(variable,"PE") & concept == "SELECTED ECONOMIC CHARACTERISTICS")

soc_chr <- acs_dict %>% 
  filter(!str_detect(variable,"PE") & concept == "SELECTED SOCIAL CHARACTERISTICS IN THE UNITED STATES")

head(dh_est) %>% 
  select(-concept) 


#### 2. national acs census ####
# contain demographic and socioeconomic data

acs <- read_excel("./data/national_acs5-2018_census.xlsx")
dim(acs)

head(acs)[c(1:5,1034)]
acs$index[1]

acs %>% 
  select(GEOID) %>% 
  count(GEOID) 

#### 3. brownfields data ####

brownfields <- read_csv("./data/brownfields_data_with_county_geoid.zip", guess_max = 60000)

dim(brownfields)
head(brownfields)[c(1:5,149)]

brownfields %>% 
  select(GEOID) %>% 
  count(GEOID)

id_96908 <- brownfields %>% 
  filter(`ACRES Property ID` == 96908) 


