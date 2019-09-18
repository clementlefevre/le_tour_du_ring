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
library(plotly)
library(shinythemes)

anim.options <- animationOptions(interval = 2000, loop = TRUE, playButton = NULL,
                                 pauseButton = NULL)

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("cyborg"),
                
    h4("Berlin Bikesharing flows"),

    
    tabsetPanel(type = "tabs",
                tabPanel("Trips & Vacancy",   
                         selectInput("maptype", "Show :",
                                     choices =   c("Flows" = 'flows',
                                                   "Availability" = 'availability'))
                         ,
                         
                         fluidRow(
                        
                            
                             column(2, radioButtons(
                             "direction", "direction",
                             
                             choiceNames = list(
                                 HTML("<font color='green'>From</font>"), 
                                 HTML("<font color='red'>To</font>")
                             ),
                             choiceValues = c(TRUE,FALSE)
                        
                         )),
                             column(
                                 2, textOutput("direction.1"),
                                 selectInput("ortsteil.from", "",
                                             choices = from.districts)
                             ),
                         column(
                             2, textOutput("direction.2"),
                             selectInput("ortsteil.to", "",
                                         choices = to.districts)
                         ),
                             column(
                                 2,
                                 selectInput("hour_filter", "Hour of day :",
                                             choices = hour_filter)
                             ),
                             column(2, radioButtons(
                                 "is.weekend", "is week end :",
                                 c("YES" = TRUE,
                                   "NO" = FALSE)
                             )),textOutput("bike_flow")
                          
                         ),        deckglOutput("flows")
                ),
                tabPanel("Bikes & BVG",h5("Bikes available on Wednesday 3rd July 2019") ,sliderInput(
                    "time",
                    "Press play button to start the animation",
                    min(df.locations.nearest.hour$timestamp),
                    max(df.locations.nearest.hour$timestamp),
                    value =as.POSIXct('2019-07-03 6:00:00'),
                    step = 60*10*2,
                    animate = anim.options
                ),leafletOutput("map.locations") 
                ),
                tabPanel("District Flow", selectInput(
                    "sankey.from",
                    "From :",
                    choices = list.sankey.districts
                ),plotlyOutput("sankey") 
                )
                )
                
   
        ,
    style = "font-family: Helvetica, Arial, sans-serif;"
))
