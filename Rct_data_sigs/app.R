#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# add timestamp controller if there is time
library(shiny)
library(tidyverse)
load('latest_data.Rda')
hrs <- unique(round(recent_cleaned2$Timestamp, units='hours'))
print('Data Loaded')
# TODO: Plot every 3rd data point or something to make app
# TODO: Improbe labels and add units 

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Anammox Granular Sludge Recent Signal Data"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
        # Select Probes to plot
        checkboxGroupInput('params', 'Display', 
                           colnames(recent_cleaned2)[2:ncol(recent_cleaned2)], 
                           selected = c("NH4+"), inline = FALSE,
                           width = NULL),
        
        # Select Time to plot
        sliderInput('time', 'Timestamp:', 
               hrs[1], 
               hrs[length(hrs)-6],
               hrs[1], step=difftime(hrs[1],hrs[2]))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("distPlot", height=800)
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

   output$distPlot <- renderPlot({
      # Assign inputs to variables
      x <- input$params 
      t <- input$time
      
      # Use input variables to filter dataframe
      selected <- recent_cleaned2 %>%
        filter(Timestamp>=t & Timestamp<t+6*60*60) %>% # Plot 3 hrs of data
        select('Timestamp', x) %>%
        gather(key='param', value='y', -Timestamp)
      
      # Plot dataframe
      ggplot(data=selected, aes( x=Timestamp, y=y)) +
        geom_line() +facet_grid(param~., scales='free_y')
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

