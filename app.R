# app.R
library(shiny)
library(httr)

# Define UI for application
ui <- fluidPage(
  titlePanel("Predicted Sold Price of House"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("sliderBedrooms", "Total Number of Bedrooms", 0, 10, value = 2),
      sliderInput("sliderBathrooms", "Total Number of Bathrooms", 0, 10, value = 2),
      actionButton("submit", "Submit")
    ),
    
    mainPanel(
      plotOutput("plot1"),
      h3("Predicted Sold Price from Model:"),
      textOutput("pred1")
    )
  )
)

# Define server logic required to draw the plot and make predictions
server <- function(input, output) {
  house_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")
  
  # Reactive to store prediction
  prediction <- eventReactive(input$submit, {
    res <- POST("http://localhost:8000/predict", body = list(
      bedrooms = input$sliderBedrooms,
      bathrooms = input$sliderBathrooms
    ), encode = "json")
    
    content(res)$`1`  # Get the prediction from the API response
  })
  
  # Render the prediction
  output$pred1 <- renderText({
    prediction()
  })
  
  # Render the plot
  output$plot1 <- renderPlot({
    bedInput <- input$sliderBedrooms
    jitter_amount <- 1
    
    plot(jitter(house_data$Total.Bedrooms, amount = jitter_amount), house_data$Sold.Price,
         xlab = "Total Bedrooms", ylab = "Sold Price",
         main = "Total Bedrooms vs. Sold Price",
         bty = "n", pch = 16, col = rgb(0.1, 0.6, 1, alpha = 0.4))
    
    # Highlight the predicted point
    points(bedInput, prediction(), col = "pink", pch = 16, cex = 2)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
