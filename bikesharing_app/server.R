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
library(dplyr)

source('global.R')


bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal.start <- colorBin("YlOrRd", domain = df.bvg.start$total_date, bins = bins)
pal.end <-  colorBin("BuPu", domain = df.bvg.start$total_date, bins = bins)




# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    points.bvg.start <- reactive({
        df.bvg.start %>%
            filter(request_time_rounded == input$time)
    })
    
    points.bvg.end <- reactive({
        df.bvg.end %>%
            filter(request_time_rounded == input$time)
    })
    
    output$map.bvg.start <- renderLeaflet({
        map.bvg.start <-
            leaflet(df.bvg.start) %>% addProviderTiles(providers$CartoDB.DarkMatter)
        setView(map.bvg.start, 13.4171173, 52.5166482, 10)
    })
    
    output$map.bvg.end <- renderLeaflet({
        map.bvg.end <-
            leaflet(df.bvg.end) %>% addProviderTiles(providers$CartoDB.DarkMatter)
        setView(map.bvg.end, 13.4171173, 52.5166482, 10)
    })
    
    
    
    bike.timeline <- eventReactive(input$bikeId,{
        
        filtered.df <-      transpose.datetime(input$bikeId)
        browser()
        filtered.df
    })
    
    output$map.bikes <- renderLeaflet({
        leaflet(bike.timeline()) %>% addProviderTiles(providers$Stamen.Toner) %>%
            addCircleMarkers(
                stroke = FALSE, fillOpacity = 1
            )
    })
    
    observe({
        m.start <-
            leafletProxy("map.bvg.start", data = points.bvg.start()) %>%
            clearShapes()       %>%
            addCircleMarkers(
                radius = ~ sqrt(total_date/10),
                fillColor =  ~ pal.start(total_date),
                stroke = FALSE,
                fillOpacity = 0.5
            )
        m.start
        
    })
    observe({
        m.end <-
            leafletProxy("map.bvg.end", data = points.bvg.end()) %>%
            clearShapes()       %>%
            addCircleMarkers(
                radius = ~ sqrt(total_date/10),
                fillColor =  ~ pal.end(total_date),
                stroke = FALSE,
                fillOpacity = 0.5
            )
        m.end
        
    })

})
