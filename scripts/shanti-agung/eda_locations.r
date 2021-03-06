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
# if the property undergoes multiple assessment phases, and/or
# if a property experience several assessment-start-date for a type of assessment

geo_epa <- geo_clean %>% 
  select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date, Assessment_Phase) %>% 
  filter(!is.na(Assessment_Start_Date)) %>% 
  mutate(year = year(Assessment_Start_Date)) %>%
  distinct(ACRES_Property_ID, Assessment_Start_Date, .keep_all = TRUE) 


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

geo_epa %>% 
  filter(year > 1994) %>% 
  select(-Assessment_Start_Date) %>% 
  distinct(ACRES_Property_ID, Assessment_Phase, .keep_all = TRUE) %>% 
  ggplot(aes(x = EPA_Region, y = Assessment_Phase)) +
  geom_count(color = "darkblue") +
  theme(legend.position = "bottom")

# what's the average number of phases that a property experience? (out of the four)
geo_epa %>% 
  filter(year > 1994) %>% 
  select(-Assessment_Start_Date) %>% 
  distinct(ACRES_Property_ID, Assessment_Phase, .keep_all = TRUE) %>% 
  group_by(EPA_Region, ACRES_Property_ID) %>% 
  summarise(n_phase = n()) %>% 
  group_by(EPA_Region) %>% 
  summarise(avg_phases = mean(n_phase)) %>% 
  ungroup() %>% 
  ggplot(aes(x = reorder(EPA_Region, avg_phases), y = avg_phases)) +
  geom_bar(stat = "identity", fill = "chartreuse4") +
  labs(title = "Average number of phases per ACRES property (1995 - 2020)",
             x = "EPA Region",
             y = "Number of phases") +
  coord_flip()


# what's the distribution of number of phases per property across region?
geo_epa %>% 
  filter(year > 1994) %>% 
  select(-Assessment_Start_Date) %>% 
  distinct(ACRES_Property_ID, Assessment_Phase, .keep_all = TRUE) %>% 
  group_by(EPA_Region, ACRES_Property_ID) %>% 
  summarise(n_phase = n()) %>% 
  ungroup() %>% 
  ggplot(aes(x = EPA_Region, fill = as.factor(n_phase))) +
  geom_bar(position = "dodge") +
  labs(title = "Phases per ACRES property (1995 - 2020)",
       x = "EPA Region",
       y = "Number of properties",
       fill = "Number of phases per ACRES property"
  ) +
  theme(legend.position = "bottom")

# ** investigate duplicates **
# geo_clean %>% 
#   filter(ACRES_Property_ID == 58901 & Assessment_Phase == "Supplemental Assessment" & 
#            Assessment_Start_Date == "2008-08-14") %>% 
#   view()
# 
# geo_clean %>% 
#   select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date, Assessment_Phase,
#          Source_of_Assessment_Funding, Entity_Providing_Assmnt_Funds, Amt_of_Assessment_Funding,
#          Source_of_Cleanup_Funding, Amount_of_Cleanup_Funding) %>% 
#   filter(!is.na(Assessment_Start_Date)) %>% 
#   distinct(ACRES_Property_ID, Assessment_Start_Date, Assessment_Phase,
#            Source_of_Assessment_Funding, Entity_Providing_Assmnt_Funds,
#            Amt_of_Assessment_Funding, Source_of_Cleanup_Funding,
#            Amount_of_Cleanup_Funding,
#            .keep_all = TRUE) %>% 
#   filter(ACRES_Property_ID == 58901 & Assessment_Phase == "Supplemental Assessment") %>% 
#   .[2:3,] %>% 
#   view()
# 
# geo_clean %>% 
#   select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date, Assessment_Phase,
#          Source_of_Assessment_Funding, Entity_Providing_Assmnt_Funds, Amt_of_Assessment_Funding,
#          Source_of_Cleanup_Funding, Amount_of_Cleanup_Funding) %>% 
#   filter(!is.na(Assessment_Start_Date)) %>% 
#   distinct(ACRES_Property_ID, Assessment_Start_Date, Assessment_Phase,
#            .keep_all = TRUE) %>% 
#   filter(ACRES_Property_ID == 16087 & Assessment_Phase == "Supplemental Assessment") %>% 
#   view()
# 
# geo_clean %>% 
#   select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date, Assessment_Phase) %>% 
#   filter(!is.na(Assessment_Start_Date)) %>% 
#   mutate(year = year(Assessment_Start_Date)) %>% 
#   filter(year > 1994) %>% 
#   distinct(ACRES_Property_ID, Assessment_Start_Date, .keep_all = TRUE) %>% 
#   filter(ACRES_Property_ID == 16087 & Assessment_Phase == "Phase II Environmental Assessment") %>% 
#   view()

# ACRES_Property_ID == 58901
# ACRES_Property_ID == 16087
  # Supplemental Assessment : 11 times (at different start-assessment-date)
  # Cleanup Planning: 1 time
  # Phase I Environmental Assessment: 2 times 
  # Phase II Environmental Assessment: 11 times -- one phase that stretch from 2004 - 2020, (receive funding diff amount per entry)

# ** end investigate duplicates **

# how long does each phase generally take? any pattern across epa region?

geo_epa <- geo_clean %>% 
  select(ACRES_Property_ID, EPA_Region, Assessment_Start_Date, Assessment_Completion_Date, Assessment_Phase) %>% 
  filter(!is.na(Assessment_Start_Date)) %>% 
  mutate(year = year(Assessment_Start_Date)) %>%
  distinct(ACRES_Property_ID, Assessment_Start_Date, .keep_all = TRUE) 

ph_duration <- geo_epa %>% 
  filter(year > 1994) %>% 
  mutate(phase_duration = Assessment_Completion_Date - Assessment_Start_Date + 1) %>% 
  group_by(ACRES_Property_ID, Assessment_Phase) %>% 
  mutate(total_duration = sum(phase_duration)) %>% # check for negative numbers
  ungroup() %>% 
  distinct(ACRES_Property_ID, EPA_Region, Assessment_Phase, total_duration, .keep_all = TRUE)

# ph_duration %>% 
#   filter(total_duration < 0)
# 
# ph_duration %>% 
#   filter(ACRES_Property_ID == 90742)
# 
# 
#   filter(ACRES_Property_ID == 16087 & Assessment_Phase == "Phase II Environmental Assessment") %>%
#   view()



# what's the number of funding per phase? do they differ across phase?


# what are the average costs look like across region?


# what does the average cost look like by region and assessment type?

# what's the length of assessment look like across epa regions?

# contaminant types (metal etc) by epa regions
  
# cost!!


