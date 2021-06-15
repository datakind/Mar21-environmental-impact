

tic("General data cleanup")

# Common Functions -------------------------------------------------------


move_digits_to_back <- function(x) {
    if (grepl("^[0-9]{4}", x)) {
        split_var <- strsplit(x, split = "_")[[1]]
        paste(c(split_var[2:length(split_var)], split_var[1]), collapse = "_")
    } else x
}


format_cols <- function(x) {
    
    make_title_case <- function(x) {
        ifelse(x == toupper(x), str_to_title(x), x)
    }
    
    x <- x %>% 
        make_title_case() %>% 
        str_replace_all('\\%', 'Pct') %>% 
        str_replace_all('\\#', 'Num') %>% 
        str_replace_all(':', '') %>% 
        str_replace_all('-', '_') %>% 
        str_replace_all('[[ ]]+', '_') %>% 
        str_replace_all('[()]', '') %>% 
        str_replace_all('\\?', '') %>% 
        str_replace_all('/', '_')
    x
}


clean_city_property <- function(x) {
    gsub("[0-9]{5}", "", x) %>%
        gsub("[[:space:]]+$", "", .) %>%
        gsub("[[:punct:]]$", "", .) %>%
        gsub(",[A-Z]{2}$", "", .) %>%
        toupper
}


count_cntmtn_fnd <- function(x) {
    x %>% 
        select(contains('Cntmnt_Fnd')) %>% 
        mutate(across(contains('Cntmnt_Fnd'), ~ ifelse(.x == 'Y', 1, 0))) %>% 
        rowSums(na.rm = TRUE)
}


factor_to_tf = function(x) {
  # Making this 1/0 to take max when combining contaminants later
  y = as.character(x)
  y[y=='Y'] = 1
  y[y=='N'] = 0
  y[y=='U'] = NA
  y = as.numeric(y)
  return(y)
}




# Geo Data Cleaning -------------------------------------------------------


# Loading Data
geo_data_raw <- read_csv('data/brownfields_data_with_county_geoid.zip')

# Remove All Missing and Unnecessary Columns
geo_data <- geo_data_raw %>% 
    select(where(~!all(is.na(.x)))) %>% 
    select(-`Future Use: Multistory (arces)`)

# Rename and Format Columns
geo_data <- geo_data %>% rename_all(format_cols) %>% rename(GEOID = Geoid)
colnames(geo_data) <- sapply(colnames(geo_data), move_digits_to_back)



# Apply Cleaning to individual values
geo_clean <- geo_data %>% 
    mutate(across(contains('Date') & contains('-'), as.Date, format = '%Y-%d-%m')) %>% # I don't think this does what I think it does - is it really checking for a hyphen?
    mutate_at(vars(Date_ICs_in_Place, Redev_Completion_Date), as.Date, format = '%m/%d/%y') %>% # A few dates are not in the standard format
    mutate_if(~ length(unique(levels(as.factor(.x)))) < 100, as.factor) %>% # Convert shorter character values to factors
    mutate_if(is.factor, ~ .x %>% fct_recode(Y = 'x', Y = 'y',N = 'n', U = 'u')) %>% # Recode those factors that don't match. 
    mutate(Property_City_clean = clean_city_property(Property_City)) %>%
    mutate_at(vars(GEOID), as.numeric) %>% 
    mutate(Num_Cntmnt_Fnd = count_cntmtn_fnd(.))


# Turn logical into T/F
c = colnames(geo_clean)[setdiff(grep("Cntmnt",colnames(geo_clean)),grep("Descr",colnames(geo_clean)))]
m = colnames(geo_clean)[grep("Media_",colnames(geo_clean))]
i = c("Institutional_Ctrl_ICs_Req","IC_Catgry_Proprietary_Ctrls","IC_Catgry_Informational_Dev",
      "IC_Catgry_Govmntal_Ctrls","IC_Catgry_Enfrcmnt_Prmt_Tools","ICs_in_Place")
v = c("Accomplishment_Counted","Did_Ownership_Change","SFLLP_fact_into_the_ownership",
      "Cleanup_Required",c,m,i,"Ready_For_Reuse_Ind")
geo_clean = geo_clean %>%
    mutate_at(v,factor_to_tf)

# Remove unnecessary columns
v = c("Accomplishment_Counted","Radius","Num_of_Cleanup_and_Redev_Jobs",
      "Horizontal_Collection_Method","Source_Map_Scale",
      "Reference_Point","Horizontal_Reference_Datum",
      "Photographs_are_available","Video_is_available","Other_Media_Ind")
geo_clean = geo_clean[,!(colnames(geo_clean) %in% v)]

# Add cleanup year
geo_clean$Cleanup_Year = format(geo_clean$Cleanup_Start_Date,"%Y")





# CPI Monetary Adjustment -------------------------------------------------

wdf = geo_clean

# Pull in data
monthly_cpi = read.csv("data/CPIAUCSL.csv")
monthly_cpi$year = format(as.Date(monthly_cpi$DATE,format="%d/%m/%Y"),"%Y")

# Average by year
annual_cpi = aggregate(monthly_cpi$CPIAUCSL,by = list(year = monthly_cpi$year),FUN = mean)

# Normalize to most recent full year
n = count(monthly_cpi,year)
n = n[n$n == 12,]
y = max(n$year)
v = annual_cpi$x[annual_cpi$year == y]
annual_cpi$x = annual_cpi$x/v

# Adjust Assessment funding
y = "Assessment"
v = "Amt_of_Assessment_Funding"
cpi = annual_cpi
colnames(cpi) = paste0(y,"_",c("Year","CPI"))
wdf = left_join(wdf,cpi,by = paste0(y,"_Year"))
wdf[[paste0("Adj_",v)]] = wdf[[v]]/wdf[[paste0(y,"_CPI")]]

# Adjust Cleanup funding
y = "Cleanup"
v = "Amount_of_Cleanup_Funding"
cpi = annual_cpi
colnames(cpi) = paste0(y,"_",c("Year","CPI"))
wdf = left_join(wdf,cpi,by = paste0(y,"_Year"))
n = wdf[[v]]
d = wdf[[paste0(y,"_CPI")]]
a = n/d
wdf[[paste0("Adj_",v)]] = a

geo_clean = wdf


# ACS Data Cleaning -------------------------------------------------------


acs_data_raw <- readxl::read_xlsx('data/national_acs5-2018_census.xlsx')

# Ensure joining between ACS and GEO
acs_data <- acs_data_raw %>% 
    mutate_at(vars(GEOID), ~ .x %>% as.numeric())


toc()