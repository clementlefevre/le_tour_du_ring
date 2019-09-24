#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinymaterial)
library(deckgl)
library(plotly)

anim.options <-
    animationOptions(
        interval = 2000,
        loop = TRUE,
        playButton = NULL,
        pauseButton = NULL
    )

# Wrap shinymaterial apps in material_page
ui <- material_page(
    background_color='black',
    tags$body(
        tags$style(HTML("
      @import url('https://fonts.googleapis.com/css?family=Roboto+Slab&display=swap');
      
      body {
        font-family: 'Roboto Slab', serif;
        font-weight: 500;
        line-height: 1.1;
        color:  #ef5350;
      }

    "))
    ),
    
    title = "Bike Pulse",
    # Place side-nav in the beginning of the UI

    # Define tabs
    material_tabs(
        tabs = c(
            "Trips & Vacancy" = "first_tab",
            "Bikes & BVG" = "second_tab",
            "District Flow" = "third_tab",
            "About" = "fourth_tab"
        )
    ),
    # Define tab content
    material_tab_content(
        tab_id = "first_tab",
      br(),
        material_row(
            material_column(
                width = 4,
                material_dropdown(
                    "maptype",
                    "Show :",
                    selected = 'flows',
                    choices =   c("Flows" = 'flows',
                                  "Availability" = 'availability'),
                    color = "#ef5350"
                ) ,
                material_dropdown(
                    input_id = "direction",
                    label = "direction",
                    selected = TRUE,
                    choices = c("From" = TRUE,
                                "To" = FALSE),
                    color = "#ef5350"
                    
                )
            ),
            material_column(
                width = 4,
                material_dropdown(
                    "ortsteil.from",
                    label=textOutput('direction.1'),
                    selected = 'Mitte',
                    choices = from.districts,color = "#ef5350"
                ),
              
                material_dropdown("ortsteil.to",  label=textOutput('direction.2'),
                                  choices = to.districts,color = "#ef5350")
                
            ),material_column(width=4,
                              material_dropdown("hour_filter", NULL,
                                                choices = hour_filter,color = "#ef5350"),
                              material_dropdown(
                                  "is.weekend",
                                  label=NULL,
                                  selected = TRUE,
                                  choices = c("weekend " = TRUE,
                                              "week days" = FALSE),color = "#ef5350"
                              )
                              )
        )
        
        ,
        material_row(deckglOutput(
            "flows", width = "100%", height = 800
        ))
        
        
    ),
    material_tab_content(
        tab_id = "second_tab",
        br(),
        material_row(material_column(
            width = 4,
            textOutput('time.selected'),
            material_slider(
                input_id="time_input",
                label='select an hour :',
                min_value = 0,
                max_value = 23,
                initial_value = 6,
                step_size = 1,
                color = "#ef5350"
            )
        ))
        ,
        material_row(leafletOutput(
            "map.locations", width = '100%', height =  800
        ))
        
        
        
    ),
    material_tab_content(
        tab_id = "third_tab",
        br(),
        material_row(
            material_column(
                width=4,
                material_dropdown("sankey.from",
                                  "From :",
                                  choices = list.sankey.districts), color = "#ef5350"
            )
            )
        
      ,material_row(
         
              plotlyOutput("sankey")
         
      )
        
    ), material_tab_content(tab_id = "fourth_tab",br(),  img(src='final_export3.png', align = "left",width="100%"))
)