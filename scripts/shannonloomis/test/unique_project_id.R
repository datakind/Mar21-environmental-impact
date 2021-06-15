closeAllConnections()
graphics.off()
rm(list = ls())

library(dplyr)
library(openxlsx)
library(tidyverse)
library(tictoc)


# USer working directory
setwd("C:/Users/Shannon/Documents/code_repositories/Mar21-environmental-impact")

# Load and clean data
source("scripts/munging/cleanup.R")




### ADDITIONAL CLEANING ###

# Remove unnecessary columns
v = c("Horizontal_Collection_Method","Source_Map_Scale",
      "Reference_Point","Horizontal_Reference_Datum")
geo_clean = geo_clean[,!(colnames(geo_clean) %in% v)]

# Clean up description history
geo_clean$Description_History = trimws(geo_clean$Description_History)
ind = geo_clean$Description_History == ''
geo_clean$Description_History[ind] = NA






# Isolate just location information
location = unique(geo_clean[,c("ACRES_Property_ID","Property_Name",
                               "Property_Address_1","Property_City",
                               "Property_State","Property_Zip_Code")])

# Count property ids
n = count(location,ACRES_Property_ID)
# *** ONLY ONE PROPERTY ID PER ADDRESS *** ###


# Count property ids
n = count(location,Property_Address_1,Property_City,Property_State,Property_Zip_Code)
# *** MULTIPLE DESCRIPTIVE ADDRESSES - CANNOT USE THIS AS UNIQUE *** #


# Location description
location_desc = unique(geo_clean[,c("ACRES_Property_ID","Property_Name",
                                    "Property_Address_1","Property_City",
                                    "Property_State","Property_Zip_Code",
                                    "Description_History")])
location_desc = location_desc[!is.na(location_desc$Description_History),]
n = count(location_desc,Description_History)
n = n[n$n>1,]
location_desc = inner_join(location_desc,n,by = "Description_History")

