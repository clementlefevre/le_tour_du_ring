#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    trips <- eventReactive(c(input$from.lor, input$is.weekend,input$time.interval,input$fromto),{
    
    if(input$fromto==TRUE){   
      df <- df.bikeshares %>% dplyr::filter( time_interval==input$time.interval & is.weekend==input$is.weekend & from_spatial_na==input$from.lor & !is.na(total_trips_count))
      df$from_spatial_na <- str_pad(df$from_spatial_na,8,pad='0')
      df$to_spatial_na <- str_pad(df$to_spatial_na,8,pad='0')
   
      berlin.lor.district.shapefile <- sp::merge(berlin.lor.district.shapefile,df,by.x='spatial_na',by.y='to_spatial_na')
      
    }else{
      df <- df.bikeshares %>% dplyr::filter( time_interval==input$time.interval & is.weekend==input$is.weekend & to_spatial_na==input$from.lor & !is.na(total_trips_count))
      df$to_spatial_na <- str_pad(df$to_spatial_na,8,pad='0')
      df$from_spatial_na <- str_pad(df$from_spatial_na,8,pad='0')
      berlin.lor.district.shapefile <- sp::merge(berlin.lor.district.shapefile,df,by.x='spatial_na',by.y='from_spatial_na')
      
    }
        
        berlin.lor.district.shapefile
    
    } 
    )
    
   
    
    output$map <- renderLeaflet( {
        
        m <-  leaflet(trips()) %>%  setView(13.3666652,52.5166646, zoom = 11) %>%
            addProviderTiles(providers$CartoDB.DarkMatter) 
        
        m
    })
    
    observe({
      pal <- colorBin("Reds", domain = trips()$total_trips_count, bins = bins)
      
        m <-
            leafletProxy("map", data =trips()) %>%
            
           clearShapes() %>%
            addPolygons(color = "#444444", weight = .5, smoothFactor = 0.5,
                                       opacity = 1.0, fillOpacity = 0.5,
                                     fillColor = ~pal(total_trips_count),
                                     highlightOptions = highlightOptions(color = "white", weight = 1,
                                                                          bringToFront = FALSE), label = ~paste0(' number of trips to ',to_PLRNAME," ", total_trips_count) )
            m
        
    })
    
    

})
