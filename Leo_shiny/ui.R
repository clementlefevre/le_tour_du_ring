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

# Define UI for application that draws a histogram
shinyUI(fluidPage(theme = shinytheme("cyborg"),

    # Application title
    titlePanel("Bikesharing trips between Berlin LOR"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
      sidebarPanel(
            selectInput("from.lor", "LOR",
                        choices = lor.selection,selected=1011303 ),
            
            selectInput("time.interval", "Interval",
                        choices = interval.selection,selected = 'Morning' ),
            
            radioButtons(
              "is.weekend", "Weekend?:",
              c("Weekend day" = TRUE,
                "Weekday" = FALSE)
            ),
            radioButtons(
              "fromto", "From/To",
              c("From" = TRUE,
                "To" = FALSE)
            ),
            actionButton("chngnd", "An action button")
              ),
     
        # Show a plot of the generated distribution
        mainPanel(
            
            leafletOutput("map",width='100%',height=800) 
        )
    )
))
