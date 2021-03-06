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

#### use david's function to cleanup ####
# Common Functions
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

clean_city_property <- function(x) {
  gsub("[0-9]{5}", "", x) %>%
    gsub("[[:space:]]+$", "", .) %>%
    gsub("[[:punct:]]$", "", .) %>%
    gsub(",[A-Z]{2}$", "", .) %>%
    toupper
}

count_cntmtn_fnd <- function(x) {
  x %>% 
    select(contains('Cntmnt_Fnd')) %>% 
    mutate(across(contains('Cntmnt_Fnd'), ~ ifelse(.x == 'Y', 1, 0))) %>% 
    rowSums(na.rm = TRUE)
}


# implement david's function
# brownfields_new <- brownfields %>% select(where(~!all(is.na(.x))))
# colnames(brownfields_new) <- sapply(colnames(brownfields_new), move_digits_to_back)
# clean_columns <- brownfields_new %>% rename_all(format_cols)
# colnames(clean_columns)

# Remove All Missing and Unnecessary Columns
geo_data <- brownfields %>% 
  select(where(~!all(is.na(.x)))) %>% 
  select(-`Future Use: Multistory (arces)`)

# Rename and Format Columns
geo_data <- geo_data %>% rename_all(format_cols) %>% rename(GEOID = Geoid)
colnames(geo_data) <- sapply(colnames(geo_data), move_digits_to_back)

# Apply Cleaning to individual values
geo_clean <- geo_data %>% 
  mutate(across(contains('Date') & contains('-'), as.Date, format = '%Y-%d-%m')) %>% # I don't think this does what I think it does - is it really checking for a hyphen?
  mutate_at(vars(Date_ICs_in_Place, Redev_Completion_Date), as.Date, format = '%m/%d/%y') %>% # A few dates are not in the standard format
  mutate_if(~ length(unique(levels(as.factor(.x)))) < 100, as.factor) %>% # Convert shorter character values to factors
  mutate_if(is.factor, ~ .x %>% fct_recode(Y = 'x', Y = 'y',N = 'n', U = 'u')) %>% # Recode those factors that don't match. 
  mutate(Property_City_clean = clean_city_property(Property_City)) %>%
  mutate_at(vars(GEOID), as.numeric) %>% 
  mutate(Num_Cntmtn_Fnd = count_cntmtn_fnd(.))


# ACS Data Cleaning -------------------------------------------------------


acs_data_raw <- readxl::read_xlsx('data/national_acs5-2018_census.xlsx')

# Ensure joining between ACS and GEO
acs_data <- acs_data_raw %>% 
  mutate_at(vars(GEOID), ~ .x %>% as.numeric())



# 
# # fix var content
# clean_columns %>% 
#   mutate(Cntmnt_Fnd_Other_Metals = case_when(Cntmnt_Fnd_Other_Metals == "x" ~ "Y",
#                                              TRUE ~ Cntmnt_Fnd_Other_Metals)) %>% 
#   count(Cntmnt_Fnd_Other_Metals)
# 
# fnclean_cntmnt <- function(cntmnt){
#   mutate(cntmnt = case_when(cntmnt == "x" ~ "Y",
#                                              TRUE ~ cntmnt))
# }
# 
# clean_columns %>% 
#   mutate_at(c("Cntmnt_Fnd_Other_Metals", "Cntmnt_Fnd_Petroleum"), fnclean_cntmnt)
# 
# clean_columns %>% 
#   mutate(across(c("Cntmnt_Fnd_Other_Metals", "Cntmnt_Fnd_Petroleum"), fnclean_cntmnt)) %>% 
#   count(Cntmnt_Fnd_Other_Metals)
# 
# clean_columns %>% 
#   mutate(Cntmnt_Fnd_Other_Metals = case_when(Cntmnt_Fnd_Other_Metals == "x" ~ "Y",
#                                              TRUE ~ Cntmnt_Fnd_Other_Metals)) %>% 
#   mutate(Cntmnt_Fnd_Petroleum = case_when(Cntmnt_Fnd_Petroleum == "x" ~ "Y",
#                                              TRUE ~ Cntmnt_Fnd_Petroleum)) 
#   
  
