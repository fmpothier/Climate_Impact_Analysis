library(sf)
library(sp)
library(spdep)
library(GWmodel)
library(ggplot2)
library(ggspatial)
library(viridis)
library(st)
library(dplyr)
library(lmtest)
library(car)
library(sandwich)
library(MASS)

# Set working directory
dir <- "~/Downloads/classes/2024/Fall/GEOG 418/Final Project"
setwd(dir)

BC <- st_read("./Cleaned_data/BC_Boundary.shp")

################################################## Define Functions
#### GWR Function ####
run_gwr_model <- function(dependent_var, independent_var, data, adaptive = FALSE) {
  # Bandwidth Selection
  optimal_bandwidth <- bw.gwr(dependent_var ~ independent_var, data = data)
  print(paste("Optimal Bandwidth selected:", optimal_bandwidth))
  
  # Run GWR Model
  gwr_model <- gwr.basic(dependent_var ~ independent_var,
                         data = data,
                         bw = optimal_bandwidth,
                         adaptive = adaptive)
  
  # Validate Model
  if (is.null(gwr_model) || is.null(gwr_model$SDF)) {
    stop("The GWR model did not return valid results.")
  }
  return(gwr_model)
}

################################################## 
# Load shapefiles
indep_sf_rn17 <- st_read("./Cleaned_data/ClimateData_precip_2017.shp")
indep_sf_rn18 <- st_read("./Cleaned_data/ClimateData_precip_2018.shp")
indep_sf_rn19 <- st_read("./Cleaned_data/ClimateData_precip_2019.shp")

indep_sf_t17 <- st_read("./Cleaned_data/ClimateData_temp_2017.shp")
indep_sf_t18 <- st_read("./Cleaned_data/ClimateData_temp_2018.shp")
indep_sf_t19 <- st_read("./Cleaned_data/ClimateData_temp_2019.shp")

dependent_sf_fire17 <- st_read("./Cleaned_data/BC_Fire_2017.shp")
dependent_sf_fire18 <- st_read("./Cleaned_data/BC_Fire_2018.shp")
dependent_sf_fire19 <- st_read("./Cleaned_data/BC_Fire_2019.shp")

################################################## precipitation
# Ensure CRS alignment
if (st_crs(dependent_sf_fire17) != st_crs(indep_sf_rn17)) {
  indep_sf_rn17 <- st_transform(indep_sf_rn17, crs = st_crs(dependent_sf_fire17))
}
if (st_crs(dependent_sf_fire18) != st_crs(indep_sf_rn18)) {
  indep_sf_rn18 <- st_transform(indep_sf_rn18, crs = st_crs(dependent_sf_fire18))
}
if (st_crs(dependent_sf_fire19) != st_crs(indep_sf_rn19)) {
  indep_sf_rn19 <- st_transform(indep_sf_rn19, crs = st_crs(dependent_sf_fire19))
}
# Perform spatial join
fire_rn_17 <- st_join(dependent_sf_fire17, indep_sf_rn17, join = st_nearest_feature)
fire_rn_18 <- st_join(dependent_sf_fire18, indep_sf_rn18, join = st_nearest_feature)
fire_rn_19 <- st_join(dependent_sf_fire19, indep_sf_rn19, join = st_nearest_feature)

# Convert variables to numeric
fire_rn_17 <- fire_rn_17 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))
fire_rn_17 <- fire_rn_17 %>%
  mutate(ttl_prc = as.numeric(ttl_prc))
fire_rn_18 <- fire_rn_18 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))
fire_rn_18 <- fire_rn_18 %>%
  mutate(ttl_prc = as.numeric(ttl_prc))
fire_rn_19 <- fire_rn_19 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))
fire_rn_19 <- fire_rn_19 %>%
  mutate(ttl_prc = as.numeric(ttl_prc))

