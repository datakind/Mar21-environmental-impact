library(tidyverse)

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

#### acres based on state ####

geo_clean %>% 
  select(ACRES_Property_ID, Property_State) %>% 
  distinct(ACRES_Property_ID, .keep_all = TRUE) %>% 
  count(Property_State) %>% 
  ggplot(aes(x = reorder(Property_State, n), y = n)) +
  geom_bar(stat = "identity", fill = "blue4") +
  labs(title = "Number of ACRES properties by states",
       x = "Number of ACRES properties",
       y = "States"
      ) +
  coord_flip() 

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
  labs(title = "ACRES properties cleanup requirement",
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
  labs(title = "ACRES properties cleanup requirement",
       x = "Number of ACRES properties",
       y = "States",
       fill = "Cleanup required"
  ) +
  coord_flip()
  



