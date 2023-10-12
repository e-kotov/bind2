rm(list = ls())
# older spatial polygons package
library(sp)
# package for finding area of a polygon
library(geosphere)
# packages for getting intersection of 2 spatial polygons objects
library(rgeos)
library(raster)
# package for loading spatial data from USCB
library(tigris)

# get county spatial data
county_sp <- counties(state = "AZ", class = "sp", 2020)
# get city spatial data
place_sp <- places(state = "AZ", class = "sp", year = 2020)

# find the overlap between cities and counties since they are not
# mutually exclusive
place_county_overlap <- intersect(place_sp, county_sp)

# make a new data frame with the city county combinations and
# calculate area of overlap in km^2
city_county_df <- data.frame(
    City = place_county_overlap@data$NAME.1,
    County = place_county_overlap@data$NAMELSAD.2,
    Area = round(areaPolygon(place_county_overlap)/1000000, 2)
)

# look at city county overlap
# View(city_county_df[order(city_county_df$Area),])