# Craete neighbors and variables
fire_rn_17_sp <- st_as_sf(fire_rn_17)
coords_sp_rn17 <- st_coordinates(fire_rn_17_sp)
nb_sp_rn17 <- dnearneigh(coords_sp_rn17, d1 = 0, d2 = 200000)

fire_rn_18_sp <- st_as_sf(fire_rn_18)
coords_sp_rn18 <- st_coordinates(fire_rn_18_sp)
nb_sp_rn18 <- dnearneigh(coords_sp_rn18, d1 = 0, d2 = 200000)

fire_rn_19_sp <- st_as_sf(fire_rn_19)
coords_sp_rn19 <- st_coordinates(fire_rn_19_sp)
nb_sp_rn19 <- dnearneigh(coords_sp_rn19, d1 = 0, d2 = 200000)

fire_rn_17_sp <- as_Spatial(fire_rn_17)
dependent_var17 <- fire_rn_17_sp@data$CURRENT_SI
indep_var_rn17 <- fire_rn_17_sp@data$ttl_prc

fire_rn_18_sp <- as_Spatial(fire_rn_18)
dependent_var18 <- fire_rn_18_sp@data$CURRENT_SI
indep_var_rn18 <- fire_rn_18_sp@data$ttl_prc

fire_rn_19_sp <- as_Spatial(fire_rn_19)
dependent_var19 <- fire_rn_19_sp@data$CURRENT_SI
indep_var_rn19 <- fire_rn_19_sp@data$ttl_prc

# Perform Checks
if (any(sapply(nb_sp_rn17, length) == 0)) {
  warning("Some polygons have no neighbors (2017). This may cause issues for GWR.")
}
if (any(sapply(nb_sp_rn18, length) == 0)) {
  warning("Some polygons have no neighbors (2018). This may cause issues for GWR.")
}
if (any(sapply(nb_sp_rn19, length) == 0)) {
  warning("Some polygons have no neighbors (2019). This may cause issues for GWR.")
}
if (!is.numeric(dependent_var17)) {
  dependent_var17 <- as.numeric(as.character(dependent_var17))
  if (any(is.na(dependent_var17))) {
    stop("Conversion failed: Some entries in dependent_var could not be converted to numeric.")
  }
}
if (!is.numeric(dependent_var18)) {
  dependent_var18 <- as.numeric(as.character(dependent_var18))
  if (any(is.na(dependent_var18))) {
    stop("Conversion failed: Some entries in dependent_var could not be converted to numeric.")
  }
}
if (!is.numeric(dependent_var19)) {
  dependent_var19 <- as.numeric(as.character(dependent_var19))
  if (any(is.na(dependent_var19))) {
    stop("Conversion failed: Some entries in dependent_var could not be converted to numeric.")
  }
}
if (!is.numeric(indep_var_rn17)) {
  indep_var_rn17 <- as.numeric(as.character(indep_var_rn17))
  if (any(is.na(indep_var_rn17))) {
    stop("Conversion failed: Some entries in independent_var could not be converted to numeric.")
  }
}
if (!is.numeric(indep_var_rn18)) {
  indep_var_rn18 <- as.numeric(as.character(indep_var_rn18))
  if (any(is.na(indep_var_rn18))) {
    stop("Conversion failed: Some entries in independent_var could not be converted to numeric.")
  }
}
if (!is.numeric(indep_var_rn19)) {
  indep_var_rn19 <- as.numeric(as.character(indep_var_rn19))
  if (any(is.na(indep_var_rn19))) {
    stop("Conversion failed: Some entries in independent_var could not be converted to numeric.")
  }
}

gwr_model_opt_rn17 <- run_gwr_model(sqrt(dependent_var17), indep_var_rn17, fire_rn_17_sp)
gwr_model_opt_rn18 <- run_gwr_model(sqrt(dependent_var18), indep_var_rn18, fire_rn_18_sp)
gwr_model_opt_rn19 <- run_gwr_model(log(dependent_var19), indep_var_rn19, fire_rn_19_sp)

