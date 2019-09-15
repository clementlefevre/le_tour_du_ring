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





properties <- list(
    getWidth = ~total_counts,
    pickable = TRUE,
    getSourceColor = JS("d => [Math.sqrt(d.inbound), 255,127]"),
    getTargetColor = JS("d => [255, 0, 0]"),
    getSourcePosition = ~from_lng + from_lat,
    getTargetPosition = ~to_lng + to_lat
)



# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$deck <- renderDeckgl({
        deckgl(zoom = 10, pitch = 35,latitude = 52.52, longitude = 13.4) %>%
            add_arc_layer(
                data = df,
                properties = properties
            ) %>% add_mapbox_basemap(token=MAPBOX_API_TOKEN)
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
    
    observeEvent(c(input$ortsteil,input$hour_filter, input$is.weekend,input$direction), {
        deckgl_proxy("deck") %>%
            add_arc_layer(
                data = trips(),
                properties = properties
            ) %>%
            update_deckgl(it = "works")
    })

})
