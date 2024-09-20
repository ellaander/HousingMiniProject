library(shiny)
house_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")
function(input, output) {
  
  # Fit Models
  model1 <- lm(Sold.Price ~ Total.Bedrooms + Total.Bathrooms, data = house_data)
  
  model1pred <- reactive({
    totalbed <- input$sliderBedrooms
    totalbath <- input$sliderBathrooms
    predict(model1, newdata = data.frame(Total.Bedrooms = totalbed, Total.Bathrooms = totalbath))
  })
  
  output$pred1 <- renderText({
    model1pred()
  })
}
