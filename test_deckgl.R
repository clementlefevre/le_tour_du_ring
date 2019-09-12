## @knitr shiny-integration
library(magrittr)
library(shiny)
library(deckgl)
library(dplyr)

Sys.setenv(MAPBOX_API_TOKEN = "pk.eyJ1IjoidGVjaG5vbG9naWVzdGlmdHVuZyIsImEiOiJjazBkeDduY3kwMW8zM2ZwbGgwb3kxbnNwIn0.CmASst9JC6hSpILBFQHNig")

sample_data <- bart_segments
df <-read.csv('bvg_flat.csv',nrows = 300, stringsAsFactors = F) %>% na.omit(from_lat)
sample_data <- df

properties <- list(
  getWidth = 2,
  getSourceColor = JS("d => [Math.sqrt(d.inbound), 140, 0]"),
  getTargetColor = JS("d => [Math.sqrt(d.outbound), 140, 0]"),
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
    deckgl(zoom = 10, pitch = 35) %>%
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
        data = sample_data[1:sample(1:45, 1), ],
        properties = properties
      ) %>%
      update_deckgl(it = "works")
  })
}

if (interactive()) shinyApp(view, backend)