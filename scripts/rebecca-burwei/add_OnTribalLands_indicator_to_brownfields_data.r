# This script takes the brownfields data and adds a new column called 
# `On Tribal Lands` indicating whether or not a property was found to 
# be on tribal lands.

# Limitations of this methodology and script warnings:
# 1. A property is represented entirely by a single
#    (longitude, latitude) point. It's possible that the property
#    overlaps with tribal lands, but the single point representing the 
#    property does not -- In this case, this script erroneously says that 
#    property is not on tribal lands.
# 2. Tribal lands are defined as the union of the following areas:
#    * 2019 Tribal Census Tracts
#    * 2019 Alaska Native Regional Corporations
#    * 2019 American Indian/Alaska Native/Native Hawaiian Areas National
# 3. Running this script for the first time involves downloading ~10 MB
#    worth of shapefiles.
# 4. The last section of the script `GENERATE CSV WITH TRIBAL INDICATOR`
#    may take a very long time to run.

library(sp)
library(tigris)
# setwd("<path-to-repo>/scripts/rebecca-burwei")

######## FUNCTIONS AND OBJECTS #############################

# Downloads spatial polygons for tribal lands from Census,
# or loads them from cache if previously downloaded.
options(tigris_use_cache = TRUE)
tribal <- tribal_census_tracts()
tribal <- c(
  as(alaska_native_regional_corporations(), "Spatial"),
  as(native_areas(), "Spatial"),
  as(tribal_census_tracts(), "Spatial")
)

is_tribal <- function(longitude, latitude){
  # Arguments: Must provide longitude, latitude in decimal degrees format.
  # Returns: True if the (long, lat) point is on tribal lands,
  #          False if it's not,
  #          NA if inputs are invalid.
  
  # Return NA if either input is NA.
  if(is.na(longitude) | is.na(latitude)){
    return(NA)
  }
  
  # Convert longitude, latitude into standard format
  coords <- cbind(longitude, latitude)
  spdf <- SpatialPointsDataFrame(coords, data.frame(ID=1:1))

  # Check if the point is in any of the tribal polygons
  for(polygons in tribal){
    proj4string(spdf) <- proj4string(polygons)
    result <- over(spdf, polygons)
    if(sum(!is.na(result)) > 0){
      # If `result` contains any non-NAs, then a match was found,
      # and the point is on tribal lands
      return(TRUE)
    }
  }
  return(FALSE)
}

######## UNIT TESTS ##########################################

# Check that O'Hare airport is not on tribal lands
if(is_tribal(-87.836723, 41.977226) == TRUE){
  stop("Unit test failed for `is_tribal` function.")
}

# Check that the Navajo Nation Welcome Center is on tribal lands
if(is_tribal(-109.18735977257617, 36.06740957280979) == FALSE){
  stop("Unit test failed for `is_tribal` function.")
}

######## GENERATE CSV WITH TRIBAL INDICATOR ###################
######## This section is slow to run.

# Run is_tribal function on brownfields data
dat <- read.csv("../../data/brownfields_data_with_county_geoid/brownfields_data_with_county_geoid.csv")
dat["Property.Longitude"] <- as.numeric(as.character(dat$Property.Longitude))
dat["Property.Latitude"] <- as.numeric(as.character(dat$Property.Latitude))
dat["On.Tribal.Lands"] = apply(
  dat[, c("Property.Longitude","Property.Latitude")], 1, function(x) is_tribal(x[1],x[2])
  )
print(summary(dat$On.Tribal.Lands))

# Write new CSV with On.Tribal.Lands field
write.csv(dat,
  "../../data/_volunteer_created_datasets/brownfields_data_with_on_tribal_lands.csv"
)

#9:10