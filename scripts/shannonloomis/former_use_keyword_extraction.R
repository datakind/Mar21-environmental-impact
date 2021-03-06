

tic("Former use extraction")



# library(tidyverse)
# library(tm)
# 
# 
# 
# geo_data_raw = read_csv('data/brownfields_data_with_county_geoid.zip')
# 
# ## Information relative to properties
# properties = geo_data_raw %>% select(`ACRES Property ID`,`Property Zip Code`,`Property Size`,`Ownership Entity`,`Property Latitude`,`Property Longitude`,`Description_History`,Highlights,matches("Past|Future")) %>% distinct()



##########################################################################################
######################            Exploration                #############################
##########################################################################################

properties = geo_clean %>% 
  select(ACRES_Property_ID,Description_History,Highlights) %>% 
  distinct()

h = properties$Highlights
dh = properties$Description_History

## Description History keywords
dh = tolower(dh)
stop_words = paste0("(?<=\\b)(?:",paste0(stopwords("english"),collapse="|"),")(?=\\b)")
dh = str_remove_all(dh,stop_words)
dh_plus = paste(dh, collapse = " ")

## The regular expressions can be used to extract keywords of interest to further label properties.
## The most common keywords are given in the common_yard_word, common_building_word etc. tables 
## If, for example, commercial building is identified as a keyword of interest, we can build a flag column using str_detect(x,"(?i)commercial(?:[a-z/\\-]*)(\\s*(?:site\\s+)?building")


## Building
building_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+(?=\\s*(?:site[\\s\\-])?building)")))
building_words = building_words[nchar(building_words)>2]
building_words = building_words[!str_detect(building_words,"one|two|three|four|five|storey|floor|square|foot|feet|^site$")]
building_word_list = unique(building_words)
building_word_table = sort(table(building_words),decr=T)
common_building_word = building_word_table[1:20]
common_building_word

## Property
property_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+(?=\\s*(?:site[\\s\\-])?property)")))
property_words = property_words[nchar(property_words)>2]
property_words = property_words[!str_detect(property_words,"one|two|three|four|five|storey|floor|square|foot|feet|^site$")]
property_word_list = unique(property_words)
property_word_table = sort(table(property_words),decr=T)
common_property_word = property_word_table[1:30]
common_property_word

## Facility
facility_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+(?=\\s*(?:site[\\s\\-])?facility)")))
facility_words = facility_words[nchar(facility_words)>2]
facility_words = facility_words[!str_detect(facility_words,"one|two|three|four|five|storey|floor|square|foot|feet|^site$")]
facility_word_list = unique(facility_words)
facility_word_table = sort(table(facility_words),decr=T)
common_facility_word = facility_word_table[1:20]
common_facility_word

## House
house_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+(?=\\s*house)")))
house_words = house_words[nchar(house_words)>2]
house_words = house_words[!str_detect(house_words,"one|two|three|four|five|storey|floor|square|foot|feet|^site$|formerly|currently|previously|^also$")]
house_words_list = unique(house_words)
house_word_table = sort(table(house_words),decr=T)
common_house_word = house_word_table[1:10]
common_house_word

## Yard
yard_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+(?=\\s*yard)")))
yard_words = yard_words[nchar(yard_words)>2]
yard_words = yard_words[!yard_words %in% c("cubic")]
yard_word_list = unique(yard_words)
yard_word_table = sort(table(yard_words),decr=T)
common_yard_word = yard_word_table[1:10]
common_yard_word

## Land
land_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+\\s*(?=lands?\\b)")))
land_words = land_words[nchar(land_words)>2]
land_words = land_words[!str_detect(land_words,"one|two|three|four|five|storey|floor|square|foot|feet|^site$")]
land_words_list = unique(land_words)
land_word_table = sort(table(land_words),decr=T)
common_land_word = land_word_table[1:10]
common_land_word

## Site
site_words = str_squish(unlist(str_extract_all(dh_plus,"(?i)[a-z/\\-]+\\s*(?=sites?\\b)")))
site_words = site_words[nchar(site_words)>2]
site_words_list = unique(site_words)
site_word_table = sort(table(site_words),decr=T)
common_site_word = site_word_table[1:10]
common_site_word


## used as a ...
## This wording is usually found to describe industrial, commercial facilities or institutions (school..).
## The extraction of former use returns a value for 2146 out of 35021 unique properties
former_use = unlist(lapply(str_match_all(properties$`Description_History`,"used[^.]*?\\sas\\s+a\\s+([^.,;]+)"),function(m) paste(m[,2],collapse = " ")))
former_use[former_use==""] = NA
former_use_words = unlist(str_extract_all(str_remove_all(paste(former_use,collapse = " "),stop_words),"[a-zA-Z\\-/]+"))
former_use_table = sort(table(former_use_words),decr=T)
common_former_use = former_use_table[1:40]
common_former_use



##########################################################################################
##########################            Features                ############################
##########################################################################################


## Feature generation

properties = properties %>% mutate(commercial_building = str_detect(`Description_History`,"(?i)commercial[a-z/\\-]*\\s*(?:site\\s+)?building"),
									repair_facility = str_detect(`Description_History`,"(?i)repair[a-z/\\-]*\\s*(?:site\\s+)?facility"),
									storage_facility_or_warehouse = str_detect(`Description_History`,"(?i)storage[a-z/\\-]*\\s*(?:site\\s+)?(?:facility|yard)|ware[\\s+-]house"),
									manufacture = str_detect(`Description_History`,"(?i)manufactur"),	
									residential = str_detect(`Description_History`,"(?i)residential"),	
									store = str_detect(`Description_History`,"(?i)\\bstore|shop|\\bretail"),	
									parking = str_detect(`Description_History`,"(?i)parking"),	
									school = str_detect(`Description_History`,"(?i)school"),
									industrial = str_detect(`Description_History`,"(?i)industr(?:ial|y)"),
									rail = str_detect(`Description_History`,"(?i)\\brail|\\btrains?\\b"),
									vacant = str_detect(`Description_History`,"(?i)\\bvacant"),
									farm_land = str_detect(`Description_History`,"(?i)(?:farm|agricultural)[a-z/\\-]*\\s*lands?\\b"),
									forest = str_detect(`Description_History`,"(?i)forest|\\btimber\\b|\\bwood"),
									wet_land = str_detect(`Description_History`,"(?i)\\bwet\\s+land|\\bswamp"),
									junk_yard = str_detect(`Description_History`,"(?i)(?:junk|scrap|salvage)[a-z/\\-]*\\s*yard"),
									undeveloped = str_detect(`Description_History`,"(?i)undeveloped")
									)
	

# properties = properties %>% mutate(nchar_history = nchar(`Description_History`),
# 									nb_dates_history = str_count(`Description_History`,"(19|20)\\d{2}|\\b\\d0.s")
# 									)
#
# write.csv(properties,"scripts/shannonloomis/property_history.csv",row.names = FALSE)


### ADD BACK ONTO GEO_CLEAN ###
d = properties
d$Description_History = NULL
d$Highlights = NULL

geo_clean = left_join(geo_clean,d,by = "ACRES_Property_ID")


toc()