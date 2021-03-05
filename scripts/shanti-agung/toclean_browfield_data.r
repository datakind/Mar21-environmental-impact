#*********************
#
# Clean Brownfield data
#
#*********************

library(tidyverse)
library(readxl)


brownfields <- read_csv("./data/brownfields_data_with_county_geoid.zip", guess_max = 60000)

dim(brownfields)
head(brownfields)[c(1:5,149)]
glimpse(brownfields)

colnames(brownfields)

brownfields %>% 
  count(`Assessment Phase`) # there are NA values

brownfields %>% 
  filter(is.na(`Assessment Phase`)) %>% 
  select(`Cleanup Start Date`)

#### split dataset based on phase ####

phase_cleanup <- brownfields %>% 
  filter(`Assessment Phase` == "Cleanup Planning")

phase_enva_ph01 <- brownfields %>% 
  filter(`Assessment Phase` == "Phase I Environmental Assessment")

phase_enva_ph02 <- brownfields %>% 
  filter(`Assessment Phase` == "Phase II Environmental Assessment")

phase_suppla <- brownfields %>% 
  filter(`Assessment Phase` == "Supplemental Assessment")

# check var content

brownfields <- brownfields %>% 
  mutate(`Cleanup Required` = str_to_upper(`Cleanup Required`)) # makes all categories in `Cleanup Required` capital


brownfields %>% 
  count(`Source of Assessment Funding`) %>% 
  view() # different punctuation makes some funding sources appear as different entity

brownfields %>% 
  mutate(`Source of Assessment Funding` = case_when(
    `Source of Assessment Funding` == "Alaska DEC" ~ "Alaska Department of Environmental Conservation",
    `Source of Assessment Funding` == "Ale's White Lake Investment LLC" ~ "Alex's White Lake Investment LLC",
    `Source of Assessment Funding` == "AmecFW" ~ "Amec Foster Wheeler",
    `Source of Assessment Funding` == "ADEQ Resource Grant" ~ "ADEQ",
    `Source of Assessment Funding` == "Anaheim Revelopment Agency" ~ "Anaheim Redevelopment Agency",
    `Source of Assessment Funding` == "Apex Laboratories" ~ "Apex Labs",
    #`Source of Assessment Funding` == "Augusta Canaly Authority" ~ "Augusta Canal Authority",
    TRUE ~ `Source of Assessment Funding`
  )) %>% 
  count(`Source of Assessment Funding`) %>% 
  view() 





brownfields %>% 
  group_by(`Assessment Phase`) %>% 
  count(`Cleanup Required`) %>% 
  view() # some obs that has `Assessment Phase` is NA and `Cleanup Required ` is NA -- what does this mean?



#### check var 41 to 80 ####

# note: var 1 - 40: emily chen, var 81 - last: david werner

brownfields %>% 
  count(`Cntmnt Fnd-Lead`) # possibly need to recode "x"

brownfields %>% 
  count(`Cntmnt Fnd-Other Metals`) # possibly need to recode "x"

brownfields %>% 
  count(`Cntmnt Fnd-Petroleum`) # possibly need to recode "x"

brownfields %>% 
  count(`Cntmnt Fnd-Other Metals`) # possibly need to recode "x"

# recode 'x'


