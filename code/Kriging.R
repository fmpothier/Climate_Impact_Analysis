# Load necessary libraries
library(sf)      
library(gstat)   
library(ggplot2) 
library(dplyr)   
library(raster)
library(tmap)
library(terra)

# Set working directory
setwd("~/Downloads/classes/2024/Fall/GEOG 418/Final Project")
BC <- st_read("./Cleaned_data/BC_Boundary.shp")
st_transform(BC, crs= 3005)

################################################## Define Functions
### Remove NAs and duplicates ####
clean_data <- function(data, value_column) {
  data <- data[!is.na(data[[value_column]]), ]
  data <- data[!duplicated(st_coordinates(data)), ]
  return(data)
}

#### Perform kriging ####
perform_kriging <- function(data, formula, variogram_model, grid_points = 15000, nmax = 30, maxdist = 1e7) {
  # Create variogram
  var.smpl <- variogram(formula, data, cloud = FALSE)
  fit <- fit.variogram(var.smpl, model = variogram_model)
  
  # Define grid
  bbox <- st_bbox(data)
  grid <- st_as_sf(expand.grid(
    x = seq(bbox$xmin, bbox$xmax, length.out = sqrt(grid_points)),
    y = seq(bbox$ymin, bbox$ymax, length.out = sqrt(grid_points))
  ), coords = c("x", "y"), crs = st_crs(data))
  
  # Run kriging
  kriging_result <- krige(formula, data, grid, fit, nmax = nmax, maxdist = maxdist)
  return(list(kriging_result = st_as_sf(kriging_result), fit = fit, variogram = var.smpl))
}

#### Function to create and visualize raster ####
create_and_visualize_raster <- function(kriging_result, title, legend, palette = "magma", clip_shape = NULL) {
  coords_df <- as.data.frame(st_coordinates(kriging_result))
  coords_df$predicted <- kriging_result$var1.pred
  raster_result <- rasterFromXYZ(coords_df)
  
  if (!is.null(clip_shape)) {
    st_transform(BC, crs= 3005)
    raster_result <-mask(raster_result,BC)
    
    tm_shape(raster_result) +
      tm_raster(palette = palette, title = legend) +
      tm_shape(BC) +
      tm_borders(col = "black", lwd = 1) +
      tm_layout(
        title = title,
        title.size = 0.9,
        title.position = c("left", "top"),
        legend.position = c("left", "bottom"),
        legend.title.size = 0.7,
        legend.text.size = 0.5
      ) +
      tm_compass(position = c("right", "center")) +
      tm_scale_bar(position = c("left", "bottom"))
  }
  else{
    tm_shape(raster_result) +
      tm_raster(palette = palette, title = title) +
      tm_layout(title = title, title.size = 1.2, title.position = c("center", "top")) +
      tm_compass(position = c("right", "top")) +
      tm_scale_bar(position = c("left", "bottom"))
  }
}
# Function to validata kriging interpolation surface
validate_kriging <- function(formula, data, variogram_model, nmax = 30, maxdist = 1e7) {
  # Perform cross-validation
  cv_results <- krige.cv(
    formula = formula, 
    locations = data, 
    model = variogram_model,
    nmax = nmax,
    maxdist = maxdist
  )
  
  # Compute RMSE
  rmse <- sqrt(mean(cv_results$residual^2))
  
  # Compute R^2
  observed_values <- cv_results$observed
  predicted_values <- cv_results$var1.pred
  ss_total <- sum((observed_values - mean(observed_values))^2)
  ss_residual <- sum((observed_values - predicted_values)^2)
  r_squared <- 1 - (ss_residual / ss_total)
  
  # Return results
  return(list(RMSE = rmse, R2 = r_squared))
}
################################################## Run Kriging on Climate Data
# Read and clean climate shapefiles
rain_data_17 <- clean_data(st_read("./Cleaned_data/ClimateData_precip_2017.shp"), "ttl_prc")
temp_data_17 <- clean_data(st_read("./Cleaned_data/ClimateData_temp_2017.shp"), "TEMP")
rain_data_18 <- clean_data(st_read("./Cleaned_data/ClimateData_precip_2018.shp"), "ttl_prc")
temp_data_18 <- clean_data(st_read("./Cleaned_data/ClimateData_temp_2018.shp"), "TEMP")
rain_data_19 <- clean_data(st_read("./Cleaned_data/ClimateData_precip_2019.shp"), "ttl_prc")
temp_data_19 <- clean_data(st_read("./Cleaned_data/ClimateData_temp_2019.shp"), "TEMP")

# Kriging for 2017 precipitation
kriging_results_rain_17 <- perform_kriging(
  rain_data_17, 
  ttl_prc ~ 1, 
  vgm(psill = 39304.047, nugget = 9172.624, range = 1e6, model = "Exp")
)
# Kriging for 2018 precipitation
kriging_results_rain_18 <- perform_kriging(
  rain_data_18, 
  ttl_prc ~ 1, 
  vgm(psill = 30695.854, nugget = 3174.977, range = 1e6, model = "Exp")
)
# Kriging for 2017 temperature
kriging_results_temp_17 <- perform_kriging(
  temp_data_17, 
  TEMP ~ 1, 
  vgm(psill = 13.377, nugget = 4.264, range = 1e6, model = "Lin")
)
# Kriging for 2018 temperature
kriging_results_temp_18 <- perform_kriging(
  temp_data_18, 
  TEMP ~ 1, 
  vgm(psill = 15.114, nugget = 6.929, range = 1e6, model = "Lin")
)

