library(rgdal)
library(leaflet)
library(stringr)
library(sp)



## load berlin lor shapefile wiht polygons :
berlin.lor.district.shapefile <- readOGR("data/shapefiles/LOR_Ortsteile/lor_ortsteile.shp",
                  layer = "lor_ortsteile", GDAL1_integer64_policy = TRUE)


## load aggregated bikeshare data  per district :
df.bikeshares <- read.csv('data/accessible_districts_hour_weekend_aggregated.csv')
df.bikeshares <- df.bikeshares %>% filter(hour_of_day==12 & is.weekend==FALSE)

## add leading zero to the spatial_na of the dataframe (because the shapefiles ID are string and not numeric):
df.bikeshares$from_district_spatial_na <- str_pad(df.bikeshares$from_district_spatial_na,4,pad='0')

## merge shapefile and dataframe :

berlin.lor.district.shapefile <- sp::merge(berlin.lor.district.shapefile,df.bikeshares,by.x='spatial_na',by.y='from_district_spatial_na')

leaflet(berlin.lor.district.shapefile) %>%   addProviderTiles(providers$CartoDB) %>%
  addPolygons(color = "#444444", weight = .5, smoothFactor = 0.5,
              opacity = 1.0, fillOpacity = 0.5,
              fillColor = ~colorQuantile("YlOrRd", median_duration)(median_duration),
              highlightOptions = highlightOptions(color = "white", weight = 1,
                                                  bringToFront = FALSE), label = ~OTEIL )
