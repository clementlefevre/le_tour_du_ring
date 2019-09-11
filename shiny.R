library(shiny)

library(leaflet)
library(dplyr)

df.bvg.start <- read.csv('BVG_start_points.csv') %>% filter(ANFRAGE_DATUM == '2017-07-17')
df.bvg.end <- read.csv('BVG_end_points.csv') %>% filter(ANFRAGE_DATUM == '2017-07-17')

bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal.start <- colorBin("YlOrRd", domain = df.bvg.start$total_date, bins = bins)
pal.end <-  colorBin("BuPu", domain = df.bvg.start$total_date, bins = bins)

anim.options <- animationOptions(interval = 2000, loop = FALSE, playButton = NULL,
                 pauseButton = NULL)


ui <- fluidPage(
  sliderInput(
    "time",
    "date",
    min(df.bvg.start$request_time_rounded),
    max(df.bvg.start$request_time_rounded),
    value = max(df.bvg.start$request_time_rounded),
    step = 1,
    animate = anim.options
  ),
  fluidRow(
    column(width = 5,
           leafletOutput("map.bvg.start")
    ),
    column(width = 5, offset = 1,
           leafletOutput("map.bvg.end")
    ))
  
 
)

server <- function(input, output, session) {
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
  
  observe({
    m.start <-
      leafletProxy("map.bvg.start", data = points.bvg.start()) %>%
      clearShapes()       %>%
      addCircleMarkers(
        radius = ~ log(total_date/10),
        fillColor =  ~ pal.start(total_date),
        stroke = FALSE,
        fillOpacity = 1
      )
    m.start
    
  })
  observe({
    m.end <-
      leafletProxy("map.bvg.end", data = points.bvg.end()) %>%
      clearShapes()       %>%
      addCircleMarkers(
        radius = ~ log(total_date/10),
        fillColor =  ~ pal.end(total_date),
        stroke = FALSE,
        fillOpacity = 1
      )
    m.end
    
  })
}

shinyApp(ui, server)