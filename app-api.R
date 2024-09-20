library(shiny)
library(tibble)

api_url <- "http://127.0.0.1:8080/predict"
log <- log4r::logger()

ui <- fluidPage(
  titlePanel("House Sold Price Predictor"),

  # Model input values
  sidebarLayout(
    sidebarPanel(
      sliderInput(
        "Garage.Stalls",
        "Number of Garage Stalls)",
        min = 0,
        max = 5,
        value = 2,
        step = 1
      ),
      sliderInput(
        "Total.Bedrooms",
        "Number of Bedrooms)",
        min = 0,
        max = 5,
        value = 2,
        step = 1
      ),
      sliderInput(
        "Total.Bathrooms",
        "Number of Bathrooms)",
        min = 0,
        max = 5,
        value = 2,
        step = 1
      ),
      # Get model predictions
      actionButton(
        "predict",
        "Predict"
      )
    ),

    mainPanel(
      h2("House Variables"),
      verbatimTextOutput("vals"),
      h2("Predicted House Sold Price"),
      textOutput("pred")
    )
  )
)

server <- function(input, output) {
  log4r::info(log, "App Started")
  # Input params
  vals <- reactive(
    tibble(
      Garage.Stalls = input$Garage.Stalls,
      Total.Bathrooms = input$Total.Bathrooms,
      Total.Bedrooms = input$Total.Bedrooms
    )
  )

  # Fetch prediction from API
  pred <- eventReactive(
    input$predict,
    {
      log4r::info(log, "Prediction Requested")
      r <- httr2::request(api_url) |>
            httr2::req_body_json(vals()) |>
            httr2::req_error(is_error = \(resp) FALSE) |>
            httr2::req_perform()
      log4r::info(log, "Prediction Returned")
      
      if (httr2::resp_is_error(r)) {
        log4r::error(log, paste("HTTP Error",
                                httr2::resp_status(r),
                                httr2::resp_status_desc(r)))
      }
      
      httr2::resp_body_json(r)
    },
    ignoreInit = TRUE
  )

  # Render to UI
  output$pred <- renderText(pred()$.pred[[1]])
  output$vals <- renderPrint(vals())
}

# Run the application
shinyApp(ui = ui, server = server)
