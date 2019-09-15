library(dplyr)


df <-read.csv('trips_districs_hour_weekend_aggregated.csv', stringsAsFactors = F)
df <- df %>% select(from_lng = district_from_longitude_LOR_district,from_lat=district_from_latitude_LOR_district,to_lng=district_to_longitude_LOR_district,to_lat=district_to_latitude_LOR_district,everything())
df <- df%>% arrange
from.districts <- unique(df$district_from_OTEIL) %>% sort()
hour_filter <- unique(df$hour_of_day)