closeAllConnections()
graphics.off()
rm(list = ls())

library(curl)
library(dplyr)
library(openxlsx)
library(tidyverse)
library(tictoc)
library(tm)


tic("\nFull ACRES data processing")

# USer working directory
setwd("C:/Users/Shannon/Documents/code_repositories/Mar21-environmental-impact")
sd = "scripts/shannonloomis/"


# --- LOGICAL STEPS FOR CLEANUP ---#

# 1. General cleanup
#   - Format column names, data types, etc.
source(paste0(sd,"cleanup.R"))
#   *** working df = "geo_clean" ***


# 2. Parse Text fields
#   - Clean description history with NLP logic
source(paste0(sd,"former_use_keyword_extraction.R"))
#   *** working df = "geo_clean" ***
#   - Parse entity type to see if that matters??


# 3. Combine fields for brevity
#   - Combine contaminants that are similar
source(paste0(sd,"combine_contaminants.R"))
#   *** working df = "geo_clean" ***


# 4. Split by phase/action
#   - Break up into different assessment/cleanup phases
#   - Keep only relevant info for that phase
source(paste0(sd,"split_by_phase.R"))

# *** working data:
#       model_data =  list of dataframes for individual models
#       eda_data =    list of dataframes for EDA/
#                     joining additional datasets to model data based on geography


toc()


