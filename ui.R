library(shiny)

fluidPage(
  titlePanel("Predicted Sold Price of House"),
  
  tags$head(
    tags$style(HTML("
    body {
      background-image: url('background.jpg');
      background-size: cover;
      opacity: 0.9;
    }
  "))
  )
  
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("sliderBedrooms", "Number of Bedrooms", 0, 10, value = 2),
      sliderInput("sliderBathrooms", "Number of Bathrooms", 0, 10, value = 2),
      submitButton("Submit")
    ),
    
    mainPanel(
      plotOutput("plot1"),
      h3("Predicted Sold Price from Model:"),
      textOutput("pred1"),
    )
  )
)
