#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)


anim.options <- animationOptions(interval = 2000, loop = FALSE, playButton = NULL,
                                 pauseButton = NULL)


# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("BVG / Bikesharing Data"),

    # Sidebar with a slider input for number of bins
   
       

        # Show a plot of the generated distribution
        mainPanel(
            tabsetPanel(type = "tabs",
                        tabPanel("BVG",   sliderInput(
                            "time",
                            "date",
                            min(df.bvg.start$request_time_rounded),
                            max(df.bvg.start$request_time_rounded),
                            value = max(df.bvg.start$request_time_rounded),
                            step = 1,
                            animate = anim.options
                        ),fluidRow(
                            column(width = 5,
                                   leafletOutput("map.bvg.start")
                            ),
                            column(width = 5, offset = 1,
                                   leafletOutput("map.bvg.end")
                            ))),
                        tabPanel("Bikesharing", selectInput("bikeId", "Bike ID :", 
                                                            choices=bike.id.list), leafletOutput('map.bikes')),
                        tabPanel("Table", tableOutput("table"))
            )
        )
    
))
