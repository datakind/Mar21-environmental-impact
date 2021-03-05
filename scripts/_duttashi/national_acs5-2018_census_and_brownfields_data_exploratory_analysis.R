# Exploratory Data analysis for environmental impact
# Objective: To determine variables relevant to environmental impact
# required data files: national_acs5-2018_census.csv, brownfields_data_with_county_geoid.csv
# Script author: Ashish Dutt
# Script create date: 05/3/2021
# Script last modified date: 05/3/2021
# Email: ashish.dutt8@gmail.com

# clean the workspace
rm(list = ls())

# required libraries
library(tidyverse) # for data manipulation
library(data.table) # for setnames()

# read the raw dataset in memory
df_raw_census <- read.csv("data/national_acs5-2018_census.csv", na.strings = NA)
df_raw_brownfields <- read.csv("data/brownfields_data_with_county_geoid.csv", na.strings = NA)

# 1. Exploratory Data Analysis

# 1.1. check data dimension
dim(df_raw_census) # [1] 3220 rows in 1034 columns
dim(df_raw_brownfields) # [1] 78527 rows in 150 columns

# 1.2. check for missing data
sum(is.na(df_raw_census)) # 237712 missing values
sum(is.na(df_raw_brownfields)) # 1205125  missing values
colSums(is.na(df_raw_census))

# 1.3 Find variables with zero variance and remove them
excluded_vars  <- df_raw_census %>%
  summarise_all(var) %>%
  select_if(function(.) . == 0) %>% 
  names() 
## Finding: df_raw_census data has 49 variables with zero variance 
## Finding: df_raw_brownfields data has 01 variable with zero variance

# remove the 49 variables with zero variance
df_raw_census<- df_raw_census %>%
  select(-one_of(excluded_vars))
dim(df_raw_census) # [1] 3220  985

# remove missing data from df_raw_census dataframe
df_raw_census <- df_raw_census %>%
  drop_na()
dim(df_raw_census) # [1] 3142  985

# 1.4 Lowercase column names
lowercase_cols<- function(df){
  for (col in colnames(df)) {
    colnames(df)[which(colnames(df)==col)] = tolower(col)
  }
  return(df)
}
# lower case all variable names
df_raw_census <- lowercase_cols(df_raw_census)
df_raw_brownfields <- lowercase_cols(df_raw_brownfields)

# I find the variable GEOCODE is common in both df_raw_census and df_raw_brownfields dataframes.
# However, GEOID in census needs cleaning. It has an additional 0 prefix to each geoid that needs to be removed

df_raw_census$geoid<- as.character(df_raw_census$geoid)
df_raw_brownfields$geoid<- as.character(df_raw_brownfields$geoid)
# So I'll now join both these files on geoid
df_raw_brownfields_census <- inner_join(df_raw_brownfields, df_raw_census, by=c("geoid"))
dim(df_raw_brownfields_census) # 77856 rows in 1134 columns

# write the raw joined file to disc
write.csv(df_raw_brownfields_census, file =  "data//_volunteer_created_datasets//df_raw_brownfields_census.csv")
