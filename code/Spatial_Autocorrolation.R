library("knitr")
library("tmap")
library("spdep")
library("e1071")
library("sf")
library("st")
library("ggplot2")

# Set working directory
dir <- "~/Downloads/classes/2024/Fall/GEOG 418/Final Project"
setwd(dir)

# Read the climate shapefiles
rain_data_17 <- st_read("./Cleaned_data/ClimateData_precip_2017.shp")
temp_data_17 <- st_read("./Cleaned_data/ClimateData_temp_2017.shp")

rain_data_18 <- st_read("./Cleaned_data/ClimateData_precip_2018.shp")
temp_data_18 <- st_read("./Cleaned_data/ClimateData_temp_2018.shp")

rain_data_19 <- st_read("./Cleaned_data/ClimateData_precip_2019.shp")
temp_data_19 <- st_read("./Cleaned_data/ClimateData_temp_2019.shp")

############################################## 2017

# Calculate statistics for total_rain in 2017
mean_rain_19 <- mean(rain_data_19$ttl_prc, na.rm = TRUE)   
sd_rain_19 <- sd(rain_data_19$ttl_prc, na.rm = TRUE)       
skew_rain_19 <- skewness(rain_data_19$ttl_prc, na.rm = TRUE)

# Calculate statistics for avg temp in 2017
mean_temp_19 <- mean(temp_data_19$TEMP, na.rm = TRUE)
sd_temp_19 <- sd(temp_data_19$TEMP, na.rm = TRUE)
skew_temp_19 <- skewness(temp_data_19$TEMP, na.rm = TRUE)

# Create dataframe for display in table
data <- data.frame(Variable = c("Maximum Temperature", "Total Precipitation"),
                   Mean = c(round(mean_temp_19,2), round(mean_rain_19,2)),
                   StandardDeviation = c(round(sd_temp_19,2), round(sd_rain_19,2)),
                   Skewness = c(round(skew_temp_19,2), round(skew_rain_19,2)))

# Produce table
kable(data, caption = paste0("Descriptive statistics for BC's Climate in 2019"))

################################################## Histogram
# Total rain in 2017 in bc
ggplot(rain_data_17, aes(x = ttl_prc)) +
  geom_histogram(binwidth = 10, fill = "darkblue", color = "darkblue", alpha = 1) +
  stat_function(fun = dnorm, args = list(mean = mean(rain_data_17$ttl_prc, na.rm = TRUE), 
                                         sd = sd(rain_data_17$ttl_prc, na.rm = TRUE)), 
                color = "red", size = 0.5) +
  labs(title = "Distribution of Total Precipitation in BC (2017)", 
       x = "Total Precipitation (mm)", 
       y = "Frequency") +
  theme_minimal()

# Total rain in 2018 in bc
ggplot(rain_data_18, aes(x = ttl_prc)) +
  geom_histogram(binwidth = 10, fill = "darkblue", color = "darkblue", alpha = 1) +
  stat_function(fun = dnorm, args = list(mean = mean(rain_data_18$ttl_prc, na.rm = TRUE), 
                                         sd = sd(rain_data_18$ttl_prc, na.rm = TRUE)), 
                color = "red", size = 0.5) +
  labs(title = "Distribution of Total Precipitation in BC (2017)", 
       x = "Total Precipitation (mm)", 
       y = "Frequency") +
  theme_minimal()

# Avg temp in 2017 in bc
ggplot(temp_data_17, aes(x = TEMP)) +
  geom_histogram(bins = 15, fill = "red", color = "darkred", alpha = 0.5) +
  stat_function(fun = dnorm, args = list(mean = mean(temp_data_17$TEMP, na.rm = TRUE), 
                                         sd = sd(temp_data_17$TEMP, na.rm = TRUE)), 
                color = "red", size = 0.5) +
  labs(title = "Distribution of Average Temperatures in BC (2017)", 
       x = "Average Temperatures (C)", 
       y = "Frequency") +
  theme_minimal()

