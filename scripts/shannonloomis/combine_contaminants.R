

tic("Contaminants parsed and combined")

# Put working dataset into its own variable so it doesn't get messed up with testing
wdf = geo_clean



#############
# FUNCTIONS #
#############

combine_contaminant_df = function(cc,x) {
  
  ### INPUTS ###
  # cc = contaminant category df read in from CSV
  # x = dataframe with parsed columns of interested (e.g. found, cleaned up)
  
  cs = split(cc$detail,cc$category)
  l = lapply(cs, function(d) {
    c = which(colnames(x) %in% d)
    if (length(c) > 0) {
      y = x[,c]
      if (length(c) == 1) {
        z = y
      } else {
        z = apply(y,1,function(a){
          b = suppressWarnings(max(a,na.rm = T))
          b
        })
        z[is.infinite(z)] = NA
      }
    } else {
      z = NULL
    }
    return(z)
  })
  ll = l[which(unlist(lapply(l, function(x) {length(x)>0})))]
  df = as.data.frame(ll)
  
  return(df) 
  
  ### OUTPUT ###
  # df = dataframe (combined contaminant groups as columns)
}


sub_contaminant_main_df = function(wdf,p) {
  
  ### INPUTS ###
  # wdf = working dataframe
  # p = string with prefix looking to combine
  
  ind = setdiff(grep(p,colnames(wdf)),grep("Descr",colnames(wdf)))
  x = wdf[,ind]
  colnames(x) = colnames(x) %>%
    gsub(p,"",.) %>%
    gsub("_"," ",.)
  
  # Combine like contaminants
  df = combine_contaminant_df(cc,x)
  colnames(df) = paste0(p,colnames(df))
  
  # Strip out old contaminant columns and insert new ones
  D = wdf
  D = D[,-ind]
  D = cbind(D,df)
  
  ### OUTPUT ###
  # D = dataframe (old contaminant description fields removed, higher level categories inserted)
  
  return(D)
}


# Read in contaminant categories
cc = read.csv(paste0(sd,"contaminant_categories.csv"))
colnames(cc) = c("detail","category")




#########################################
# PROCESS OTHER CONTAMINANT DESCRIPTION #
#########################################


### SPLIT INTO INDIVIDUAL DESCRIPTIONS ###

# Get sites with description
d = wdf[,c("ACRES_Property_ID","Cntmnt_Fnd_Other_Descr")]
d = d[!is.na(d$Cntmnt_Fnd_Other_Descr),]

d$Cntmnt_Fnd_Other_Descr = d$Cntmnt_Fnd_Other_Descr %>%
  toupper %>%
  # Get rid of digits
  gsub("[[:digit:]]","",.) %>%
  gsub("-"," ",.) %>% 
  # Turn other split words into commas
  gsub(" AND ",", ",.) %>%
  gsub("&",", ",.) %>%
  gsub(";",", ",.) %>%
  gsub("\\*",", ",.) %>%
  gsub("\\.",", ",.) %>%
  gsub("\\'",", ",.) %>%
  gsub('\\"',", ",.) %>%
  gsub('\\/',", ",.)

# Split multiple contaminants into 
dl = strsplit(d$Cntmnt_Fnd_Other_Descr,",")
dl = lapply(dl,function(x) {
  y = trimws(x)
  y = y[y!='Y']
  y = y[y!='N']
  y = y[y!='']
  y = y[y!='NOT SPECIFIED']
  y = y[y!='ETC']
  return(y)
})

# Turn into dataframe
ds = mapply(function(d,n) {
  if (length(d) > 0) {
    data.frame(id = n, contaminant = d)
  } else {
    NULL
  }
}, d = dl, n = as.list(d$ACRES_Property_ID),SIMPLIFY = FALSE)
df = do.call("rbind",ds)



### ADD CATEGORY TO DESCRIPTION ###

# Join description to category table
cj = cc
cj$detail = toupper(cj$detail)
dc = left_join(df,cj,by = c("contaminant" = "detail"))

# Pull out asbsetos
ind = c(grep("asbestos",dc$contaminant,ignore.case = T))
ind = intersect(which(is.na(dc$category)),unique(ind))
dc$category[ind] = 'Asbestos'

# Pull out lead
ind = c(grep("lead",dc$contaminant,ignore.case = T),
        grep("galena",dc$contaminant,ignore.case = T))
ind = intersect(which(is.na(dc$category)),unique(ind))
dc$category[ind] = 'Metal'

# Pull out solid waste/fill - note this includes landfill gasses and tires
ind = c(grep("fill",dc$contaminant,ignore.case = T),
        grep("solid waste",dc$contaminant,ignore.case = T),
        grep("tire",dc$contaminant,ignore.case = T))
ind = intersect(which(is.na(dc$category)),unique(ind))
dc$category[ind] = 'Landfill'

# Pull out petroleum
o = grep("OIL",dc$contaminant)
s = grep("SOIL",dc$contaminant)
ind = c(setdiff(o,s), #oil but not soil (includes linseed and cooking oil...will fix later...maybe)
        grep("diesel",dc$contaminant,ignore.case = T),
        grep("petroleum",dc$contaminant,ignore.case = T),
        grep("UST",dc$contaminant,ignore.case = T))
ind = intersect(which(is.na(dc$category)),unique(ind))
dc$category[ind] = 'Petroleum'


# 
# # Stats on other contaminants
# # x = count(d,Cntmnt_Fnd_Other_Descr)
# x = dc[is.na(dc$category),]
# x = count(x,contaminant,category)
# #write.xlsx(x,paste0(sd,"other_contaminants.xlsx"))



### TRANSFORM DESCRIPTION INTO BOOLEAN FIELDS ###

# Isolate only those with category
df = dc[!is.na(dc$category),]
cntmnt_desc_id = split(df$id,df$category)







######################################################
# COMBINE FOUND AND CLEANED CONTAMINANTS INTO GROUPS #
######################################################

# Contaminants cleaned up
p = "Cntmnt_Clnd_Up_"
wdf = sub_contaminant_main_df(wdf,p)


# Contaminants found
p = "Cntmnt_Fnd_"
wdf = sub_contaminant_main_df(wdf,p)


# Add other description boolean to df
for (n in names(cntmnt_desc_id)) {
  
  cn = paste0("Cntmnt_Fnd_",n) # Column name
  if (!(cn %in% colnames(wdf))) {wdf[[cn]] = NA} # Make column if missing
  
  # Turn those values into 1
  ind = wdf$ACRES_Property_ID %in% cntmnt_desc_id[[n]]
  wdf[[cn]][ind] = 1
}





# Rename output to geo_clean for easier working
geo_clean = wdf

toc()