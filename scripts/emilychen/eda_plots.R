library(tidyverse)
library(reshape2)

# Requires munging/cleanup.R and emilychen/Clean_aggregate_brownfields_data.R
# to be run first


# Assessment Cost by Phase ----------------------------------------------------
cost_by_phase <- assessment_agg %>%
  filter(!is.na(Assessment_Phase) & Assessment_Phase != 0) %>%
  mutate(
    Total_Assessment_Funding_log = log(Total_Assessment_Funding),
    Assessment_Phase = gsub(" Environmental Assessment", "", Assessment_Phase) %>%
      factor(levels = c("Phase I", "Phase II", "Supplemental Assessment", "Cleanup Planning"))
  )

ggplot(
  cost_by_phase, 
  aes(x = Assessment_Phase, y = Total_Assessment_Funding_log)) +
  geom_boxplot() +
  labs(
    x = "Phase",
    y = "Assessment Cost (log)",
    title = "Distribution of Assessment Cost by Phase"
  )


# Assessment Cost by Phase and Property Size ----------------------------------
ggplot(cost_by_phase, 
       aes(x = log(Property_Size), y = Total_Assessment_Funding_log,
           color = Assessment_Phase)) +
  facet_wrap(~ Assessment_Phase) +
  geom_smooth(method = "lm", se = F) +
  geom_point(alpha = 0.05)


# Clean up costs by contaminants ----------------------------------------------
cnmnt_cost <- cleanup_aggr %>%
  mutate(
    Num_Cntmtn_Fnd = factor(Num_Cntmtn_Fnd, levels = 1:13),
    Total_Cleanup_Funding_log = log(Total_Cleanup_Funding)
    
    )

ggplot(cnmnt_cost, aes(x = Num_Cntmtn_Fnd, y = Total_Cleanup_Funding_log)) +
  geom_boxplot() +
  labs(
    x = "Number of contaminants found",
    y = "Cleanup cost (log)"
  )



# Cleanup cost by group of contaminants ---------------------------------------
cnmnt_group_cost <- cleanup_aggr %>%
  ungroup() %>%
  filter(Total_Cleanup_Funding > 0) %>%
  select(
    Cntmnt_Fnd_Asbestos,
    Cntmnt_Fnd_Metal,
    Cntmnt_Fnd_PAH_SVOC,
    Cntmnt_Fnd_Other,
    Cntmnt_Fnd_VOCs,
    Cntmnt_Fnd_Petroleum,
    Total_Cleanup_Funding
  ) %>%
  melt(id = "Total_Cleanup_Funding") %>%
  mutate(
    Total_Cleanup_Funding_log = log(Total_Cleanup_Funding),
    variable_clean = gsub("Cntmnt_Fnd_", "", variable),
    value = ifelse(is.na(value), 0, value)
  ) %>%
  filter(value == 1)

ggplot(cmtnt_grps_fnd, aes(x = variable_clean, y = Total_Cleanup_Funding_log)) +
  geom_boxplot() +
  labs(
    x = "Contaminant Found",
    y = "Cleanup Funding (log)",
    title = "Cleanup cost by contaminant type found"
  )


# Cleanup cost by Media cleaned -----------------------------------------------
media_cleaned <- cleanup_aggr %>%
  ungroup() %>%
  select(contains("Media"), Total_Cleanup_Funding) %>%
  melt(id = "Total_Cleanup_Funding") %>%
  mutate(
    Total_Cleanup_Funding_log = log(Total_Cleanup_Funding),
    variable_clean = gsub("Media_Clnd_Up_", "", variable)
    
    ) %>%
  filter(value == 1)


ggplot(media_cleaned, aes(x = variable_clean, y = Total_Cleanup_Funding_log)) +
  # facet_wrap(~ variable_clean) +
  geom_boxplot() +
  labs(
    x = "Media Cleaned",
    y = "Cleanup cost (log)",
    title = "Cleanup cost by media cleaned"
  )








