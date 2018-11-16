#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)
library(rsconnect)




bcl <- read.csv("bcl-data.csv", stringsAsFactors = FALSE)
# Define UI for application that draws a histogram
ui <- fluidPage(
  titlePanel("BC Liquor price app", 
             windowTitle = "BCL app"),
  sidebarLayout(
    sidebarPanel(

      # Add this slider to the sidebar panel so that the user can select a price range:
      
      sliderInput("priceInput", "Select your desired price range.",
                  min = 0, max = 100, value = c(15, 30), pre="$"),
      
      radioButtons("typeinput", "Select your alcoholic beverage type",
                   choices=c("BEER", "REFRESHMENT", "SPIRITS", "WINE"),
                   selected= "WINE"),
      
      # Add an option to sort the results table by price.
      checkboxInput("sortInput", "Sort results by price",
                    value= FALSE,
                    width= NULL),
      # Add an option to let user choose whether they would like to narrow down by the sweetness of wine
      
      checkboxInput("sweetSort", "Narrow down by sweetness",
                    value= FALSE,
                    width= NULL),
      
      # the sweetness slider only showed while the Wine is chosen.
      conditionalPanel(
        condition = "input.typeinput == 'WINE'",
        sliderInput("sweetness", "Wine Sweetness Level", min = 0, max = 10, value = c(3,5))),
      
      # user can pick their desire color for the histogram bars. 
      colourpicker::colourInput("col", "Choose colour", "#505F8F")
      
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Plot", plotOutput("price_hist")),
        tabPanel("Summary Table", DT::dataTableOutput("NEWTABLE")),
        # insert an image in a separate panel
        tabPanel("BC liquor store image", img(src = "BCLS.jPG"))
      )
      
      
      
    )
  )
  )

# Define server logic required to draw a histogram
# use input$... to access the input of some specific term
server <- function (input,output){
  observe(print(input$priceInput))
  
  bcl_filtered <- reactive({
    bcl %>% 
      filter(Price < input$priceInput[2], 
             Price >input$priceInput[1],
             Type == input$typeinput 
      )
  })
  
  output$price_hist <- renderPlot({
    bcl_filtered() %>% 
      ggplot(aes(Price))+
      geom_histogram(binwidth = 1,fill = input$col)
    
  })
  
 
# Use the DT package to turn the current results table into an interactive table.
# the sweetness only narrow down while the users choose to do so.
# the table only sorted by price while the users choose to do so.
  output$NEWTABLE <- DT::renderDataTable( 
    if(input$sortInput==TRUE & input$sweetSort == TRUE){
      bcl_filtered() %>% 
        arrange(desc(Price)) %>% 
        filter(Sweetness <= input$sweetness[2], Sweetness >= input$sweetness[1])
    }
    else if (input$sortInput==TRUE & input$sweetSort == FALSE){
     bcl_filtered() %>% 
       arrange(desc(Price))
     }
    else if (input$sortInput== FALSE & input$sweetSort == TRUE){
       bcl_filtered() %>% 
         filter(Sweetness <= input$sweetness[2], Sweetness >= input$sweetness[1])
     }
    else  bcl_filtered()

  )
  
  
  
} 

# Run the application 
shinyApp(ui = ui, server = server)

