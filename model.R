# train_model.R
library(vetiver)
library(plumber)

# Load the data
house_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")

# Fit the model
model1 <- lm(Sold.Price ~ Total.Bedrooms + Total.Bathrooms, data = house_data)

# Save the model for use in plumber API
v <- vetiver_model(model1, "house_price_model")
vetiver_write_plumber(v, "plumber.R")

# Model prediction function for local testing or other purposes
predict_house_price <- function(bedrooms, bathrooms) {
  predict(model1, newdata = data.frame(Total.Bedrooms = bedrooms, Total.Bathrooms = bathrooms))
}