# Avg temo in 2018 in bc
ggplot(temp_data_18, aes(x = TEMP)) +
  geom_histogram(bins = 15, fill = "red", color = "darkred", alpha = 0.5) +
  stat_function(fun = dnorm, args = list(mean = mean(temp_data_18$TEMP, na.rm = TRUE), 
                                         sd = sd(temp_data_18$TEMP, na.rm = TRUE)), 
                color = "red", size = 0.5) +
  labs(title = "Distribution of Average Temperatures in BC (2017)", 
       x = "Average Temperatures (C)", 
       y = "Frequency") +
  theme_minimal()

# Avg temp in 2019 in bc
ggplot(rain_data_19, aes(x = ttl_prc)) +
  geom_histogram(bins = 15, fill = "blue", color = "darkblue", alpha = 0.5) +
  stat_function(fun = dnorm, args = list(mean = mean(rain_data_19$ttl_prc, na.rm = TRUE), 
                                         sd = sd(rain_data_19$ttl_prc, na.rm = TRUE)), 
                color = "red", size = 0.5) +
  labs(title = "Distribution of Total Precipitation in BC (2019)", 
       x = "Average Temperatures (C)", 
       y = "Frequency") +
  theme_minimal()

# Avg temo in 2019 in bc
ggplot(temp_data_19, aes(x = TEMP)) +
  geom_histogram(bins = 15, fill = "red", color = "darkred", alpha = 0.5) +
  stat_function(fun = dnorm, args = list(mean = mean(temp_data_19$TEMP, na.rm = TRUE), 
                                         sd = sd(temp_data_19$TEMP, na.rm = TRUE)), 
                color = "red", size = 0.5) +
  labs(title = "Distribution of Average Temperatures in BC (2017)", 
       x = "Average Temperatures (C)", 
       y = "Frequency") +
  theme_minimal()


################################################## Calculating Global Moran's I
### Creating Weighting Matrix Precip 2017 ###
coords_rain_17 <- st_coordinates(rain_data_17)
nb_rain_17 <- dnearneigh(coords_rain_17, d1 = 500, d2 = 200000) 
weights_rain_17 <- nb2listw(nb_rain_17, style = "W")

# Maran's I
moran_result_precip17 <- moran.test(rain_data_17$ttl_prc, weights_rain_17)

# Extract Global Moran's I results
stats_precip_17 <- moran_result_precip17$estimate[[1]]
Expect_precip_17 <- moran_result_precip17$estimate[[2]]
varinace_precip_17 <- moran_result_precip17$estimate[[3]]

### Creating Weighting Matrix Temp 2017 ###
coords_temp_17 <- st_coordinates(temp_data_17)
nb_temp_17 <- dnearneigh(coords_temp_17, d1 = 500, d2 = 200000) 
weights_temp_17 <- nb2listw(nb_temp_17, style = "W")

# Maran's I
moran_result_temp_17 <- moran.test(temp_data_17$TEMP, weights_temp_17)

# Extract Global Moran's I results
stats_temp_17 <- moran_result_temp_17$estimate[[1]]
Expect_temp_17 <- moran_result_temp_17$estimate[[2]]
varinace_temp_17 <- moran_result_temp_17$estimate[[3]]

### Creating Weighting Matrix Precip 2018 ###
coords_rain_18 <- st_coordinates(rain_data_18)
nb_rain_18 <- dnearneigh(coords_rain_18, d1 = 500, d2 = 200000) 
weights_rain_18 <- nb2listw(nb_rain_18, style = "W")

# Maran's I
moran_result_precip18 <- moran.test(rain_data_18$ttl_prc, weights_rain_18)

# Extract Global Moran's I results
stats_precip_18 <- moran_result_precip18$estimate[[1]]
Expect_precip_18 <- moran_result_precip18$estimate[[2]]
varinace_precip_18 <- moran_result_precip18$estimate[[3]]

### Creating Weighting Matrix Temp 2018 ###
coords_temp_18 <- st_coordinates(temp_data_18)
nb_temp_18 <- dnearneigh(coords_temp_18, d1 = 500, d2 = 200000) 
weights_temp_18 <- nb2listw(nb_temp_18, style = "W")

