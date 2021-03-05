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

# david'sfunction 
move_digits_to_back <- function(x) {
  if (grepl("^[0-9]{4}", x)) {
    split_var <- strsplit(x, split = "_")[[1]]
    paste(c(split_var[2:length(split_var)], split_var[1]), collapse = "_")
  } else x
}
format_cols <- function(x) {
  make_title_case <- function(x) {
    ifelse(x == toupper(x), str_to_title(x), x)
  }
  x <- x %>% 
    make_title_case() %>% 
    str_replace_all('\\%', 'Pct') %>% 
    str_replace_all('\\#', 'Num') %>% 
    str_replace_all(':', '') %>% 
    str_replace_all('-', '_') %>% 
    str_replace_all('[[ ]]+', '_') %>% 
    str_replace_all('[()]', '') %>% 
    str_replace_all('\\?', '') %>% 
    str_replace_all('/', '_')
  x
}

# implement david's function
brownfields_new <- brownfields %>% select(where(~!all(is.na(.x))))
colnames(brownfields_new) <- sapply(colnames(brownfields_new), move_digits_to_back)
clean_columns <- brownfields_new %>% rename_all(format_cols)
colnames(clean_columns)

# fix var content
clean_columns %>% 
  mutate(Cntmnt_Fnd_Other_Metals = case_when(Cntmnt_Fnd_Other_Metals == "x" ~ "Y",
                                             TRUE ~ Cntmnt_Fnd_Other_Metals)) %>% 
  count(Cntmnt_Fnd_Other_Metals)

fnclean_cntmnt <- function(cntmnt){
  mutate(cntmnt = case_when(cntmnt == "x" ~ "Y",
                                             TRUE ~ cntmnt))
}

clean_columns %>% 
  mutate_at(c("Cntmnt_Fnd_Other_Metals", "Cntmnt_Fnd_Petroleum"), fnclean_cntmnt)

clean_columns %>% 
  mutate(across(c("Cntmnt_Fnd_Other_Metals", "Cntmnt_Fnd_Petroleum"), fnclean_cntmnt)) %>% 
  count(Cntmnt_Fnd_Other_Metals)

clean_columns %>% 
  mutate(Cntmnt_Fnd_Other_Metals = case_when(Cntmnt_Fnd_Other_Metals == "x" ~ "Y",
                                             TRUE ~ Cntmnt_Fnd_Other_Metals)) %>% 
  mutate(Cntmnt_Fnd_Petroleum = case_when(Cntmnt_Fnd_Petroleum == "x" ~ "Y",
                                             TRUE ~ Cntmnt_Fnd_Petroleum)) 
  
  