################################################## temperature
dependent_sf_fire17 <- st_read("./Cleaned_data/BC_Fire_2017.shp")
dependent_sf_fire18 <- st_read("./Cleaned_data/BC_Fire_2018.shp")
dependent_sf_fire19 <- st_read("./Cleaned_data/BC_Fire_2019.shp")

# Ensure CRS alignment
if (st_crs(dependent_sf_fire17) != st_crs(indep_sf_t17)) {
  indep_sf_t17 <- st_transform(indep_sf_t17, crs = st_crs(dependent_sf_fire17))
}
if (st_crs(dependent_sf_fire18) != st_crs(indep_sf_t18)) {
  indep_sf_t18 <- st_transform(indep_sf_t18, crs = st_crs(dependent_sf_fire18))
}
if (st_crs(dependent_sf_fire19) != st_crs(indep_sf_t19)) {
  indep_sf_t19 <- st_transform(indep_sf_t19, crs = st_crs(dependent_sf_fire19))
}
# Perform spatial join
fire_t_17 <- st_join(dependent_sf_fire17, indep_sf_t17, join = st_nearest_feature)
fire_t_18 <- st_join(dependent_sf_fire18, indep_sf_t18, join = st_nearest_feature)
fire_t_19 <- st_join(dependent_sf_fire19, indep_sf_t19, join = st_nearest_feature)

# Convert variables to numeric
fire_t_17 <- fire_t_17 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))
fire_t_17 <- fire_t_17 %>%
  mutate(TEMP = as.numeric(TEMP))
fire_t_19 <- fire_t_19 %>%
  mutate(TEMP = as.numeric(TEMP))
fire_t_18 <- fire_t_18 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))
fire_t_18 <- fire_t_18 %>%
  mutate(TEMP = as.numeric(TEMP))
fire_t_19 <- fire_t_19 %>%
  mutate(TEMP = as.numeric(TEMP))

# Craete neighbors and variables
fire_t_17_sp <- st_as_sf(fire_t_17)
coords_sp_t17 <- st_coordinates(fire_t_17_sp)
nb_sp_t17 <- dnearneigh(coords_sp_t17, d1 = 0, d2 = 200000)

fire_t_18_sp <- st_as_sf(fire_t_18)
coords_sp_t18 <- st_coordinates(fire_t_18_sp)
nb_sp_t18 <- dnearneigh(coords_sp_t18, d1 = 0, d2 = 200000)

fire_t_19_sp <- st_as_sf(fire_t_19)
coords_sp_t19 <- st_coordinates(fire_t_19_sp)
nb_sp_t19 <- dnearneigh(coords_sp_t19, d1 = 0, d2 = 200000)

fire_t_17_sp <- as_Spatial(fire_t_17)
dependent_var17 <- fire_t_17_sp@data$CURRENT_SI
indep_var_t17 <- fire_t_17_sp@data$TEMP

fire_t_18_sp <- as_Spatial(fire_t_18)
dependent_var18 <- fire_t_18_sp@data$CURRENT_SI
indep_var_t18 <- fire_t_18_sp@data$TEMP

fire_t_19_sp <- as_Spatial(fire_t_19)
dependent_var19 <- fire_t_19_sp@data$CURRENT_SI
indep_var_t19 <- fire_t_19_sp@data$TEMP

