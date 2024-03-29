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
    getWidth = ~median_trips_count,
    pickable = TRUE,
    getSourceColor = JS("d => [Math.sqrt(d.inbound), 255,127]"),
    getTargetColor = JS("d => [255, 0, 0]"),
    getSourcePosition = ~from_lng + from_lat,
    getTargetPosition = ~to_lng + to_lat
    

    
)
# 
# properties.availability <- list(
#     filled = TRUE,
#     extruded = TRUE,
#     stroked = FALSE,
#     getElevation =  JS("data => data.properties.median_counts"),#1000*2,
#     lineWidthScale = 20,
#     lineWidthMinPixels = 10,
#     getLineWidth = 100,
#     getLineColor = c(255,255,255),
#     elevationScale = 10,
#     getFillColor = JS("data => [data.properties.median_duration,  0,0]"),
#     # getFillColor = JS("data => data.properties.AREA > 0.2 ? [240, 140, 10] : [210, 80, 20]"), #c(160, 160, 180, 200),
#     getTooltip = JS("object => `${object.properties.PLRNAME}<br/>Median Duration (mn): ${object.properties.median_duration}<br/>Median Total bikes: ${object.properties.median_counts}`")
# )

properties.availability <- list(
  filled = TRUE,
  extruded = TRUE,
  getRadius = 10,
  lineWidthScale = 2,
  lineWidthMinPixels = 2,
  getLineWidth = 1,
  getLineColor = c(100,255,255,255),
  #getFillColor =  c(128,0,0,255),
  getFillColor = JS("data => [data.properties.median_duration,0,0]"),
  getElevation =  JS("data => data.properties.median_counts_10"),
  #getTooltip = JS("object => `Median Duration (mn): ${object.properties.median_duration}<br/>Median bikes available : ${object.properties.median_counts} ${object.properties.PLRNAME}`"),
  getTooltip = JS("object => `${object.properties.name}<br/>Median bikes available : ${object.properties.median_counts}<br/>Median Availability (mn): ${object.properties.median_duration}`"),
  elevationScale = 3
)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$flows <- renderDeckgl({
        deckgl(zoom = 10, pitch = 35,latitude = 52.52, longitude = 13.4) %>%
            add_arc_layer(
                data = df,
                properties = properties.flows
            ) %>% add_mapbox_basemap(token=MAPBOX_API_TOKEN, style = "mapbox://styles/mapbox/dark-v9")
    })
    
     output$deck.availability <- renderDeckgl({
        deckgl(zoom = 10, pitch = 35,latitude = 52.52, longitude = 13.4) %>%
             add_geojson_layer(data = availability(), properties = properties.availability)  %>% add_mapbox_basemap(token=MAPBOX_API_TOKEN)
     })
    
    observeEvent(input$deck_onclick, {
        info <- input$deck_onclick
        print(names(info$object))
    })
    
    trips <- eventReactive(c(input$ortsteil.from,input$ortsteil.to,input$hour_filter, input$is.weekend,input$direction),{
    
      if(input$direction==TRUE){
          
          if(input$ortsteil.to=='ALL'){
            filtered.df <-    df %>% filter(district_from_OTEIL==input$ortsteil.from & time_interval==input$hour_filter & is.weekend==input$is.weekend)  
            
          }else{
            filtered.df <-    df %>% filter(district_from_OTEIL==input$ortsteil.from & district_to_OTEIL==input$ortsteil.to & time_interval==input$hour_filter & is.weekend==input$is.weekend)  
            
          }
        } else{
          if(input$ortsteil.to=='ALL'){
            filtered.df <-    df %>% filter(district_to_OTEIL==input$ortsteil.from  & time_interval==input$hour_filter & is.weekend==input$is.weekend)  
            
          }else{
            filtered.df <-    df %>% filter(district_to_OTEIL==input$ortsteil.from & district_from_OTEIL==input$ortsteil.to & time_interval==input$hour_filter & is.weekend==input$is.weekend)  
            
          }
        }
        
        filtered.df
    })
    
   
    
    availability <- eventReactive(c(input$hour_filter, input$is.weekend),{

            filtered.df <-    df.accessible %>% dplyr::filter(time_interval==input$hour_filter & is.weekend==input$is.weekend)

            sp.merged  <- sp::merge(sp.lor,filtered.df,by.x='spatial_na',by.y='from_spatial_na',all.y=T)
            nc_geojson <- geojsonio::geojson_json(sp.merged)
            nc_geojson
    })
    
    observeEvent(c(input$maptype,input$ortsteil.from,input$ortsteil.to,input$hour_filter, input$is.weekend,input$direction), {
  
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
        addProviderTiles(providers$CartoDB.DarkMatter)  %>%
        
        addLegend(colors = c("red", "gold"), labels = c("Bikes available", "BVG S+U/Tram")) %>%
        
        addCircleMarkers(data = df.locations.nearest.hour %>% filter(lubridate::hour(timestamp)==6),
          lng = ~rounded.lon, lat = ~rounded.lat, radius = ~total,stroke = FALSE, fillOpacity = 1,color = ~pal(mode))  %>%
        
        addCircleMarkers(data=df.bvg,
                         lng = ~lon, lat = ~lat, radius =2,stroke = TRUE, color = "black",fillOpacity = 1,fillColor = 'gold',weight = 1,label=~name) 
    
        
      m
      })
    
    
    pal <- colorFactor(c("red"), domain = c("accessible"))
    observe({
    
      m.start <-
        leafletProxy("map.locations", data = df.locations.nearest.hour %>% filter(lubridate::hour(timestamp)==input$time_input)) %>%
        clearMarkers()      %>% 
        addCircleMarkers(
          lng = ~rounded.lon, lat = ~rounded.lat, radius = ~total,stroke = FALSE, fillOpacity = 1,color = ~pal(mode))  %>%
    
        addCircleMarkers(data=df.bvg,
          lng = ~lon, lat = ~lat, radius =2,stroke = TRUE, color = "black",fillOpacity = 1,fillColor = 'gold',weight = 1,label=~name) 
      m.start
      
    })
    
    observe({
      
      time_selected <- input$time_input
      print(time_selected)
      output$time.selected <- renderText({
        paste0('Bikes available at ',str_pad(time_selected,width=2,pad='0'), 'H on 2019-07-03')
      })
    })
    
    
    output$sankey <- renderPlotly({
      # create an index :
      groupy <- df.sankey %>% filter(from_name==input$sankey.from)
      
      groupy$from_spatial_na<-paste0('start_',groupy$from_district_spatial_na,'_',groupy$from_name)
      groupy$to_spatial_na<-paste0('end_',groupy$to_district_spatial_na,'_',groupy$to_name)
      
      
      
      from <- unique(groupy$from_spatial_na)
      to <- unique(groupy$to_spatial_na)
      
      
      df.indexes <-c(from,to) %>% as.data.frame()
      df.indexes$index <- rownames(df.indexes) 
      df.indexes <- as.data.frame(df.indexes)
      colnames(df.indexes)<- c('name','index')
      df.indexes$index <- as.numeric(df.indexes$index)-1
      
      
      groupy <- merge(groupy,df.indexes,by.x='from_spatial_na',by.y='name')
      groupy <- merge(groupy,df.indexes,by.x='to_spatial_na',by.y='name')
      
      groupy <- groupy %>% arrange(total)
      
      groupy <- groupy %>% select(source=index.x,target=index.y,value=total)# %>% filter(target>0)
      
      nodes <-  df.indexes %>% select(name)
      colnames(nodes) <- c('name')
      nodes$name <- as.character(nodes$name)
      nodes <- as.data.frame(nodes)
      
      
      p <- plot_ly(
        type = "sankey",
        orientation = "h",
        
        node = list(
          label = nodes%>% pull(),
          color = 'lightcoral',
          pad = 15,
          thickness = 20,
          line = list(
            color = "black",
            width = 0.5
          )
        ),
        
        link = list(
          source = groupy %>% pull(source),
          target = groupy %>% pull(target),
          value =  groupy %>% pull(value)
        )
      ) %>% 
        layout(
          title = "Bikes destinations (total trips March 27th to July 17th)",
          font = list(
            size = 10
          ), plot_bgcolor = 'black',
          paper_bgcolor = 'black'
        )
      p
    })
    
    
  
    
    output$direction.1 <- renderText({
      if(input$direction==TRUE){
        'FROM'
      }else{
        'TO'
      }
      
    })
    
    output$direction.2 <- renderText({
      if(input$direction==TRUE){
        'TO'
      }else{
        'FROM'
      }
      
    })
   
})
