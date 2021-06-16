

tic("Data split for EDA and modeling")

wdf = geo_clean[!is.na(wdf$ACRES_Property_ID),]


#################################
# GROUP COLUMNS FOR PHASE SPLIT #
#################################


### ISOLATE GRANT AND LOCATION INFORMATION ###

# Define location parameters
iv = "ACRES_Property_ID"
lv = c("Property_Name",
       "Property_Address_1","Property_City","Property_State","Property_Zip_Code",
       "IC_Data_Address","Local_Parcel_Number",
       "Ownership_Entity","Current_Owner",
       "Did_Ownership_Change","SFLLP_fact_into_the_ownership",
       "Property_Latitude","Property_Longitude",
       "GEOID","County_Name","Property_City_clean","EPA_Region")
gv = c("Grant_Recipient_Name","Cooperative_Agreement_Number",
       "Type_of_Brownfields_Grant","ST_Tribal_Prg_ID_Number","Grant_ID")

# Get location information
loc_clean = unique(wdf[,c(iv,lv)])

# Grant info
grant_clean = unique(wdf[,c(iv,gv)])

# Remove location information from working model data
wdf = wdf[,!(colnames(wdf) %in% c(lv,gv))]
#geo_clean = wdf



### DEFINE GROUPS OF VARIABLES FOR MODEL ADDITION ###

pred = list(id = iv,
            cntmnt_fnd = colnames(wdf)[grep("Cntmnt_Fnd",colnames(wdf))],
            cntmnt_clnd_up = colnames(wdf)[grep("Cntmnt_Clnd_Up",colnames(wdf))],
            media_affected = colnames(wdf)[grep("Media_Affected",colnames(wdf))],
            media_clnd_up = colnames(wdf)[grep("Media_Clnd_Up",colnames(wdf))],
            future_use = colnames(wdf)[grep("Future_Use",colnames(wdf))],
            past_use = colnames(wdf)[grep("Past_Use",colnames(wdf))],
            use_desc = colnames(properties)[!(colnames(properties) %in% 
                                                   c("ACRES_Property_ID","Description_History","Highlights"))],
            acs2010 = colnames(wdf)[grep("_2010",colnames(wdf))],
            ics = colnames(wdf)[grep("IC",colnames(wdf))],
            assmnt = colnames(wdf)[grep("Assessment",colnames(wdf))],
            cleanup = c(colnames(wdf)[grep("Cleanup",colnames(wdf))],
                        "ACRES_Cleaned_Up","Acreage_and_Greenspace_Created"),
            redev = colnames(wdf)[grep("Redev",colnames(wdf))],
            prop_info= c("Property_Size"),
            pgm = c("Type_of_Funding","Entity_Providing_Assmnt_Funds",
                    "Enrollment_ST_Tribal_Prg","Program_Code"))



### PROPERTY INFO ###

# Pull data of interest
v = c("id","prop_info","past_use","use_desc","future_use","acs2010")
n = unlist(pred[names(pred) %in% v])
d = unique(wdf[,n])

# Find sites with duplicate rows
c = count(d,ACRES_Property_ID)
c = c[c$n > 1,]
y = d[d$ACRES_Property_ID %in% c$ACRES_Property_ID,]

# Split by site and pick one with closest use values property size
y = split(y,y$ACRES_Property_ID)
y = lapply(y, function(a) {
   x = a
   
   # Past use
   u = apply(x[,colnames(x)[grep("Past_Use",colnames(x))]],1,function(z) {sum(z,na.rm = T)})
   x$diff = abs(x$Property_Size - u)
   m = min(x$diff)
   x = x[x$diff == m,]
   
   # Future use
   u = apply(x[,colnames(x)[grep("Future_Use",colnames(x))]],1,function(z) {sum(z,na.rm = T)})
   x$diff = abs(x$Property_Size - u)
   m = min(x$diff)
   x = x[x$diff == m,]
   
   # Give result back
   x$diff = NULL
   return(x[1,])
})

