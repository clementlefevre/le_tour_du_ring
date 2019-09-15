#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(deckgl)


anim.options <- animationOptions(interval = 2000, loop = TRUE, playButton = NULL,
                                 pauseButton = NULL)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    h3("sharing is biking"),
    
    tabsetPanel(type = "tabs",
                tabPanel("Deckgl",   
                         selectInput("maptype", "Show :",
                                     choices =   c("Flows" = 'flows',
                                                   "Availability" = 'availability'))
                         ,
                         
                         fluidRow(
                             column(
                                 3,
                                 selectInput("ortsteil", "FROM Ortsteil :",
                                             choices = from.districts)
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
                             )),
                             column(3, radioButtons(
                                 "direction", "direction",
                                 c("FROM" = TRUE,
                                   "TO" = FALSE)
                             ))
                         ),        deckglOutput("flows")
                ),
                tabPanel("Anim", sliderInput(
                    "time",
                    "date",
                    0,
                    23,
                    value =8,
                    step = 1,
                    animate = anim.options
                ),leafletOutput("map.locations") 
                ))
                
   
        ,
    style = "font-family: Helvetica, Arial, sans-serif;"
))
