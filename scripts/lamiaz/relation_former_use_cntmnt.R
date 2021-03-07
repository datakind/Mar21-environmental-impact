library(tidyverse)
library(gridExtra)



# Common Functions
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


# Geo Data Cleaning -------------------------------------------------------


# Loading Data
geo_data_raw = read_csv('data/brownfields_data_with_county_geoid.zip')

# Remove All Missing and Unnecessary Columns
geo_data <- geo_data_raw %>% 
    select(where(~!all(is.na(.x)))) %>% 
    select(-`Future Use: Multistory (arces)`)

# Rename and Format Columns
geo_data <- geo_data %>% rename_all(format_cols) %>% rename(GEOID = Geoid)
colnames(geo_data) <- sapply(colnames(geo_data), move_digits_to_back)



# Apply Cleaning to individual values
## I modified a few things in the cleanup: further cleaned dates, converted Y/N to 0/1 numeric (not factors)
geo_clean = geo_data %>% 
    ## Cleaning date format before conversion: change dates in format of 03/20/0020 to 03/20/20
    mutate(across(matches('Date|Enrollment|Further'), function(x) str_remove_all(x,"(?<=/)00(?=\\d{2})"))) %>%
    ## Redev Completion Date, Date ICs in Place are in format %m/%d/%y
    mutate(across(matches('Redev[ _\\-]Completion[ _\\-]Date|Date[ _\\-]ICs[ _\\-]in[ _\\-]Place'), as.Date, format = '%m/%d/%y')) %>% 
    ## Assessment Start Date, Assessment Completion Date, Cleanup Start Date, Cleanup Completion Date, Redevelopment Start Date are in format %Y-%m-%d
    mutate(across(matches('(Assessment|Cleanup).*Date|Redevelopment[ _\\-]Start[ _\\-]Date'), as.Date, format = '%Y-%m-%d')) %>% 
    mutate(Property_City_clean = clean_city_property(Property_City)) %>%
    mutate_at(vars(GEOID), as.numeric) %>% 
    ## Recode x to Y
    mutate(across(matches("^(Cntmnt|Media)_(?!.*Desc)",perl = T), function(a) ifelse(is.na(a),NA,as.numeric(a %in% c("x","Y"))))) %>%
    rowwise() %>%
    mutate(Num_Cntmnt_Fnd = sum(c_across(matches("Cntmnt_Fnd(?!.*Desc)",perl = T)),na.rm = T)) %>%
    ungroup()


## Add text features

geo_clean = geo_clean %>% mutate(use_commercial_building = as.numeric(str_detect(Description_History,"(?i)commercial[a-z/\\-]*\\s*(?:site\\s+)?building")),
									use_repair_facility = as.numeric(str_detect(Description_History,"(?i)repair[a-z/\\-]*\\s*(?:site\\s+)?facility")),
									use_storage_facility_or_warehouse = as.numeric(str_detect(Description_History,"(?i)storage[a-z/\\-]*\\s*(?:site\\s+)?(?:facility|yard)|ware[\\s+-]house")),
									use_manufacture = as.numeric(str_detect(Description_History,"(?i)manufactur")),	
									use_residential = as.numeric(str_detect(Description_History,"(?i)residential")),	
									use_store = as.numeric(str_detect(Description_History,"(?i)\\bstore|shop|\\bretail")),	
									use_parking = as.numeric(str_detect(Description_History,"(?i)parking")),	
									use_school = as.numeric(str_detect(Description_History,"(?i)school")),
									use_industrial = as.numeric(str_detect(Description_History,"(?i)industr(?:ial|y)")),
									use_rail = as.numeric(str_detect(Description_History,"(?i)\\brail|\\btrains?\\b")),
									use_vacant = as.numeric(str_detect(Description_History,"(?i)\\bvacant\\b")),
									use_farm_land = as.numeric(str_detect(Description_History,"(?i)(?:farm|agricultural)[a-z/\\-]*\\s*lands?\\b")),
									use_forest = as.numeric(str_detect(Description_History,"(?i)forest|\\btimber\\b|\\bwood")),
									use_wet_land = as.numeric(str_detect(Description_History,"(?i)\\bwet\\s+land|\\bswamp")),
									use_junk_yard = as.numeric(str_detect(Description_History,"(?i)(?:junk|scrap|salvage)[a-z/\\-]*\\s*yard")),
                                    use_undeveloped = str_detect(Description_History,"(?i)undeveloped")
									)
	

geo_clean = geo_clean %>% mutate(nchar_history = nchar(Description_History),
									nb_dates_history = str_count(Description_History,"(19|20)\\d{2}|\\b\\d0.s")
									)

## Relation between historical use and contaminants found

use_cntmnt = geo_clean %>% select(ACRES_Property_ID,matches("Cntmnt_Fnd|^use")) %>% distinct()
			#%>% mutate(Cntmnt_Fnd_Not_Other = pmax(c_across(matches("Cntmnt_Fnd_(?!)")),na.rm = T))

use_cntmnt_long = use_cntmnt %>% filter(use_rail == 1) %>% pivot_longer(matches("^Cntmnt_Fnd(?!.*Desc)",perl = T),names_to="Cntmnt_Fnd",values_to="Fnd") %>% filter(!is.na(Fnd),Fnd == 1)
use_cntmnt_long = use_cntmnt_long %>% pivot_longer(matches("^use"),names_to="Use",values_to="value") %>% filter(!is.na(value),value == 1) %>% select(-value) %>% mutate(Cntmnt_Fnd = str_remove(Cntmnt_Fnd,"Cntmnt_Fnd_"),Use = str_remove(Use,"use_"))


g_abs = use_cntmnt_long %>% ggplot() +
 geom_bar(aes(x = Use, fill = Ctmnt_Fnd),position = "stack") +
 theme(axis.text.x = element_text(angle = 45, hjust = 1))

g_prop = use_cntmnt_long %>% ggplot() +
 geom_bar(aes(x = Use, fill = Ctmnt_Fnd),position = "fill") +
 theme(axis.text.x = element_text(angle = 45, hjust = 1))

grid.arrange(g_abs,g_prop,ncol = 2)
g = arrangeGrob(g_abs,g_prop,ncol = 2)
ggsave("scripts/lamiaz/Cntmnt_Fnd_in properties_former_use.png",g)
