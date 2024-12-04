# Load necessary libraries
library(sf)       # For handling shapefiles
library(gstat)    # For geostatistical methods
library(ggplot2)  # For plotting
library(viridis)  # For color scales

###################################### 

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

######################################

# Create a grid for the interpolation
bbox <- st_bbox(rain_data_19)
grid <- st_make_grid(st_as_sfc(bbox), cellsize = c(15000, 15000)) 

# Interpolate using IDW
idw_result_rn <- gstat::idw(ttl_prc ~ 1, 
                         locations = rain_data_19, 
                         newdata = st_as_sf(grid), 
                         idp = 2)

# Extract coordinates 
idw_sf <- st_as_sf(idw_result_rn)

# Plot the results to view surface
ggplot(data = idw_sf) +
  geom_sf(aes(fill = var1.pred), color = NA) +  # Fill based on predicted values
  scale_fill_viridis_c(name = "Temperature", option = "C") +  # Viridis heatmap
  labs(
    title = "IDW Interpolation of rain",
    x = "Longitude",
    y = "Latitude"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    plot.title = element_text(hjust = 0.5, size = 14),
    axis.title = element_text(size = 12)
  )

# Save the result to a shapefile if needed
st_write(idw_sf, "./Results/IDW_Result_rain_15km_2019.shp", driver = "ESRI Shapefile", delete_dsn = TRUE)

######################################### Clipping IDW to bc_border
# Load shapefiles
BC_polygon <- st_read("./Cleaned_data/BC_Boundary.shp")

IDW_rain_data_17 <- st_read("./Results/IDW_Result_rain_15km_2017.shp")
IDW_temp_data_17 <- st_read("./Results/IDW_Result_temp_15km_2017.shp")

IDW_rain_data_18 <- st_read("./Results/IDW_Result_rain_15km_2018.shp")
IDW_temp_data_18 <- st_read("./Results/IDW_Result_temp_15km_2018.shp")

IDW_rain_data_19 <- st_read("./Results/IDW_Result_rain_15km_2019.shp")
IDW_temp_data_19 <- st_read("./Results/IDW_Result_temp_15km_2019.shp")

# Check the CRS of both objects
crs_idw <- st_crs(IDW_temp_data_19)  
crs_polygon <- st_crs(BC_polygon) 

print(crs_idw)
print(crs_polygon)

# Step to transform the CRS of either shapefile if they do not match
if (crs_idw != crs_polygon) {
  IDW_temp_data_19 <- st_transform(IDW_temp_data_19, crs = crs_polygon)  # Transform IDW result to polygon's CRS
  message("Transformed IDW result CRS to match the polygon.")
} else {
  message("CRS of IDW result and polygon already match.")
}

# Now attempt the intersection again
idw_clipped <- st_intersection(IDW_temp_data_17, BC_polygon)

# Create the map of the clipped results
ggplot(data = idw_clipped) +
  geom_sf(aes(fill = var1_pred), color = NA) +  
  scale_fill_viridis_c(option = "C") +  
  labs(
    title = "IDW Interpolation of average Temperature in BC (2017)",
    fill = "Temperature (°C)",  
    x = "Longitude", 
    y = "Latitude"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = NA), 
    plot.background = element_rect(fill = "white", color = NA)   
  )

# Save the map as an image file
ggsave("./Results/Clipped_IDW_Interpolation_2017_temp_Map.png", width = 10, height = 8, dpi = 300)


#Temperature (°C)
