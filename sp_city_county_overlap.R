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
library(dplyr)
library(sf)
library(ggplot2)
library(maptiles) # tiles for adding context to plots
library(tidyterra) # easy plotting of map tiles

# get county spatial data
county_sp <- counties(state = "AZ", class = "sp", year = 2020)
county_sp@data$COUNTY <- county_sp@data$NAME
county_sp@data$NAME <- NULL
# get city spatial data
place_sp <- places(state = "AZ", class = "sp", year = 2020)


# find the overlap between cities and counties since they are not
# mutually exclusive
place_county_overlap <- rgeos::intersect(place_sp, county_sp)

# make a new data frame with the city county combinations and
# calculate area of overlap in km^2
city_county_df <- data.frame(
    City = place_county_overlap@data$NAME,
    County = place_county_overlap@data$COUNTY,
    Area = round(areaPolygon(place_county_overlap)/1000000, 2)) %>%
    group_by(City, County) %>%
    summarise(Area = sum(Area), .groups = "drop_last") %>%
    filter(Area > .001) %>%
    mutate(N = n()) %>%
    ungroup()

# pull mcnary city lines
mcnary <- places(state = "AZ", class = "sf", year = 2020) %>%
    filter(NAME == "McNary")

# get the open street map tiles
dc <- mcnary %>%
    get_tiles(
        provider = "OpenStreetMap",
        zoom = 13, crop = T)

# plot city against county lines
mcnary_plot <- mcnary %>%
    ggplot() +
    geom_spatraster_rgb(data = dc) +
    geom_sf(alpha = .1, linewidth = 2) +
    theme_void(base_size = 14) +
    ggtitle("City of McNary", "Apache and Navajo Counties")

mcnary_plot

ggsave("./mcnary_map.png", mcnary_plot)