# Perform Checks
if (any(sapply(nb_sp_t17, length) == 0)) {
  warning("Some polygons have no neighbors. This may cause issues for GWR.")
}
if (any(sapply(nb_sp_t18, length) == 0)) {
  warning("Some polygons have no neighbors. This may cause issues for GWR.")
}
if (any(sapply(nb_sp_t19, length) == 0)) {
  warning("Some polygons have no neighbors. This may cause issues for GWR.")
}
if (!is.numeric(dependent_var17)) {
  dependent_var17 <- as.numeric(as.character(dependent_var17))
  if (any(is.na(dependent_var17))) {
    stop("Conversion failed: Some entries in dependent_var could not be converted to numeric.")
  }
}
if (!is.numeric(dependent_var18)) {
  dependent_var18 <- as.numeric(as.character(dependent_var18))
  if (any(is.na(dependent_var18))) {
    stop("Conversion failed: Some entries in dependent_var could not be converted to numeric.")
  }
}
if (!is.numeric(dependent_var19)) {
  dependent_var19 <- as.numeric(as.character(dependent_var19))
  if (any(is.na(dependent_var19))) {
    stop("Conversion failed: Some entries in dependent_var could not be converted to numeric.")
  }
}
if (!is.numeric(indep_var_t17)) {
  indep_var_t17 <- as.numeric(as.character(indep_var_t17))
  if (any(is.na(indep_var_t17))) {
    stop("Conversion failed: Some entries in independent_var could not be converted to numeric.")
  }
}
if (!is.numeric(indep_var_t18)) {
  indep_var_t18 <- as.numeric(as.character(indep_var_t18))
  if (any(is.na(indep_var_t18))) {
    stop("Conversion failed: Some entries in independent_var could not be converted to numeric.")
  }
}
if (!is.numeric(indep_var_t19)) {
  indep_var_t19 <- as.numeric(as.character(indep_var_t19))
  if (any(is.na(indep_var_t19))) {
    stop("Conversion failed: Some entries in independent_var could not be converted to numeric.")
  }
}

# Box-Cox transformation
boxcox_result <- boxcox(dependent_var18 ~ indep_var_t18, data = fire_t_18_sp)
lambda <- boxcox_result$x[which.max(boxcox_result$y)]

# Box-Cox transformation
boxcox_result <- boxcox(dependent_var18 ~ indep_var_t18, data = fire_t_18_sp@data)

# Find the optimal lambda
lambda <- boxcox_result$x[which.max(boxcox_result$y)]

# Apply the transformation to the dependent variable
transformed <- if (lambda != 0) {
  (dependent_var17^lambda - 1) / lambda
} else {
  log(dependent_var17)
}

# Add the transformed variable back to the fire_t_17_sp@data slot
fire_t_18_sp@data$transformed <- transformed


gwr_model_opt_t17 <- run_gwr_model(sqrt(dependent_var17), indep_var_t17, fire_t_17_sp)
gwr_model_opt_t18 <- run_gwr_model(log(dependent_var18), indep_var_t18, fire_t_18_sp)
gwr_model_opt_t19 <- run_gwr_model(log(dependent_var19), indep_var_t19, fire_t_19_sp)

################################################## Visualize Map results
# precip 2017
gwr_results_optimal_rn17 <- as.data.frame(gwr_model_opt_rn17$SDF)
coordinates_optimal_rn17 <- st_coordinates(st_centroid(fire_rn_17))
gwr_results_optimal_rn17 <- cbind(gwr_results_optimal_rn17, coordinates_optimal_rn17)
gwr_output_sf_optimal_rn17 <- st_as_sf(gwr_results_optimal_rn17, coords = c("X", "Y"), crs = st_crs(fire_rn_17))

ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = gwr_output_sf_optimal_rn17, aes(colour = Local_R2)) +
  scale_color_gradientn(colours = c("lightgreen", "turquoise", "cyan", "skyblue", "blue", "navy")) +
  labs(title = "GWR Coefficients with Optimal Bandwidth for Total Precipitation in BC (2017)",
       fill = "localR2",
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal()+ 
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )+
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"))

ggsave("./Results/gwr_coefficients_optimal_bandwidth_rn_17_map.png", width = 10, height = 8, dpi = 300)

# precip 2018
gwr_results_optimal_rn18 <- as.data.frame(gwr_model_opt_rn18$SDF)
coordinates_optimal_rn18 <- st_coordinates(st_centroid(fire_rn_18))
gwr_results_optimal_rn18 <- cbind(gwr_results_optimal_rn18, coordinates_optimal_rn18)
gwr_output_sf_optimal_rn18 <- st_as_sf(gwr_results_optimal_rn18, coords = c("X", "Y"), crs = st_crs(fire_rn_18))

