closeAllConnections()
graphics.off()
rm(list = ls())

library(dplyr)
library(openxlsx)
library(tidyverse)
library(tictoc)
library(tm)



# USer working directory
setwd("C:/Users/Shannon/Documents/code_repositories/Mar21-environmental-impact")


# --- LOGICAL STEPS FOR CLEANUP ---#

# 1. General cleanup
#   - Format column names, data types, etc.
source("scripts/shannonloomis/cleanup.R")


# 2. Parse/combine fields for brevity
#   - Clean description history with NLP logic
source("scripts/shannonloomis/former_use_keyword_extraction.R")
#   - Combine contaminants that are similar
#   - Parse entity type to see if that matters??

# 3. Create site info table
#   - Name, location, etc. so it can be stripped out of 


# 4. Split by phase/action
#   - Break up into different assessment/cleanup phases
#   - Keep only relevant info for that phase






