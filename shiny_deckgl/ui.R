#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(deckgl)

anim.options <- animationOptions(interval = 2000, loop = TRUE, playButton = NULL,
                                 pauseButton = NULL)

# Define UI for application that draws a histogram
shinyUI(fluidPage(tags$style("#hour_filter {background-color:blue;}"),
    h3("sharing is biking"),
    
    tabsetPanel(type = "tabs",
                tabPanel("Deckgl",   
                         selectInput("maptype", "Show :",
                                     choices =   c("Flows" = 'flows',
                                                   "Availability" = 'availability'))
                         ,
                         
                         fluidRow(
                        
                            
                             column(3, radioButtons(
                             "direction", "direction",
                             c("FROM" = TRUE,
                               "TO" = FALSE)
                         )),
                             column(
                                 3,
                                 selectInput("ortsteil.from", "FROM :",
                                             choices = from.districts)
                             ),
                         column(
                             3,
                             selectInput("ortsteil.to", "TO :",
                                         choices = to.districts)
                         ),
                             column(
                                 3,
                                 selectInput("hour_filter", "Hour of day :",
                                             choices = hour_filter)
                             ),
                             column(3, radioButtons(
                                 "is.weekend", "is week end :",
                                 c("YES" = TRUE,
                                   "NO" = FALSE)
                             )),textOutput("bike_flow")
                          
                         ),        deckglOutput("flows")
                ),
                tabPanel("Anim", sliderInput(
                    "time",
                    "Bikes available on Wednesday 3rd July 2019",
                    min(df.locations.nearest.hour$timestamp),
                    max(df.locations.nearest.hour$timestamp),
                    value =as.POSIXct('2019-07-03 6:00:00'),
                    step = 60*10*2,
                    animate = anim.options
                ),leafletOutput("map.locations") 
                ))
                
   
        ,
    style = "font-family: Helvetica, Arial, sans-serif;"
))
