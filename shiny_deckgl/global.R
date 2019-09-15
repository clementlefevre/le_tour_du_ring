library(dplyr)

require(rgdal)
require(geojsonio)
source('key.R')
library(stringr)
library(data.table)
library(leaflet)
library(lubridate)


# trips data
df <-read.csv('data/trips_districs_hour_weekend_aggregated.csv', stringsAsFactors = F)
df <- df %>% select(from_lng = district_from_longitude_LOR_district,from_lat=district_from_latitude_LOR_district,to_lng=district_to_longitude_LOR_district,to_lat=district_to_latitude_LOR_district,everything())

from.districts <- unique(df$district_from_OTEIL) %>% sort()
hour_filter <- unique(df$hour_of_day)


# accessibility data
sp.lor    <- readOGR(dsn="data/shapefiles/LOR/",layer="lor_planungsraeume",encoding = "DE")
df.accessible <- read.csv('data/accessible_lor_hour_weekend_aggregated.csv')

df.accessible$from_spatial_na <- str_pad(df.accessible$from_spatial_na,width=8,pad='0')

df.accessible$median_duration <- round(df.accessible$median_duration,0)


nc_geojson <- NULL


# locations rounded
#df.locations.rounded <- fread('../data/bikes_locations_rounded_test.csv')
df.locations.nearest.hour <- fread('data/bikes_nearest_hour.csv')
df.locations.nearest.hour <- df.locations.nearest.hour


