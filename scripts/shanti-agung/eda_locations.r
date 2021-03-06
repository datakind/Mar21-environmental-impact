library(tidyverse)
library(lubridate)

#### dataset ####
# use dataset resulting from cleanup.R

colnames(geo_clean) 
colnames(acs_data)

geo_acs <- geo_clean %>% 
  left_join(acs_data, by = "GEOID")

# dim(geo_clean)
# geo_clean[,1]
# dim(acs_data)
# acs_data[,1]
#colnames(geo_acs[,1:150])

# what's the time span of this dataset?
min(year(geo_clean$Assessment_Start_Date), na.rm = TRUE)
max(year(geo_clean$Assessment_Start_Date), na.rm = TRUE)



#### by states ####

# how do the number of properties look like across states (1970 - 2020)?
geo_clean %>% 
  select(ACRES_Property_ID, Property_State) %>% 
  distinct(ACRES_Property_ID, .keep_all = TRUE) %>% 
  count(Property_State) %>% 
  ggplot(aes(x = reorder(Property_State, n), y = n)) +
  geom_bar(stat = "identity", fill = "blue4") +
  labs(title = "Number of ACRES properties (1970 - 2020)",
       x = "Number of ACRES properties",
       y = "States"
      ) +
  coord_flip() 

# how do the number of properties (that needs cleaning) look like across states (1970 - 2020)?
# properties that need cleaning by state

geo_clean %>% 
  count(Cleanup_Required)

    # count
geo_clean %>% 
  select(ACRES_Property_ID, Property_State, Cleanup_Required) %>% 
  filter(!is.na(Cleanup_Required)) %>% 
  distinct(ACRES_Property_ID, .keep_all = TRUE) %>% 
  group_by(Property_State) %>% 
  count(Cleanup_Required) %>% 
  ggplot(aes(x = reorder(Property_State, n), y = n, fill = Cleanup_Required)) +
  geom_bar(stat = "identity") +
  labs(title = "ACRES properties cleanup requirement (1970 - 2020)",
       x = "Number of ACRES properties",
       y = "States",
       fill = "Cleanup required"
  ) +
  coord_flip()

  # proportion

geo_clean %>% 
  select(ACRES_Property_ID, Property_State, Cleanup_Required) %>% 
  filter(!is.na(Cleanup_Required)) %>% 
  distinct(ACRES_Property_ID, .keep_all = TRUE) %>% 
  group_by(Property_State) %>% 
  count(Cleanup_Required)%>% 
  ggplot(aes(x = reorder(Property_State, n), y = n, fill = Cleanup_Required)) +
  geom_bar(stat = "identity", position = "fill") +
  labs(title = "ACRES properties cleanup requirement (1970 - 2020)",
       x = "Number of ACRES properties",
       y = "States",
       fill = "Cleanup required"
  ) +
  coord_flip()


#### by epa regions ####

# how many epa regions are there?
geo_clean %>% 
  count(EPA_Region)

# what's the average number of properties per year in an epa region?
geo_epa <- geo_clean %>% 
  select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date) %>% 
  filter(!is.na(Assessment_Start_Date)) %>% 
  distinct(ACRES_Property_ID, .keep_all = TRUE) %>% 
  mutate(year = year(Assessment_Start_Date))

geo_epa %>% 
  group_by(EPA_Region) %>% 
  group_by(EPA_Region, year) %>%
  summarize(n_properties = n()) %>% 
  group_by(EPA_Region) %>% 
  summarize(avg_properties = mean(n_properties)) %>% 
  ungroup() %>% 
  ggplot(aes(x = reorder(EPA_Region, -avg_properties), y = avg_properties)) +
  geom_bar(stat = "identity", fill = "coral2") +
  labs(title = "Average number of ACRES properties per year",
       x = "EPA Region",
       y = "Avg number of ACRES properties"
  )

# how does the number of acres properties changes over the years by regions?

geo_epa %>% 
  group_by(EPA_Region, year) %>%
  summarize(n_properties = n()) %>% 
  ungroup() %>% 
  ggplot(aes(x = year, y = n_properties, colour = EPA_Region)) +
  geom_line() +
  labs(title = "ACRES properties by EPA region (1970 - 2020)",
       x = "Number of ACRES properties",
       y = "Year",
       colour = "EPA Region"
  )

# how does the type of assessments varies between 1995 - 2020 across epa regions?

# recreate geo_epa with required vars, this time an acres_property_id may appear multiple times
# if the property undergoes multiple assessment phases

geo_epa <- geo_clean %>% 
  select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date, Assessment_Phase) %>% 
  filter(!is.na(Assessment_Start_Date)) %>% 
  mutate(year = year(Assessment_Start_Date))

geo_epa%>% 
  filter(year > 1994)%>% 
  group_by(EPA_Region, Assessment_Phase) %>% 
  summarise(n_phase = n()) %>% 
  ungroup() %>% 
  ggplot(aes(x = EPA_Region, y = n_phase)) +
  geom_bar(aes(fill = Assessment_Phase), position = "dodge", stat = "identity") +
  labs(title = "Assessment Phases on ACRES properties (1995 - 2020)",
       x = "EPA Region",
       y = "Number of ACRES properties",
       fill = "Assessment Phase"
  ) 

# what's the average phase that a property experience? (out of the four)

# what are the average costs look like across region?


# what does the average cost look like by region and assessment type?

# what's the length of assessment look like across epa regions?

# contaminant types (metal etc) by epa regions


