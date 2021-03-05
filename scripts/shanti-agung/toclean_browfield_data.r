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

brownfields %>% 
  count(`Cleanup Required`)

brownfields <- brownfields %>% 
  mutate(`Cleanup Required` = str_to_upper(`Cleanup Required`)) # makes all categories in `Cleanup Required` capital

brownfields %>% 
  group_by(`Assessment Phase`) %>% 
  count(`Cleanup Required`) %>% 
  view() # some obs that has `Assessment Phase` is NA and `Cleanup Required ` is NA -- what does this mean?


#### check and cleanup "phase I - environmental assessment" ####

glimpse(phase_enva_ph01)

complete.cases(phase_enva_ph01)

