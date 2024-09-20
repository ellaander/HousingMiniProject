library(shiny)

fluidPage(
  titlePanel("Predicted Sold Price of House"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("sliderBedrooms", "Total Number of Bedrooms", 0, 10, value = 2),
      sliderInput("sliderBathrooms", "Total Number of Bathrooms", 0, 10, value = 2),
      submitButton("Submit")
    ),
    
    mainPanel(
      plotOutput("plot1"),
      h3("Predicted Sold Price from Model:"),
      textOutput("pred1"),
    )
  )
)
