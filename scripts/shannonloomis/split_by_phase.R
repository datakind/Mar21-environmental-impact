




###################
# ASSESSMENT DATA #
###################

# Split by phase
d = geo_clean[!is.na(geo_clean$Assessment_Phase),]
p = unique(d$Assessment_Phase)
d = split(d,d$Assessment_Phase)



### PHASE I ###

phaseI = d$`Phase I Environmental Assessment`
v = c("Amt_of_Assessment_Funding","ACRES_Property_ID",
      "Property_City","Property_State","Property_Zip_Code",
      "Did_Ownership_Change","SFLLP_fact_into_the_ownership","Description_History",
      "Property_Size","Past_Use_Greenspace_arces","Past_Use_Residential_arces",
      "Past_Use_Commercial_arces","Past_Use_Industrial_arces",
      "Assessment_Start_Date","Assessment_Completion_Date",      "Cleanup_Required"              
      [37] "Cntmnt_Fnd_Arsenic"             "Cntmnt_Fnd_Asbestos"            "Cntmnt_Fnd_Chromium"           
      [40] "Cntmnt_Fnd_Lead"                "Cntmnt_Fnd_Mercury"             "Cntmnt_Fnd_Nickel"             
      [43] "Cntmnt_Fnd_None"                "Cntmnt_Fnd_Other"               "Cntmnt_Fnd_Other_Metals"       
      [46] "Cntmnt_Fnd_PAHs"                "Cntmnt_Fnd_PCBs"                "Cntmnt_Fnd_Petroleum"          
      [49] "Cntmnt_Fnd_Selenium"            "Cntmnt_Fnd_SVOCs"               "Cntmnt_Fnd_Unknown"            
      [52] "Cntmnt_Fnd_VOCs"                "Cntmnt_Clnd_Up_Asbestos"        "Cntmnt_Clnd_Up_Lead"           
      [55] "Cntmnt_Clnd_Up_Mercury"         "Cntmnt_Clnd_Up_Other_Metals"    "Cntmnt_Clnd_Up_PAHs"           
      [58] "Cntmnt_Clnd_Up_Petroleum"       "Cntmnt_Clnd_Up_VOCs"            "Cntmnt_Fnd_Other_Descr"        
      [61] "Media_Affected_Unknown"         "Media_Clnd_Up_Sediments"        "Media_Clnd_Up_Soil"            
      [64] "Media_Clnd_Up_Ground_Water"     "Media_Clnd_Up_Indoor_Air"       "Media_Affected_Sediments"      
      [67] "Media_Affected_Bldg_Materials"  "Media_Affected_Soil"            "Media_Affected_Surface_Water"  
      [70] "Media_Clnd_Up_Bldg_Materials"   "Media_Clnd_Up_Air"              "Media_Affected_Drnking_Water"  
      [73] "Media_Affected_Ground_Water"    "Media_Affected_Indoor_Air"      "Media_Affected_Air"            
      [76] "Institutional_Ctrl_ICs_Req"     "IC_Catgry_Proprietary_Ctrls"    "IC_Catgry_Informational_Dev"   
      [79] "IC_Catgry_Govmntal_Ctrls"       "IC_Catgry_Enfrcmnt_Prmt_Tools"  "ICs_in_Place"                  
      [82] "Date_ICs_in_Place"              "Cleanup_Start_Date"             "Cleanup_Completion_Date"       
      [85] "ACRES_Cleaned_Up"               "Source_of_Cleanup_Funding"      "Entity_Prvding_Cleanup_Funds"  
      [88] "Amount_of_Cleanup_Funding"      "Redevelopment_Start_Date"       "Future_Use_Greenspace"         
      [91] "Future_Use_Residential"         "Future_Use_Commercial"          "Future_Use_Industrial"         
      [94] "Acreage_and_Greenspace_Created" "Src_of_Redev_Funding"           "Entity_Prvding_Redev_Funds"    
      [97] "Amount_of_Redev_Funding"        "Num_of_Cleanup_and_Redev_Jobs"  "Photographs_are_available"     
      [100] "Video_is_available"             "Num_Below_Poverty_2010"         "Pct_Below_Poverty_2010"        
      [103] "Median_Income_2010"             "Num_Low_Income_2010"            "Pct_Low_Income_2010"           
      [106] "Num_Vacant_Housing_2010"        "Pct_Vacant_Housing_2010"        "Num_Unemployed_2010"           
      [109] "Pct_Unemployed_2010"            "Other_Media_Ind"                "Type_of_Funding"               
      [112] "Ready_For_Reuse_Ind"            "Enrollment_ST_Tribal_Prg"       "ST_Tribal_Prg_ID_Number"       
      [115] "Further_Action_Cleanup"         "Radius"                         "EPA_Region"                    
      [118] "Grant_ID"                       "Highlights"                     "Program_Code"                  
      [121] "Assessment_Year"                "Row_Count"                      "GEOID"                         
      [124] "County_Name"                    "Property_City_clean"            "Num_Cntmtn_Fnd" )