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


# read the raw dataset in memory
df_raw_census <- read.csv("data/national_acs5-2018_census.csv", na.strings=c("","NA"))
df_raw_brownfields <- read.csv("data/brownfields_data_with_county_geoid.csv", na.strings=c("","NA"))

# 1. Exploratory Data Analysis

# 1.1. check data dimension
dim(df_raw_census) # [1] 3220 rows in 1034 columns
dim(df_raw_brownfields) # [1] 78527 rows in 150 columns

# 1.2. check for missing data
sum(is.na(df_raw_census)) # 237712 missing values
sum(is.na(df_raw_brownfields)) # 7517972  missing values


# 1.3 Find variables with zero variance and remove them
excluded_vars  <- df_raw_census %>%
  summarise_all(var) %>%
  select_if(function(.) . == 0) %>% 
  names() 
## Finding: df_raw_census data has 49 variables with zero variance 
## Finding: df_raw_brownfields data has 01 variable with zero variance

# remove the 49 variables with zero variance from df_raw_census dataframe
df_raw_census<- df_raw_census %>%
  select(-one_of(excluded_vars))
dim(df_raw_census) # [1] 3220  985

# remove the 01 variable with zero variance from df_raw_brownfields dataframe
excluded_vars  <- df_raw_brownfields %>%
  summarise_all(var) %>%
  select_if(function(.) . == 0) %>% 
  names()
df_raw_brownfields <- df_raw_brownfields %>%
  select(-one_of(excluded_vars))
dim(df_raw_brownfields) # [1] 78527   149

# remove missing data from df_raw_census dataframe
df_raw_census <- df_raw_census %>%
  drop_na()

colSums(is.na(df_raw_brownfields))
names(df_raw_brownfields)[colSums(is.na(df_raw_brownfields)) >0] 
# # 143 variables out of  149 variables in brownfields dataframe has missing values
