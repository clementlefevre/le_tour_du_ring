#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)



library(magrittr)
library(deckgl)
library(dplyr)
source('global.R')
source('key.R')


properties.flows <- list(
    getWidth = ~total_counts,
    pickable = TRUE,
    getSourceColor = JS("d => [Math.sqrt(d.inbound), 255,127]"),
    getTargetColor = JS("d => [255, 0, 0]"),
    getSourcePosition = ~from_lng + from_lat,
    getTargetPosition = ~to_lng + to_lat
)

properties.availability <- list(
    filled = TRUE,
    extruded = TRUE,
    stroked = FALSE,
    getElevation =  JS("data => data.properties.total_counts"),#1000*2,
    lineWidthScale = 20,
    lineWidthMinPixels = 1,
    getLineWidth = 10,
    getLineColor = c(165, 42, 42),
    elevationScale = 10,
    getFillColor = JS("data => [data.properties.median_duration,  0,0]"),
    # getFillColor = JS("data => data.properties.AREA > 0.2 ? [240, 140, 10] : [210, 80, 20]"), #c(160, 160, 180, 200),
    getTooltip = JS("object => `${object.properties.PLRNAME}<br/>Median Duration (mn): ${object.properties.median_duration}<br/>Total bikes: ${object.properties.total_counts}`")
)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$flows <- renderDeckgl({
        deckgl(zoom = 10, pitch = 35,latitude = 52.52, longitude = 13.4) %>%
            add_arc_layer(
                data = df,
                properties = properties.flows
            ) %>% add_mapbox_basemap(token=MAPBOX_API_TOKEN)
    })
    
     output$deck.availability <- renderDeckgl({
        deckgl(zoom = 10, pitch = 35,latitude = 52.52, longitude = 13.4) %>%
             add_geojson_layer(data = availability(), properties = properties.availability)  %>% add_mapbox_basemap(token=MAPBOX_API_TOKEN)
     })
    
    observeEvent(input$deck_onclick, {
        info <- input$deck_onclick
        print(names(info$object))
    })
    
    trips <- eventReactive(c(input$ortsteil,input$hour_filter, input$is.weekend,input$direction),{
        if(input$direction==TRUE){
            filtered.df <-    df %>% filter(district_from_OTEIL==input$ortsteil & hour_of_day==input$hour_filter & is.weekend==input$is.weekend)  
        } else{
            filtered.df <-    df %>% filter(district_to_OTEIL==input$ortsteil & hour_of_day==input$hour_filter & is.weekend==input$is.weekend)  
        }
        
        filtered.df
    })
    
    availability <- eventReactive(c(input$hour_filter, input$is.weekend),{
      
            filtered.df <-    df.accessible %>% dplyr::filter(hour_of_day==input$hour_filter & is.weekend==input$is.weekend)
  
            sp.merged  <- sp::merge(sp.lor,filtered.df,by.x='spatial_na',by.y='from_spatial_na',all.y=T)
            nc_geojson <- geojsonio::geojson_json(sp.merged)
            nc_geojson
    })
    
    observeEvent(c(input$maptype,input$ortsteil,input$hour_filter, input$is.weekend,input$direction), {
      if(input$maptype=='flows'){
        deckgl_proxy("flows") %>%
          add_arc_layer(
            data = trips(),
            properties = properties.flows
          ) %>%
          update_deckgl(it = "works")
      } else{
        deckgl_proxy("flows") %>%
          add_geojson_layer(data = availability(), properties = properties.availability) %>%
          update_deckgl(it = "works")
      }
      
   
    })
    
    observeEvent(c(input$hour_filter_availability, input$is.weekend.availability), {
        deckgl_proxy("deck.availability") %>%
            add_geojson_layer(data = availability(), properties = properties.availability) %>%
            update_deckgl(it = "works")
    })
    
    output$map.locations <- renderLeaflet( {
      
      m <-  leaflet(df.locations.nearest.hour) %>%  setView(13.3666652,52.5166646, zoom = 12) %>%
        addProviderTiles(providers$CartoDB.Positron) 
        
      m
      })
    
    
    pal <- colorFactor(c("navy", "red"), domain = c("accessible", "trip"))
    observe({
    
      m.start <-
        leafletProxy("map.locations", data = df.locations.nearest.hour %>% filter(hour_of_day==input$time)) %>%
        clearMarkers()       %>%
        addCircleMarkers(
          lng = ~rounded.lon, lat = ~rounded.lat, radius = ~total,stroke = FALSE, fillOpacity = 0.5,color = ~pal(mode))
      m.start
      
    })
   
})
