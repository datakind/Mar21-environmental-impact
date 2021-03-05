# Rename one column to ensure consistent naming
brownfields <- rename(brownfields, `Redevelopment Completion Date` = `Redev Completion Date`)

fix_dates <- function(df, method) {
  # Standardize date formats
  # Choose "base" or "dplyr" for method
  if(!(method %in% c("base", "dplyr"))) stop("method must be base or dplyr")
  
  if(method == "base") {
    # Base R Date standardization
    cols <- grep("Date", names(df), value=T)
    df[cols] <- data.frame(lapply(df[cols], function(x) as.POSIXct(x, format = "%m/%d/%y")))
  }
  
  if(method == "dplyr") {
    # dplyr Date standardization
    df <- df %>%
      mutate_at(vars(contains("Date")), list(~ as.POSIXlt(., format = "%m/%d/%y")))
  }
  return(df)
}

label_bad_dates <- function(df, method) {
  # Create a label for rows with potentially bad dates
  # Choose "base" or "dplyr" for method
  if(!(method %in% c("base", "dplyr"))) stop("method must be base or dplyr")
  
  if(method == "base") {
    # Base R bad date labeling
    df$bad_date_flag <- ifelse(
      (df$`Assessment Start Date` > df$`Assessment Completion Date`) |
        (df$`Cleanup Start Date` > df$`Cleanup Completion Date`) |
        (df$`Redevelopment Start Date` > df$`Redevelopment Completion Date`),
      1,
      0)
    }
  
  if(method == "dplyr") {
    # dplyr bad date labeling
    df <- df %>%
      mutate(bad_date_flag = case_when(
        (`Assessment Start Date` > `Assessment Completion Date`) |
          (`Cleanup Start Date` > `Cleanup Completion Date`) |
          (`Redevelopment Start Date` > `Redevelopment Completion Date`) ~ 1,
        TRUE ~ 0))
    }
  return(df)
}