# Kriging for 2019 precipitation
kriging_results_rain_19 <- perform_kriging(
  rain_data_17, 
  ttl_prc ~ 1, 
  vgm(psill = 33098.732, nugget = 861.785, range = 1e6, model = "Lin")
)

# Kriging for 2019 temperature
kriging_results_temp_19 <- perform_kriging(
  temp_data_19, 
  TEMP ~ 1, 
  vgm(psill = 16.110, nugget = 7.252, range = 1e6, model = "Lin")
)

################################################## Visualized results
#### Precipitation ####
# Visualize kriging results
kriging_raster_rain_17 <- create_and_visualize_raster(
  kriging_results_rain_17$kriging_result, 
  "Kriging Interpolation of Total Precipitation in BC (2017)","Precipitation(mm)", "Blues", BC
)
print(kriging_raster_rain_17)

# Visualize kriging results
kriging_raster_rain_18 <- create_and_visualize_raster(
  kriging_results_rain_18$kriging_result, 
  "Kriging Interpolation of Total Precipitation in BC (2018)","Precipitation(mm)", "Blues", BC
)
print(kriging_raster_rain_18)

# Visualize kriging results
kriging_raster_rain_19 <- create_and_visualize_raster(
  kriging_results_rain_19$kriging_result, 
  "Kriging Interpolation of Total Precipitation in BC (2019)","Precipitation(mm)", "Blues", BC
)
print(kriging_raster_rain_19)

#### Temperature ####
kriging_raster_temp_17 <- create_and_visualize_raster(
  kriging_results_temp_17$kriging_result, 
  "Kriging Interpolation of Average Temperature in BC (2017)","Temperature(°C)", "Reds", BC
)
print(kriging_raster_temp_17)

# Visualize kriging results
kriging_raster_temp_18 <- create_and_visualize_raster(
  kriging_results_temp_18$kriging_result, 
  "Kriging Interpolation of Average Temperature in BC (2018)","Temperature(°C)", "Reds", BC
)
print(kriging_raster_temp_18)

# Visualize kriging results
kriging_raster_temp_19 <- create_and_visualize_raster(
  kriging_results_temp_19$kriging_result, 
  "Kriging Interpolation of Average Temperature in BC (2019)","Temperature(°C)", "Reds", BC
)
print(kriging_raster_temp_19)
################################################## validating surfaces
# Create formulas
formula_rn <- ttl_prc ~ 1
formula_t <- TEMP ~ 1

# valiaded kriging suface precip 2017
variogram_model_rn17 <- vgm(psill = 39304.047, nugget = 9172.624, range = 1e6, model = "Exp")
validation_results_rn17 <- validate_kriging(formula_rn, rain_data_17, variogram_model_rn17)
RMSE_rn17 <-validation_results_rn17[1]
R2_rn17 <-validation_results_rn17[2]
print(validation_results_rn17)

# valiaded kriging suface precip 2018
variogram_model_rn18 <- vgm(psill = 30695.854, nugget = 3174.977, range = 1e6, model = "Exp")
validation_results_rn18 <- validate_kriging(formula_rn, rain_data_18, variogram_model_rn18)
RMSE_rn18 <-validation_results_rn18[1]
R2_rn18 <-validation_results_rn18[2]
print(validation_results_rn18)

# valiaded kriging suface precip 2019
variogram_model_rn19 <- vgm(psill = 33098.732, nugget = 861.785, range = 1e6, model = "Lin")
validation_results_rn19 <- validate_kriging(formula_rn, rain_data_19, variogram_model_rn19)
RMSE_rn19 <-validation_results_rn19[1]
R2_rn19 <-validation_results_rn19[2]
print(validation_results_rn19)

# valiaded kriging suface TEMP 2017
variogram_model_t17 <- vgm(psill = 13.377, nugget = 4.264, range = 1e6, model = "Lin")
validation_results_t17 <- validate_kriging(formula_t, temp_data_17, variogram_model_t17)
RMSE_t17 <-validation_results_t17[1]
R2_t17 <-validation_results_t17[2]
print(validation_results_t17)

# valiaded kriging suface TEMP 2018
variogram_model_t18 <- vgm(psill = 15.114, nugget = 6.929, range = 1e6, model = "Lin")
validation_results_t18 <- validate_kriging(formula_t, temp_data_18, variogram_model_t18)
RMSE_t18 <-validation_results_t18[1]
R2_t18 <-validation_results_t18[2]
print(validation_results_t18)

# valiaded kriging suface TEMP 2019
variogram_model_t19 <- vgm(psill = 16.110, nugget = 7.252, range = 1e6, model = "Lin")
validation_results_t19 <- validate_kriging(formula_t, temp_data_19, variogram_model_t19)
RMSE_t19 <-validation_results_t19[1]
R2_t19 <-validation_results_t19[2]
print(validation_results_t19)

# Create table with valiation stats
validating_surfaces <- data.frame(
  Statistic = c("Precipitation in 2019", "Temperature in 2019", "Precipitation in 2018", "Temperature 2018", "Precipitation in 2017", "Temperature 2017"),
  RMSE = c(as.numeric(RMSE_rn19), as.numeric(RMSE_t19), as.numeric(RMSE_rn18), as.numeric(RMSE_t18), as.numeric(RMSE_rn17), as.numeric(RMSE_t17)),
  R2 = c(as.numeric(R2_rn19), as.numeric(R2_t19), as.numeric(R2_rn18) , as.numeric(R2_t18) , as.numeric(R2_rn17) , as.numeric(R2_t17))
)

# Display the table
kable(validating_surfaces, align = "c" ,caption = "Kriging Validation Results")