# Maran's I
moran_result_temp_18 <- moran.test(temp_data_18$TEMP, weights_temp_18)

# Extract Global Moran's I results
stats_temp_18 <- moran_result_temp_18$estimate[[1]]
Expect_temp_18 <- moran_result_temp_18$estimate[[2]]
varinace_temp_18 <- moran_result_temp_18$estimate[[3]]

### Creating Weighting Matrix Precip 2019 ###
coords_rain_19 <- st_coordinates(rain_data_19)
nb_rain_19 <- dnearneigh(coords_rain_19, d1 = 500, d2 = 200000) 
weights_rain_19 <- nb2listw(nb_rain_19, style = "W")

# Maran's I
moran_result_precip19 <- moran.test(rain_data_19$ttl_prc, weights_rain_19)

# Extract Global Moran's I results
stats_precip_19 <- moran_result_precip19$estimate[[1]]
Expect_precip_19 <- moran_result_precip19$estimate[[2]]
varinace_precip_19 <- moran_result_precip19$estimate[[3]]

### Creating Weighting Matrix Temp 2018 ###
coords_temp_19 <- st_coordinates(temp_data_19)
nb_temp_19 <- dnearneigh(coords_temp_19, d1 = 500, d2 = 200000) 
weights_temp_19 <- nb2listw(nb_temp_19, style = "W")

# Maran's I
moran_result_temp_19 <- moran.test(temp_data_19$TEMP, weights_temp_19)

# Extract Global Moran's I results
stats_temp_19 <- moran_result_temp_19$estimate[[1]]
Expect_temp_19 <- moran_result_temp_19$estimate[[2]]
varinace_temp_19 <- moran_result_temp_19$estimate[[3]]

################################################## Calucate Range
# Function to calculate the range of global Moran's I
moran.range <- function(lw) {
  wmat <- listw2mat(lw)
  return(range(eigen((wmat + t(wmat))/2)$values))
}

# Calculate the range for the precip in 2017
range_precip17 <- moran.range(weights_rain_17)
minRange_rn17 <- range_precip17[1]
maxRange_rn17 <- range_precip17[2]
range_precip17 <- paste(round(minRange_rn17, 4), "-", round(maxRange_rn17, 4))

# Calculate the range for the precip in 2018
range_precip18 <- moran.range(weights_rain_18)
minRange_rn18 <- range_precip18[1]
maxRange_rn18 <- range_precip18[2]
range_precip18 <- paste(round(minRange_rn18, 4), "-", round(maxRange_rn18, 4))

# Calculate the range for the precip in 2019
range_precip19 <- moran.range(weights_rain_19)
minRange_rn19 <- range_precip19[1]
maxRange_rn19 <- range_precip19[2]
range_precip19 <- paste(round(minRange_rn19, 4), "-", round(maxRange_rn19, 4))


# Calculate the range for the temp in 2017
range_temp17 <- moran.range(weights_temp_17)
minRange_t17 <- range_temp17[1]
maxRange_t17 <- range_temp17[2]
range_temp17 <- paste(round(minRange_t17, 4), "-", round(maxRange_t17, 4))

# Calculate the range for the temp in 2018
range_temp18 <- moran.range(weights_temp_18)
minRange_t18 <- range_temp18[1]
maxRange_t18 <- range_temp18[2]
range_temp18 <- paste(round(minRange_t18, 4), "-", round(maxRange_t18, 4))

# Calculate the range for the temp in 2018
range_temp19 <- moran.range(weights_temp_19)
minRange_t19 <- range_temp19[1]
maxRange_t19 <- range_temp19[2]
range_temp19 <- paste(round(minRange_t19, 4), "-", round(maxRange_t19, 4))

################################################## Compute Z-test
z_precip17 <- (stats_precip_17 - Expect_precip_17) / (sqrt(varinace_precip_17))
z_precip18 <- (stats_precip_18 - Expect_precip_18) / (sqrt(varinace_precip_18))
z_precip19 <- (stats_precip_19 - Expect_precip_19) / (sqrt(varinace_precip_19))