# create graph
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = gwr_output_sf_optimal_rn18, aes(colour = Local_R2)) +
  scale_color_gradientn(colours = c("lightgreen", "turquoise", "cyan", "skyblue", "blue", "navy")) +
  labs(title = "GWR Coefficients with Optimal Bandwidth for Total Precipitation in BC (2018)",
       fill = "localR2",
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal()+ 
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )+
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"))

ggsave("./Results/gwr_coefficients_optimal_bandwidth_rn_18_map.png", width = 10, height = 8, dpi = 300)

# precip 2019
gwr_results_optimal_rn19 <- as.data.frame(gwr_model_opt_rn19$SDF)
coordinates_optimal_rn19 <- st_coordinates(st_centroid(fire_rn_19))
gwr_results_optimal_rn19 <- cbind(gwr_results_optimal_rn19, coordinates_optimal_rn19)
gwr_output_sf_optimal_rn19 <- st_as_sf(gwr_results_optimal_rn19, coords = c("X", "Y"), crs = st_crs(fire_rn_19))

ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = gwr_output_sf_optimal_rn19, aes(colour = Local_R2)) +
  scale_color_gradientn(colours = c("lightgreen", "turquoise", "cyan", "skyblue", "blue", "navy")) +
  labs(title = "GWR Coefficients with Optimal Bandwidth for Total Precipitation in BC (2019)",
       fill = "localR2",
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal()+ 
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )+
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"))

ggsave("./Results/gwr_coefficients_optimal_bandwidth_rn_19_map.png", width = 10, height = 8, dpi = 300)

# temp 2017
gwr_results_optimal_t17 <- as.data.frame(gwr_model_opt_t17$SDF)
coordinates_optimal_t17 <- st_coordinates(st_centroid(fire_t_17))
gwr_results_optimal_t17 <- cbind(gwr_results_optimal_t17, coordinates_optimal_t17)
gwr_output_sf_optimal_t17 <- st_as_sf(gwr_results_optimal_t17, coords = c("X", "Y"), crs = st_crs(fire_t_17))

ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = gwr_output_sf_optimal_t17, aes(colour = Local_R2)) +
  scale_color_gradientn(colours = c("yellow","gold", "orange", "darkorange", "red", "darkred")) + 
  labs(title = "GWR Results for Average Temperature in BC (2017) with Optimal Bandwidth",
       fill = "localR2",
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal()+ 
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )+
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"))

ggsave("./Results/gwr_coefficients_optimal_bandwidth_t_17_map.png", width = 10, height = 8, dpi = 300)

# temp 2018
gwr_results_optimal_t18 <- as.data.frame(gwr_model_opt_t18$SDF)
coordinates_optimal_t18 <- st_coordinates(st_centroid(fire_t_18))
gwr_results_optimal_t18 <- cbind(gwr_results_optimal_t18, coordinates_optimal_t18)
gwr_output_sf_optimal_t18 <- st_as_sf(gwr_results_optimal_t18, coords = c("X", "Y"), crs = st_crs(fire_t_18))

ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = gwr_output_sf_optimal_t18, aes(colour = Local_R2)) +
  scale_color_gradientn(colours = c("yellow","gold", "orange", "darkorange", "red", "darkred")) + 
  labs(title = "GWR Results for Average Temperature in BC (2018) with Optimal Bandwidth",
       fill = "local R2",  
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal()+
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )+
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"))
ggsave("./Results/gwr_coefficients_optimal_bandwidth_t_18_map.png", width = 10, height = 8, dpi = 300)

