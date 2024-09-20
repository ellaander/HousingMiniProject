# plumber.R
library(vetiver)
library(plumber)

# Load model
house_data <- read.csv("https://raw.githubusercontent.com/gmtanner-cord/DATA470-2024/refs/heads/main/fmhousing/FM_Housing_2018_2022_clean.csv")
model1 <- vetiver_read_model("house_price_model")

#* @apiTitle House Price Prediction API

#* Predict house price
#* @param bedrooms:int Total number of bedrooms
#* @param bathrooms:int Total number of bathrooms
#* @post /predict
function(bedrooms, bathrooms) {
  predict(model1, newdata = data.frame(Total.Bedrooms = as.numeric(bedrooms), Total.Bathrooms = as.numeric(bathrooms)))
}
