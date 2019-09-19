library(rgdal)
library(leaflet)
library(stringr)
library(sp)
library(dplyr)


## load berlin lor shapefile wiht polygons :
berlin.lor.district.shapefile <- readOGR("data/shapefiles/lor_planungsraeume.shp",
                                         layer = "lor_planungsraeume", GDAL1_integer64_policy = TRUE)

## load aggregated bikeshare data  per district :
df.bikeshares <- read.csv('data/trips_lor_hour_weekend_aggregated.csv',stringsAsFactors = FALSE,sep=';')
df.bikeshares <- df.bikeshares %>% dplyr::filter(!is.na(total_trips_count) )
df.bikeshares$is.weekend <- as.logical(df.bikeshares$is.weekend)



bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)


lor.selection <- split(df.bikeshares$from_spatial_na, df.bikeshares$from_PLRNAME)
interval.selection <- unique(df.bikeshares$time_interval)

## merge shapefile and dataframe :


# 
# leaflet(berlin.lor.district.shapefile) %>%   addProviderTiles(providers$CartoDB) %>%
#   addPolygons(color = "#444444", weight = .5, smoothFactor = 0.5,
#               opacity = 1.0, fillOpacity = 0.5,
#               fillColor = ~pal(total_trips_count),
#               highlightOptions = highlightOptions(color = "white", weight = 1,
#                                                   bringToFront = FALSE), label = ~to_PLRNAME )
