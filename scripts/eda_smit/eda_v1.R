
#################################
# EDA v1
# author: Smit Mehta
# github: @smit-m
#################################

# loading libraries
library(tidyverse)
library(leaflet)


# loading data
df <- read_csv('data/brownfields_data_with_county_geoid.zip')

# clean up column names
colnames_array <- colnames(df)
newcolnames <- gsub(' ', '_', 
                    gsub('%', 'pct', 
                         gsub('#', 'num', 
                              gsub('-', '_', 
                                   gsub(':', '', 
                                        gsub('/', '_', 
                                             gsub('\\(', '', 
                                                  gsub('\\)', '', 
                                                       gsub("\\[", '', 
                                                            gsub("\\]", '', 
                                                                 gsub('?', '', tolower(colnames_array))))))))))))

colnames(df) <- newcolnames


