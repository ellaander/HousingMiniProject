
library(dplyr)
library(ggplot2)
library(dbplyr)
library(pins)
library(plumber)

# load data
house_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")

# build predictive model
model = lm(Sold.Price ~ Total.Bedrooms + Total.Bathrooms, data = house_data)

# vetiver model
library(vetiver)
v = vetiver_model(model, model_name='house_model')

# creates temporary board to store model
model_board <- board_temp(versioned = TRUE)
model_board %>% vetiver_pin_write(v)

#initialize plumber router
pr() %>%
  vetiver_api(v) %>%
  pr_run(port = 8080)


