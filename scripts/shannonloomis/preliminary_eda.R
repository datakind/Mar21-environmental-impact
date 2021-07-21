

### COST QUANTILES FUNCTIONS ###

get_cost_distribution = function(x,l) {
  
  # Join data and location info
  lj = l[,c("ACRES_Property_ID","Property_State")]
  y = inner_join(x,lj,by = "ACRES_Property_ID")
  y$Property_State = as.character(y$Property_State)
  
  # Remove territories
  r = c("AS","GU","MP","PR","VI")
  y = y[!(y$Property_State %in% r),]
  
  # Define quantiles of interest
  p = c(.1,.25,.5,.75,.9)
  
  # Get distribution of all data
  qx = quantile(y$cost,p)
  df = as.data.frame(t(as.matrix(round(qx))))
  colnames(df) = paste0("q",100*p)
  dfx = data.frame(state = "USA",df)
  
  # Split by state
  s = split(y,y$Property_State)
  qs = lapply(s, function(d) {
    q = quantile(d$cost,p)
    df = as.data.frame(t(as.matrix(round(q))))
    colnames(df) = paste0("q",100*p)
    return(df)
  })
  
  # Turn into dataframe
  df = do.call("rbind",qs)
  df = data.frame(state = rownames(df),df)
  df = rbind(df,dfx)
  
  return(df)
}


# Get cost distributions
cost_dist = list()
cost_dist$phaseI = get_cost_distribution(cost_phaseI,loc_clean)
cost_dist$phaseII = get_cost_distribution(cost_phaseII,loc_clean)
cost_dist$cleanup = get_cost_distribution(cost_cleanup,loc_clean)
write.xlsx(cost_dist,"scripts/shannonloomis/eda_plots/cost_dist_by_state.xlsx")

# # Check 
# smoothScatter(y$Assessment_Year,log10(y$cost),
#               xlab = "Year",ylab = "log10(Cost) [2020 Dollars]",
#               main = "Phase I - Entire USA")

