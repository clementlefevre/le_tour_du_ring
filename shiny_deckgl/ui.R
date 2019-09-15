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

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    h1("deckgl for R"),
    fluidRow(column(3,   selectInput("ortsteil", "FROM Ortsteil :",
                                     choices = from.districts)),column(3,   selectInput("hour_filter", "Hour of day :",
                                                                                        choices = hour_filter)),
             column(3,radioButtons("is.weekend", "is week end :",
                                   c("YES" = TRUE,
                                     "NO" = FALSE))),
             column(3,radioButtons("direction", "direction",
                                   c("FROM" = TRUE,
                                     "TO" = FALSE)))
    )
    ,
    deckglOutput("deck"),
    style = "font-family: Helvetica, Arial, sans-serif;"
))