# Add back to main dataframe
y = do.call("rbind",y)
d = d[!(d$ACRES_Property_ID %in% y$ACRES_Property_ID),]
d = rbind(d,y)
prop_info = d




### CONTAMINANTS FOUND AND MEDIA AFFECTED ###

# Get contaminants and media
v = c("id","cntmnt_fnd","media_affected")
x = wdf[!is.na(wdf$ACRES_Property_ID),]
n = unlist(pred[names(pred) %in% v])
d = unique(x[,n])
cntmnt_media = d





####################################
# PHASE I ENVIRONMENTAL ASSESSMENT #
####################################

# Define phases and variable groups
p = 'Phase I Environmental Assessment'
a = "Adj_Amt_of_Assessment_Funding"
v = c("id","assmnt")

# Pull data of interest
x = wdf[wdf$Assessment_Phase %in% p & !is.na(wdf[[a]]) &!is.na(wdf$ACRES_Property_ID),]
n = unlist(pred[names(pred) %in% v])
d = x[,n]

# Define cost column and remove everything less than $100 or over $100k
d$cost = round(d[[a]])
d = d[d$cost >= 100 & d$cost <= 100000,]

# Remove unnecessary columns
v = c("Assessment_Phase","Source_of_Assessment_Funding",
      "Amt_of_Assessment_Funding","Assessment_CPI","Adj_Amt_of_Assessment_Funding")
d = d[,!(colnames(d) %in% v)]
d = unique(d)

# Remove duplicates (pick most recent that has been completed)
l = split(d,d$ACRES_Property_ID)
l = lapply(l, function(x) {
   y = x
   if (nrow(y) > 1) {
      # Remove those without completion dates
      ind = which(!is.na(y$Assessment_Completion_Date))
      if (length(ind) > 0) {y = y[ind,]}
      
      # Get one with max start date
      m = max(y$Assessment_Start_Date)
      y = y[y$Assessment_Start_Date == m,]
      
      # Pick value closest to median cost (looks like a lot are probably Phase IIs that have been miscategorized)
      m = abs(y$cost - median(d$cost))
      y = y[m == min(m),]
      
      # Pick first row (some still have dups for end date)
      y = y[1,]
   }
   return(y)
})
d = do.call("rbind",l)


# # Look at cost of assessment
# cost = d$cost
# q = quantile(cost,probs = c(.01,.05,.1,.5,.9,.95,.99),na.rm = TRUE)
# hist(log10(cost),breaks = 50,main = "Phase I Adjusted Cost",xlab = "log10(cost) (2020 dollars)")

# *** Leaving data here - clearly some weird spikes at lower end, 
#     but decent log normal distribution overall ***
d = inner_join(d,prop_info,by = "ACRES_Property_ID")
cost_phaseI = d[,c("cost",colnames(d)[colnames(d) != "cost"])]





#################################
# PHASE II AND SUPP ASSESSMENTS #
#################################

### ADVANCE TO ADDITIONAL ASSESSMENT ###

# Determine if site goes to next assessment phase
x = unique(wdf[,c("ACRES_Property_ID","Assessment_Phase",
                  "Cleanup_Required","Institutional_Ctrl_ICs_Req")])
x$Supp_Assessment_Req = NA
x$Supp_Assessment_Req[!is.na(x$Assessment_Phase)] = 1
x$Supp_Assessment_Req[x$Assessment_Phase == 'Phase I Environmental Assessment'] = 0
x$req = apply(x,1,function(x) {max(x[3:5],na.rm = T)})
x = x[!is.na(x$req),c("ACRES_Property_ID","req")]
x = aggregate(x$req,by = list(ACRES_Property_ID = x$ACRES_Property_ID),FUN = max)
colnames(x)[2] = "req"
x[,2] = as.numeric(x[,2])

# Join phase to site data
j = inner_join(prop_info,x,by = "ACRES_Property_ID")
req_phaseII = j[,c("req",colnames(j)[!(colnames(j) %in% "req")])]




