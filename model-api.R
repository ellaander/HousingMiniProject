## Get Data

library(dplyr)
library(ggplot2)
library(dbplyr)
library(vetiver)
library(pins)


housing_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")
port <- 8080  

## train model
model = lm(Sold.Price ~ Total.Bedrooms + Total.Bathrooms + Garage.Stalls, data = housing_data)
model

## vetiver Model
v = vetiver_model(model, model_name='housing_model')

## board
model_board <- board_temp(versioned = TRUE)
model_board %>% vetiver_pin_write(v)

## API ->  http://127.0.0.1:4175
library(plumber)
pr() %>%
  vetiver_api(v) %>%
  pr_run(port = port)


