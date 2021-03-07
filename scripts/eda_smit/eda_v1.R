
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




##### Visualizations

# mapping assessment funded properties

# separate maps
phase_1_df <- subset(df, assessment_phase == "Phase I Environmental Assessment", select = c(acres_property_id, property_latitude, property_longitude))
phase_1_df <- phase_1_df %>% distinct()

phase_2_df <- subset(df, assessment_phase == "Phase II Environmental Assessment", select = c(acres_property_id, property_latitude, property_longitude))
phase_2_df <- phase_2_df %>% distinct()

phase_3_df <- subset(df, assessment_phase == "Cleanup Planning", select = c(acres_property_id, property_latitude, property_longitude))
phase_3_df <- phase_3_df %>% distinct()

phase_4_df <- subset(df, assessment_phase == "Supplemental Assessment", select = c(acres_property_id, property_latitude, property_longitude))
phase_4_df <- phase_4_df %>% distinct()

phase_1_map <- leaflet(phase_1_df) %>% addTiles() %>%
  addCircleMarkers(~property_longitude, ~property_latitude, 
                   radius = 2,
                   color = "red", 
                   fillOpacity = 0.5, 
                   label = ~as.character(acres_property_id), 
                   #clusterOptions = markerClusterOptions()
  )
phase_1_map

phase_2_map <- leaflet(phase_2_df) %>% addTiles() %>%
  addCircleMarkers(~property_longitude, ~property_latitude, 
                   radius = 2,
                   color = "blue", 
                   fillOpacity = 0.5, 
                   label = ~as.character(acres_property_id), 
                   #clusterOptions = markerClusterOptions()
  )
phase_2_map

phase_3_map <- leaflet(phase_3_df) %>% addTiles() %>%
  addCircleMarkers(~property_longitude, ~property_latitude, 
                   radius = 2,
                   color = "green", 
                   fillOpacity = 0.5, 
                   label = ~as.character(acres_property_id), 
                   #clusterOptions = markerClusterOptions()
  )
phase_3_map

phase_4_map <- leaflet(phase_4_df) %>% addTiles() %>%
  addCircleMarkers(~property_longitude, ~property_latitude, 
                   radius = 2,
                   color = "orange", 
                   fillOpacity = 0.5, 
                   label = ~as.character(acres_property_id), 
                   #clusterOptions = markerClusterOptions()
  )
phase_4_map


# combined maps 

combined_df <- subset(df, select = c(acres_property_id, property_latitude, property_longitude, assessment_phase))
combined_df <- combined_df %>% distinct()
combined_df <- combined_df[which(combined_df$assessment_phase != "NA"), ]

col_pal <- colorFactor(c("red", "blue", "green", "orange"), domain = c("Phase I Environmental Assessment", "Phase II Environmental Assessment", "Cleanup Planning", "Supplemental Assessment"))

# without leaflet clusters
combined_map <- leaflet(combined_df) %>% addTiles() %>%
                  addCircleMarkers(~property_longitude, ~property_latitude, 
                    radius = ~ifelse(assessment_phase == "Supplemental Assessment", 5, 2), 
                    color = ~col_pal(assessment_phase), 
                    fillOpacity = ~ifelse(assessment_phase == "Supplemental Assessment", 0.25, 0.5), 
                    label = ~as.character(acres_property_id), 
                    #clusterOptions = markerClusterOptions()
  )

combined_map

# with leaflet clusters
combined_map_clustered <- leaflet(combined_df) %>% addTiles() %>%
  addCircleMarkers(~property_longitude, ~property_latitude, 
                   radius = ~ifelse(assessment_phase == "Supplemental Assessment", 5, 2), 
                   color = ~col_pal(assessment_phase), 
                   fillOpacity = ~ifelse(assessment_phase == "Supplemental Assessment", 0.25, 0.5), 
                   label = ~as.character(acres_property_id), 
                   clusterOptions = markerClusterOptions()
  )

combined_map_clustered



