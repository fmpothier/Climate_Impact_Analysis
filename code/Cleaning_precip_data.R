library(tmap)
library(spdep)
library(raster)
library(sf)
library(lubridate)
library(dplyr)
library(gstat)
library(ggplot2)
library(maps)

# Set working directory
dir <- "~/Downloads/classes/2024/Fall/GEOG 418/Final Project"
setwd(dir)

#######

## CSV file for temp data
empty_data <- data.frame(Native.ID = character(), total_precip = numeric(), avg_precip = numeric(),
                         Longitude = numeric(), Latitude = numeric(), stringsAsFactors = FALSE)

csv_file_name <- "BC_ENV_ASP_PRECIP_2019.csv"

# Precip
write.csv(empty_data, file = csv_file_name, row.names = FALSE)

########
# List all CSV files in the directory
csv_files <- list.files(path = "./frankiedata/pcds_data_precip_19/ENV-ASP", pattern = "\\.csv$", full.names = TRUE)

# Loop through each CSV file
for (file in csv_files) {
  # Read each CSV file
  daily_data <- read.csv(file, skip = 1, header = TRUE)
  file_name <- file
  
  # Trim any leading or trailing whitespace
  daily_data$time <- trimws(daily_data$time)
  daily_data$ONE_DAY_PRECIPITATION <- trimws(daily_data$ONE_DAY_PRECIPITATION)
  
  # Convert the 'time' column to date
  daily_data$time <- lubridate::ymd_hms(daily_data$time)  
  
  # Filter data by year 
  daily_data <- daily_data %>%
    filter(lubridate::year(time) == 2019)
  
  # Remove NA values
  daily_data <- daily_data %>%
    filter(!is.na(time)) 
  
  # Convert MAX_TEMP to numeric and remove rows with NA values
  daily_data$ONE_DAY_PRECIPITATION <- as.numeric(daily_data$ONE_DAY_PRECIPITATION)
  daily_data <- daily_data %>%
    filter(!is.na(ONE_DAY_PRECIPITATION))
  
  # ######### if data is in hourly un-comment below code
  # 
  # # Aggregate hourly data into daily totals
  # daily_data <- daily_data %>%
  #   mutate(date = as.Date(time)) %>%  # Extract the date from the timestamp
  #   group_by(date) %>%
  #   summarize(daily_precip_total = sum(precipitation, na.rm = TRUE), .groups = "drop")
  # 
  # # Calculate monthly average daily rainfall
  # monthly_avg_rainfall <- daily_data %>%
  #   mutate(year = lubridate::year(date), month = lubridate::month(date)) %>%
  #   group_by(year, month) %>%
  #   summarize(monthly_avg_rainfall = mean(daily_precip_total, na.rm = TRUE), .groups = "drop")
  # 
  # # Calculate total monthly rainfall
  # monthly_total_rainfall <- daily_data %>%
  #   mutate(year = lubridate::year(date), month = lubridate::month(date)) %>%
  #   group_by(year, month) %>%
  #   summarize(monthly_total_rainfall = sum(daily_precip_total, na.rm = TRUE), .groups = "drop")
  # 
  # # Filter for the months from May to October and calculate the average daily rainfall
  # average_rainfall_may_october <- daily_data %>%
  #   filter(lubridate::month(date) >= 5 & lubridate::month(date) <= 10) %>%
  #   summarize(avg_precip = mean(daily_precip_total, na.rm = TRUE))
  # 
  # # Filter for the months from May to October and calculate the total rainfall
  # total_rainfall_may_october <- daily_data %>%
  #   filter(lubridate::month(date) >= 5 & lubridate::month(date) <= 10) %>%
  #   summarize(total_precip = sum(daily_precip_total, na.rm = TRUE))

  ######## if data is in daily un-comment below code
  
  # Calculate monthly average temperature from daily data
  monthly_avg_rainfall <- daily_data %>%
    group_by(year = lubridate::year(time), month = lubridate::month(time)) %>%
    summarize(monthly_avg_rainfall = mean(ONE_DAY_PRECIPITATION, na.rm = TRUE)) %>%
    ungroup()

  # Calculate total monthly rainfall from daily data
  monthly_total_rainfall <- daily_data %>%
    group_by(year = lubridate::year(time), month = lubridate::month(time)) %>%
    summarize(monthly_total_rainfall = sum(ONE_DAY_PRECIPITATION, na.rm = TRUE)) %>%
    ungroup()

  # Filter for the months from May to October and calculate the average rainfall
  average_rainfall_may_october <- daily_data %>%
    filter(lubridate::month(time) >= 5 & lubridate::month(time) <= 10) %>%
    summarize(avg_precip = mean(ONE_DAY_PRECIPITATION, na.rm = TRUE))

  # Filter for the months from May to October and calculate the total rainfall
  total_rainfall_may_october <- daily_data %>%
    filter(lubridate::month(time) >= 5 & lubridate::month(time) <= 10) %>%
    summarize(total_precip = sum(ONE_DAY_PRECIPITATION, na.rm = TRUE))

  ############
  
  # Assigning the filename to an object
  file_name <- basename(file_name)
  
  # Remove the file extension
  file_name_no_ext <- sub("\\.[^.]*$", "", file_name)
  
  # Read the existing CSV file
  file_path <- csv_file_name
  data <- read.csv(file_path)
  
  # Round decimals
  Rounded_rainfall_avg <- round(average_rainfall_may_october,2)
  Rounded_rainfall_total <- round(total_rainfall_may_october,2)
  
  # Convert the weather station ID column to character
  data$Native.ID <- as.character(data$Native.ID)
  
  # Append new rows
  new_values <- data.frame(Native.ID = file_name_no_ext,
                           avg_precip = Rounded_rainfall_avg,
                           total_precip = Rounded_rainfall_total,
                           stringsAsFactors = FALSE)
  
  data <- bind_rows(data, new_values)
  
  # Save the updated data frame back to a new CSV file
  output_file_path <- csv_file_name
  write.csv(data, file = output_file_path, row.names = FALSE)
}

###################
# Merge the climate data for each station with the location data found in the metadata file
metadata <- read.csv("./frankiedata/station-metadata-by-history19.csv")
climatedata <- read.csv("BC_ENV_ASP_PRECIP_2019.csv")
merged_data <- merge(metadata, climatedata, by = "Native.ID")

# Remove the last two columns which are duplicate Latitude and Longitude
merged_data <- merged_data[, -((ncol(merged_data)-1):ncol(merged_data))]

# Change column names for Latitude and Longitude to remove the x
colnames(merged_data)[colnames(merged_data) %in% c("Latitude.x", "Longitude.x")] <- c("Longitude", "Latitude")

# Omit NA's
merged_data <- na.omit(merged_data)

# Filter data to remove these
merged_data <- merged_data[merged_data$total_precip > 0 & merged_data$total_precip < 3000, ]
merged_data <- merged_data[merged_data$avg_precip <= 100, ]

# File name for the output
output_file <- "./Cleaned_data/ClimateData_precipitation_2019.csv"

# Check if the file already exists
if (file.exists(output_file)) {
  # Append data to the file
  write.table(merged_data, file = output_file, row.names = FALSE, col.names = FALSE, sep = ",", append = TRUE)
} else {
  # Write data to a new file
  write.table(merged_data, file = output_file, row.names = FALSE, col.names = TRUE, sep = ",", append = FALSE)
}