### COST - PHASE II/SUPPLEMENTAL ASSESSMENT ###

# Define phases and variable groups
p = c('Phase II Environmental Assessment',"Supplemental Assessment")
a = "Adj_Amt_of_Assessment_Funding"
v = c("id","assmnt")

# Pull data of interest
x = wdf[wdf$Assessment_Phase %in% p & !is.na(wdf[[a]]) &!is.na(wdf$ACRES_Property_ID),]
n = unlist(pred[names(pred) %in% v])
d = x[,n]

# Define cost column and remove everything less than $100 or over $100k
d$cost = round(d[[a]])
d = d[d$cost >= 100,]

# Remove unnecessary columns
v = c(#"Assessment_Phase","Source_of_Assessment_Funding",
      "Amt_of_Assessment_Funding","Assessment_CPI","Adj_Amt_of_Assessment_Funding")
d = d[,!(colnames(d) %in% v)]
d = unique(d)

# # Split by site and examine multi rows
# l = split(d,d$ACRES_Property_ID)
# r = unlist(lapply(l, nrow))
# ind = which(r > 1)
# xl = l[ind]
# *** No real pattern. Summing cost bc can have multiple phase IIs 
#     and/or supplemental assessments ***

# Summarize assessment data by site
da = d %>%  
   group_by(ACRES_Property_ID) %>% 
   summarise(cost = sum(cost),
             Assessment_Start_Date = min(Assessment_Start_Date),
             Assessment_Completion_Date = max(Assessment_Completion_Date),
             Assessment_Year = min(Assessment_Year),
             Individual_Assessments = n())

# # Look at cost of assessment
# cost = da$cost
# q = quantile(cost,probs = c(.01,.05,.1,.5,.9,.95,.99),na.rm = TRUE)
# hist(log10(cost),breaks = 50,main = "Phase II Adjusted Cost",xlab = "log10(cost) (2020 dollars)")
# for (i in 3:5) {
#    plot(da[[i]],log10(da$cost),
#         xlab = colnames(da)[i],ylab = "log10(cost) (2020 dollars)")
# }

# *** No striking biased patterns jumping out. Stopping here. ***

d = inner_join(prop_info,da,by = "ACRES_Property_ID")
cost_phaseII = d[,c("cost",colnames(d)[colnames(d) != "cost"])]





################
# SITE CLEANUP #
################


### ADVANCE TO CLEANUP ###

# Determine if site goes to cleanup
x = unique(wdf[,c("ACRES_Property_ID","Cleanup_Required",
                  "Institutional_Ctrl_ICs_Req","Amount_of_Cleanup_Funding")])
x$Cleanup_Funding = NA
x$Cleanup_Funding[x$Amount_of_Cleanup_Funding >= 1000] = 1
x$Amount_of_Cleanup_Funding = NULL
x$req = apply(x,1,function(x) {max(x[2:4],na.rm = T)})
x = x[!is.infinite(x$req),c("req","ACRES_Property_ID")]
x = aggregate(x$req,by = list(ACRES_Property_ID = x$ACRES_Property_ID),FUN = max)
colnames(x)[2] = "req"
x[,2] = as.numeric(x[,2])

# Join phase to site data
j = inner_join(prop_info,x,by = "ACRES_Property_ID")
j = inner_join(j,cntmnt_media,by = "ACRES_Property_ID")
req_cleanup = j[,c("req",colnames(j)[!(colnames(j) %in% "req")])]




### CLEANUP PLANNING COST ###

# Define phases and variable groups
p = 'Cleanup Planning'
a = "Adj_Amt_of_Assessment_Funding"
v = c("id","assmnt")

# Pull data of interest
x = wdf[wdf$Assessment_Phase %in% p & !is.na(wdf[[a]]) &!is.na(wdf$ACRES_Property_ID),]
n = unlist(pred[names(pred) %in% v])
d = unique(x[,n])

# Define cost column and remove everything less than $100
d$cost = round(d[[a]])
d = d[d$cost >= 100,]

