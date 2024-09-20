library(shiny)
library(tibble)
library(tidyverse)

api_url <- "http://127.0.0.1:8080/predict"
log <- log4r::logger()
house_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")

ui <- fluidPage(
  titlePanel("Predicted Sold Price of House "),
  
  # select total bedrooms
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "Total.Bedrooms",
        "Total Bedrooms",
        min = 0,
        max = 10,
        value = 3,
        step = 1
      ),
      
      # select total bathrooms
      sliderInput(
        "Total.Bathrooms",
        "Total Bathrooms",
        min = 0,
        max = 10,
        value = 3,
        step = 1
      ),
      
      # trigger predictions
      actionButton(
        "predict",
        "Predict"
      )
    ),
    
    # displays variables and predicted price
    mainPanel(
      plotOutput("pricePlot"), # plot output to display graph
      h2("Predicted Sold Price"),
      textOutput("pred"),
    )
  )
)



server <- function(input, output) {
  log4r::info(log, "App Started") # log app starting
  
  #store inputs in a tibble
  vals <- reactive(
    tibble(
      Total.Bedrooms = input$Total.Bedrooms,
      Total.Bathrooms = input$Total.Bathrooms,
    )
  )
  
  # triggers predictions when predict is clicked
  pred <- eventReactive(
    input$predict,
    {
      log4r::info(log, "Prediction Requested")
      
      # call to prediction server
      r <- httr2::request(api_url) |>
        # attach values to request
        httr2::req_body_json(vals()) |>
        # handle errors 
        httr2::req_error(is_error = \(resp) FALSE) |>
        # perform request
        httr2::req_perform()
      
      # log response
      log4r::info(log, "Prediction Returned")
      
      # error handling
      if (httr2::resp_is_error(r)) {
        log4r::error(log, paste("HTTP Error",
                                httr2::resp_status(r),
                                httr2::resp_status_desc(r)))
      }
      
      # parse response
      httr2::resp_body_json(r)
    },
    
    #ignore initial state, trigger after button click
    ignoreInit = TRUE
  )
  
  # show predictions results on UI
  output$pred <- renderText(pred()$.pred[[1]])
  output$vals <- renderPrint(vals())
  
  output$pricePlot <- renderPlot({
    ggplot(house_data, aes(x = Total.Bedrooms, y = Sold.Price)) +
      # plot of  data points
      geom_jitter(size = 3, color = "steelblue", alpha = 0.3, width = 0.5, height = 0) +
      
      # plot of the predicted point
      geom_point(aes(x = vals()$Total.Bedrooms, y = pred()$.pred[[1]]), 
                 color = "red", size = 6, shape = 18) +
      
      # Add a linear regression line
      geom_smooth(method = "lm", color = "darkgreen", se = FALSE, size = 1) +
      labs(x = "Number of Bedrooms", 
           y = "Sold Price ($)", 
           title = "Relationship Between Bedrooms and Sold Price") +

      theme_minimal(base_size = 15) +
      theme(plot.title = element_text(hjust = 0.5, face = "bold"),
            axis.title.x = element_text(margin = margin(t = 10)),
            axis.title.y = element_text(margin = margin(r = 10))) +
      annotate("text", label = "Predicted Point", x = vals()$Total.Bedrooms, 
               y = pred()$.pred[[1]] + 10000, color = "red", size = 5, fontface = "italic")
  })
  
  
}

shinyApp(ui = ui, server = server)