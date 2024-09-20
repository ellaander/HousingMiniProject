library(shiny)
library(tibble)

api_url <- "http://127.0.0.1:8080/predict"
log <- log4r::logger()

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
      h2("House Variables"),
      verbatimTextOutput("vals"),
      h2("Predicted Sold Price"),
      textOutput("pred"),
      h2("Price vs Bedrooms Plot"),
      plotOutput("pricePlot") # plot output to display graph
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
  
    # plot for bedrooms vs sold price
    output$pricePlot <- renderPlot({
      ggplot(house_data, aes(x = Total.Bedrooms, y = Sold.Price)) +
        geom_point(size = 3, color = "lightblue") +  
        geom_smooth(method = "lm", se = FALSE, color = "gray") +  # trend line
        geom_point(aes(x = vals()$Total.Bedrooms, y = pred()$.pred[[1]]),  #  predicted point
                   color = "pink", size = 5) +  
        labs(x = "Total Bedrooms", y = "Sold Price", title = "Price vs Bedrooms") +
        theme_minimal()
    })
  
}

# Run the application
shinyApp(ui = ui, server = server)