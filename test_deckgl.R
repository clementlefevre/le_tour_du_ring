## @knitr shiny-integration
library(magrittr)
library(shiny)
library(deckgl)
library(dplyr)
source('key.R')


#sample_data <- bart_segments
#df <-read.csv('bvg_flat.csv',nrows = 300, stringsAsFactors = F) %>% na.omit(from_lat)
df <-read.csv('data/trips_districts.csv', stringsAsFactors = F) %>% filter(date_only=='2019-07-01')
df <- df %>% select(from_lng = longitude_LOR_district.x,from_lat=latitude_LOR_district.x,to_lng=longitude_LOR_district.y,to_lat=latitude_LOR_district.y,trips)
sample_data <- df

properties <- list(
  getWidth = ~trips,
  pickable = TRUE,
  getSourceColor = JS("d => [Math.sqrt(d.inbound), 255,127]"),
  getTargetColor = JS("d => [255, 0, 0]"),
  getSourcePosition = ~from_lng + from_lat,
  getTargetPosition = ~to_lng + to_lat
)

view <- fluidPage(
  h1("deckgl for R"),
  actionButton("go", "go"),
  deckglOutput("deck"),
  style = "font-family: Helvetica, Arial, sans-serif;"
)

backend <- function(input, output) {
  output$deck <- renderDeckgl({
    deckgl(zoom = 10, pitch = 35,latitude = 52.52, longitude = 13.4) %>%
      add_arc_layer(
        data = sample_data,
        properties = properties
      ) %>% add_mapbox_basemap()
  })
  
  observeEvent(input$deck_onclick, {
    info <- input$deck_onclick
    print(names(info$object))
  })
  
  observeEvent(input$go, {
    deckgl_proxy("deck") %>%
      add_arc_layer(
        data = df %>% filter(from_lng==sample(df$from_lng,1)),
        properties = properties
      ) %>%
      update_deckgl(it = "works")
  })
}

if (interactive()) shinyApp(view, backend)