z_temp17 <- (stats_temp_17 - Expect_temp_17) / (sqrt(varinace_temp_17))
z_temp18 <- (stats_temp_18 - Expect_temp_18) / (sqrt(varinace_temp_18))
z_temp19 <- (stats_temp_19 - Expect_temp_19) / (sqrt(varinace_temp_19))

################################################## Show Results
# Round the numeric values to 4 decimal places
# Create dataframe for table
moran_results <- data.frame(
  Statistic = c("Global Moran's I", "Expected Moran's I", "Variance", "Range", "P-Value", "Z-Score"),
  Precipitation_2017 = c(round(stats_precip_17, 4), round(Expect_precip_17, 4), round(varinace_precip_17, 4), range_precip17, "p < 0.001", round(z_precip17, 4)),
  Temperature_2017 = c(round(stats_temp_17, 4), round(Expect_temp_17, 4), round(varinace_temp_17, 4), range_temp17, "p < 0.001", round(z_temp17, 4)),
  Precipitation_2018 = c(round(stats_precip_18, 4), round(Expect_precip_18, 4), round(varinace_precip_18, 4), range_precip18, "p < 0.001", round(z_precip18, 4)),
  Temperature_2018 = c(round(stats_temp_18, 4), round(Expect_temp_18, 4), round(varinace_temp_18, 4), range_temp18, "p < 0.001", round(z_temp18, 4))
)
moran_results9 <- data.frame(
  Statistic = c("Global Moran's I", "Expected Moran's I", "Variance", "Range", "P-Value", "Z-Score"),
  Precipitation_2019 = c(round(stats_precip_19, 4), round(Expect_precip_19, 4), round(varinace_precip_19, 4), range_precip19, "p < 0.001", round(z_precip19, 4)),
  Temperature_2019 = c(round(stats_temp_19, 4), round(Expect_temp_19, 4), round(varinace_temp_19, 4), range_temp19, "p < 0.001", round(z_temp19, 4)),
  Precipitation_2018 = c(round(stats_precip_18, 4), round(Expect_precip_18, 4), round(varinace_precip_18, 4), range_precip18, "p < 0.001", round(z_precip18, 4)),
  Temperature_2018 = c(round(stats_temp_18, 4), round(Expect_temp_18, 4), round(varinace_temp_18, 4), range_temp18, "p < 0.001", round(z_temp18, 4))
)
kable(moran_results9, align = "c" ,caption = "Global Moran's I Results for Tatol Precipitation and Average Temperature in BC (2018 and 2019)")

moran_results_19_18 <- data.frame(
  Statistic = c("Precipitation in 2019", "Temperature in 2019", "Precipitation in 2018", "Temperature 2018"),
  Global_Morans_I = c(round(stats_precip_19, 4),  round(stats_temp_19, 4), round(stats_precip_18, 4), round(stats_temp_18, 4)),
  Expected_Morans_I = c(round(Expect_precip_19, 4), round(Expect_temp_19, 4), round(Expect_precip_18, 4), round(Expect_temp_18, 4)),
  Variance = c(round(varinace_precip_19, 4), round(varinace_temp_19, 4), round(varinace_precip_18, 4), round(varinace_temp_18, 4)),
  Range = c(range_precip19, range_temp19, range_precip18, range_temp18),
  p_value = c("p < 0.001",  "p < 0.001",  "p < 0.001",  "p < 0.001"),
  Z_Score = c(round(z_precip19, 4), round(z_temp19, 4), round(z_precip18, 4),  round(z_temp18, 4))
)


# Display the table
kable(moran_results, align = "c" ,caption = "Global Moran's I Results for Tatol Precipitation and Average Temperature in BC (2017 and 2018)")

# Display the table
kable(moran_results_19_18, align = "c" ,caption = "Global Moran's I Results for Tatol Precipitation and Average Temperature in BC (2017 and 2018)")