# # Split by site and examine multi rows
# l = split(d,d$ACRES_Property_ID)
# r = unlist(lapply(l, nrow))
# ind = which(r > 1)
# xl = l[ind]
# *** No real pattern. Summing cost bc can have multiple phase IIs
#     and/or supplemental assessments ***

# Remove unnecessary columns
v = c("Assessment_Phase",#"Source_of_Assessment_Funding",
   "Amt_of_Assessment_Funding","Assessment_CPI","Adj_Amt_of_Assessment_Funding")
d = d[,!(colnames(d) %in% v)]
d = unique(d)


# Summarize assessment data by site
da = d %>%  
   group_by(ACRES_Property_ID) %>% 
   summarise(planning_cost = sum(cost),
             Assessment_Start_Date = min(Assessment_Start_Date),
             Assessment_Completion_Date = max(Assessment_Completion_Date),
             Assessment_Year = min(Assessment_Year),
             Individual_Assessments = n())
cleanup_planning = da




### CLEANUP COST ###

# Define phases and variable groups
a = "Adj_Amount_of_Cleanup_Funding"
v = c("id","cleanup")

# Pull data of interest
x = wdf[!is.na(wdf[[a]]) &!is.na(wdf$ACRES_Property_ID),]
n = unlist(pred[names(pred) %in% v])
d = unique(x[,n])

# Define cost column and remove everything less than $100
d$cost = round(d[[a]])
d = d[d$cost >= 100,]

# # Split by site and examine multi rows
# l = split(d,d$ACRES_Property_ID)
# r = unlist(lapply(l, nrow))
# ind = which(r > 1)
# xl = l[ind]
# *** Summing cost bc usually from multiple sources and/or dates ***


# Summarize cleanup data by site
da = d %>%  
   group_by(ACRES_Property_ID) %>% 
   summarise(cleanup_cost = sum(cost),
             Cleanup_Start_Date = min(Cleanup_Start_Date),
             Cleanup_Completion_Date = max(Cleanup_Completion_Date),
             Cleanup_Year = min(Cleanup_Year),
             Acres_Cleaned_Up = median(ACRES_Cleaned_Up),
             Acreage_and_Greenspace_Created = median(Acreage_and_Greenspace_Created),
             Individual_Cleanups = n())
cleanups = da




### COMBINE PLANNING AND CLEANING COST FOR FULL COST OF CLEANUP ###

# Join and add cost
d = full_join(cleanup_planning,cleanups,by = "ACRES_Property_ID")
p = d$planning_cost
p[is.na(p)] = 0
c = d$cleanup_cost
c[is.na(c)] = 0
d$cost = p + c

# # Look at cost of cleanup
# cost = d$cost
# q = quantile(cost,probs = c(.01,.05,.1,.5,.9,.95,.99),na.rm = TRUE)
# hist(log10(cost),breaks = 25,main = "Cleanup Cost",xlab = "log10(cost) (2020 dollars)")

# Get cleaned contaminants
v = c("id","cntmnt_clnd_up","media_clnd_up")
x = wdf[!is.na(wdf$ACRES_Property_ID),]
n = unlist(pred[names(pred) %in% v])
cm = unique(x[,n])

# Add property and contaminant info
j = inner_join(d,prop_info,by = "ACRES_Property_ID")
j = inner_join(j,cntmnt_media,by = "ACRES_Property_ID")
j = inner_join(j,cm,by = "ACRES_Property_ID")
cost_cleanup = j




###############################################
# RETURN DATA IN LIST FORM FOR EASY REFERENCE #
###############################################

model_data = list(cost_phaseI = cost_phaseI,
                  req_phaseII = req_phaseII,
                  cost_phaseII = cost_phaseII,
                  req_cleanup = req_cleanup,
                  cost_cleanup = cost_cleanup)

eda_data = list(full_acres = geo_clean,
                location = loc_clean,
                grant = grant_clean,
                assess_clean = unique(wdf))

toc()