# temp 2019
gwr_results_optimal_t19 <- as.data.frame(gwr_model_opt_t19$SDF)
coordinates_optimal_t19 <- st_coordinates(st_centroid(fire_t_19))
gwr_results_optimal_t19 <- cbind(gwr_results_optimal_t19, coordinates_optimal_t19)
gwr_output_sf_optimal_t19 <- st_as_sf(gwr_results_optimal_t19, coords = c("X", "Y"), crs = st_crs(fire_t_19))

ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = gwr_output_sf_optimal_t19, aes(colour = Local_R2)) +
  scale_color_gradientn(colours = c("yellow","gold", "orange", "darkorange", "red", "darkred")) + 
  labs(title = "GWR Results for Average Temperature in BC (2019) with Optimal Bandwidth",
       fill = "localR2",
       x = "Longitude", 
       y = "Latitude") +
  theme_minimal()+ 
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )+
  annotation_scale(location = "bl", width_hint = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", height = unit(1, "cm"))

ggsave("./Results/gwr_coefficients_optimal_bandwidth_t_19_map.png", width = 10, height = 8, dpi = 300)

################################################## Linnear Regression Model
####### temperature 2017
# run model
model_t17 <- lm(sqrt(dependent_var17) ~ indep_var_t17)
summary(model_t17)

# checking that the mean of Errors is close to Zero
mean(residuals(model_t17))

# testing Homoscedasticity
bptest(model_t17) # Breusch-Pagan test

# testing normality
shapiro.test(residuals(model_t17))

# cehcking for spatial autocorrelation
durbinWatsonTest(model_t17)

# Create a data frame for plotting
data_t17 <- data.frame(temp = indep_var_t17, Fires = sqrt(dependent_var17))
data_t17$Fitted <- predict(model_t17) # Add predicted values

# Plot for 2017
plot_t17 <- ggplot(data_t17, aes(x = temp, y = Fires)) +
  geom_point(color = "blue") + # Scatter plot
  geom_line(aes(y = Fitted), color = "red") + # Fitted regression line
  ggtitle("Regression Plot of Average Temperature and Wildfires in BC (2017)") +
  xlab("Average Temperature (°C)") +
  ylab("Hectares Burned") +
  theme_minimal()

print(plot_t17)
ggsave("./Results/REG_Plot_t17.png", width = 10, height = 8, dpi = 300)

####### temperature 2018
model_t18 <- lm(log(dependent_var18) ~ indep_var_t18)
summary(model_t18)

# checking that the mean of Errors is close to Zero
mean(residuals(model_t18))

# testing Homoscedasticity
bptest(model_t18) # Breusch-Pagan test

# testing normality
shapiro.test(residuals(model_t18))

# cehcking for spatial autocorrelation
durbinWatsonTest(model_t18)

data_t18 <- data.frame(temp = indep_var_t18, Fires = log(dependent_var18))
data_t18$Fitted <- predict(model_t18)

plot_t18 <- ggplot(data_t18, aes(x = temp, y = Fires)) +
  geom_point(color = "blue") + # Scatter plot
  geom_line(aes(y = Fitted), color = "red") + # Fitted regression line
  ggtitle("Regression Plot of Average Temperature and Wildfires in BC (2018)") +
  xlab("Average Temperature (°C)") +
  ylab("Hectares Burned") +
  theme_minimal()

print(plot_t18)
ggsave("./Results/REG_Plot_t18.png", width = 10, height = 8, dpi = 300)

####### temperature 2019
model_t19 <- lm(log(dependent_var19) ~ indep_var_t19)
summary(model_t19)

# checking that the mean of Errors is close to Zero
mean(residuals(model_t19))

# testing Homoscedasticity
bptest(model_t19) # Breusch-Pagan test

# testing normality
shapiro.test(residuals(model_t19))

# cehcking for spatial autocorrelation
durbinWatsonTest(model_t19)

data_t19 <- data.frame(temp = indep_var_t19, Fires = log(dependent_var19))
data_t19$Fitted <- predict(model_t19)

plot_t19 <- ggplot(data_t19, aes(x = temp, y = Fires)) +
  geom_point(color = "blue") + # Scatter plot
  geom_line(aes(y = Fitted), color = "red") + # Fitted regression line
  ggtitle("Regression Plot of Average Temperature and Wildfires in BC (2019)") +
  xlab("Average Temperature (°C)") +
  ylab("Hectares Burned") +
  theme_minimal()

print(plot_t19)
ggsave("./Results/REG_Plot_t19.png", width = 10, height = 8, dpi = 300)

####### precipitation 2017
# run model
model_r17 <- lm(sqrt(dependent_var17) ~ indep_var_rn17)
summary(model_r17)

# checking that the mean of Errors is close to Zero
mean(residuals(model_r17))

# testing Homoscedasticity
bptest(model_r17) # Breusch-Pagan test

# testing normality
shapiro.test(residuals(model_r17))

# cehcking for spatial autocorrelation
durbinWatsonTest(model_r17)

# Create a data frame for plotting
data_r17 <- data.frame(temp = indep_var_rn17, Fires = sqrt(dependent_var17))
data_r17$Fitted <- predict(model_r17) # Add predicted values

# Plot for 2017
plot_r17 <- ggplot(data_r17, aes(x = temp, y = Fires)) +
  geom_point(color = "blue") + # Scatter plot
  geom_line(aes(y = Fitted), color = "red") + # Fitted regression line
  ggtitle("Regression Plot of Average Temperature and Wildfires in BC (2017)") +
  xlab("Average Temperature (°C)") +
  ylab("Hectares Burned") +
  theme_minimal()

print(plot_r17)
ggsave("./Results/REG_Plot_t17.png", width = 10, height = 8, dpi = 300)

####### precipitation 2018
model_r18 <- lm(sqrt(dependent_var18) ~ indep_var_rn18)
summary(model_r18)

# checking that the mean of Errors is close to Zero
mean(residuals(model_r18))

# testing Homoscedasticity
bptest(model_r18) # Breusch-Pagan test

# testing normality
shapiro.test(residuals(model_r18))

# cehcking for spatial autocorrelation
durbinWatsonTest(model_r18)

data_r18 <- data.frame(temp = indep_var_rn18, Fires = sqrt(dependent_var18))
data_r18$Fitted <- predict(model_r18)

plot_r18 <- ggplot(data_r18, aes(x = temp, y = Fires)) +
  geom_point(color = "blue") + # Scatter plot
  geom_line(aes(y = Fitted), color = "red") + # Fitted regression line
  ggtitle("Regression Plot of Average Temperature and Wildfires in BC (2018)") +
  xlab("Average Temperature (°C)") +
  ylab("Hectares Burned") +
  theme_minimal()

print(plot_r18)
ggsave("./Results/REG_Plot_t18.png", width = 10, height = 8, dpi = 300)

####### precipitation 2019
model_r19 <- lm(log(dependent_var19) ~ indep_var_rn19)
summary(model_r19)

# Checking that the mean of Errors is close to Zero
mean(residuals(model_r19))

# Testing Homoscedasticity
bptest(model_r19) # Breusch-Pagan test

# Testing normality
shapiro.test(residuals(model_r19))

# Checking for spatial autocorrelation
durbinWatsonTest(model_r19)

data_r19 <- data.frame(temp = indep_var_rn19, Fires = log(dependent_var19))
data_r19$Fitted <- predict(model_r19)

plot_r19 <- ggplot(data_r19, aes(x = temp, y = Fires)) +
  geom_point(color = "blue") + # Scatter plot
  geom_line(aes(y = Fitted), color = "red") + # Fitted regression line
  ggtitle("Regression Plot of Average Temperature and Wildfires in BC (2019)") +
  xlab("Average Temperature (°C)") +
  ylab("Hectares Burned") +
  theme_minimal()

print(plot_r19)
ggsave("./Results/REG_Plot_t19.png", width = 10, height = 8, dpi = 300)
