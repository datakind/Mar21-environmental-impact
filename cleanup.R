library(tidyverse)

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

geo_data <- read_csv('data/brownfields_data_with_county_geoid.zip')
geo_data_new <- geo_data %>% select(where(~!all(is.na(.x))))
clean_columns <- geo_data_new %>% rename_all(format_cols)
colnames(clean_columns) <- sapply(colnames(clean_columns), move_digits_to_back)


cleaning <- clean_columns[, 81:length(colnames(clean_columns))] %>% 
    mutate(across(contains('Date') & contains('-'), as.Date, format = '%Y-%d-%m')) %>% 
    mutate_at(vars(Date_ICs_in_Place), as.Date, format = '%m/%d/%y') %>% # A few dates are not in the standard format
    mutate_if(~ length(unique(levels(as.factor(.x)))) < 100, as.factor) %>% # Convert shorter character values to factors
    mutate_if(is.factor, ~ .x %>% fct_recode(Y = 'y',N = 'n', U = 'u')) # Recode those factors that don't match. 
    





