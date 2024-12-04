
library("raster")
library("spatstat")
library("tmap")
library("knitr")
library("sf")
library("ggplot2")
library("raster")
library("spatstat")
library("sp")
library("tmap")
library("plyr")
library("dplyr")
library("st")
library("ggspatial")

# Set working directory
dir <- "~/Downloads/classes/2024/Fall/GEOG 418/Final Project"
setwd(dir)

# Read the climate shapefiles
BC <- st_read("./Cleaned_data/BC_Boundary.shp")
rain_data_17 <- st_read("./Cleaned_data/ClimateData_precip_2017.shp")
temp_data_17 <- st_read("./Cleaned_data/ClimateData_temp_2017.shp")
rain_data_18 <- st_read("./Cleaned_data/ClimateData_precip_2018.shp")
temp_data_18 <- st_read("./Cleaned_data/ClimateData_temp_2018.shp")
rain_data_19 <- st_read("./Cleaned_data/ClimateData_precip_2019.shp")
temp_data_19 <- st_read("./Cleaned_data/ClimateData_temp_2019.shp")


################################################## Prepare Data
# Intersect Datasets 
bc_rain_17 <- st_intersection(rain_data_17, BC)
bc_rain_18 <- st_intersection(rain_data_18, BC)
bc_rain_19 <- st_intersection(rain_data_19, BC)

bc_temp_17 <- st_intersection(temp_data_17, BC)
bc_temp_18 <- st_intersection(temp_data_18, BC)
bc_temp_19 <- st_intersection(temp_data_19, BC)

# Remove duplicate points
bc_rain_17 <- st_difference(bc_rain_17)
bc_rain_18 <- st_difference(bc_rain_18)
bc_rain_19 <- st_difference(bc_rain_19)

bc_temp_17 <- st_difference(bc_temp_17)
bc_temp_18 <- st_difference(bc_temp_18)
bc_temp_19 <- st_difference(bc_temp_19)

### Create ppp objects ###
# Create an "extent" objecst 
bc_rain_17_ext <- as.matrix(st_bbox(bc_rain_17))
bc_rain_18_ext <- as.matrix(st_bbox(bc_rain_18))
bc_rain_19_ext <- as.matrix(st_bbox(bc_rain_19))

bc_temp_17_ext <- as.matrix(st_bbox(bc_temp_17))
bc_temp_18_ext <- as.matrix(st_bbox(bc_temp_18))
bc_temp_19_ext <- as.matrix(st_bbox(bc_temp_19))

# Create observation windows 
window_rn17 <- as.owin(list(xrange = c(bc_rain_17_ext[1], bc_rain_17_ext[3]), 
                        yrange = c(bc_rain_17_ext[2], bc_rain_17_ext[4])))

window_rn18 <- as.owin(list(xrange = c(bc_rain_18_ext[1], bc_rain_18_ext[3]), 
                            yrange = c(bc_rain_18_ext[2], bc_rain_18_ext[4])))

window_rn19 <- as.owin(list(xrange = c(bc_rain_19_ext[1], bc_rain_19_ext[3]), 
                            yrange = c(bc_rain_19_ext[2], bc_rain_19_ext[4])))


window_t17 <- as.owin(list(xrange = c(bc_temp_17_ext[1], bc_temp_17_ext[3]), 
                            yrange = c(bc_temp_17_ext[2], bc_temp_17_ext[4])))

window_t18 <- as.owin(list(xrange = c(bc_temp_18_ext[1], bc_temp_18_ext[3]), 
                            yrange = c(bc_temp_18_ext[2], bc_temp_18_ext[4])))

window_t19 <- as.owin(list(xrange = c(bc_temp_19_ext[1], bc_temp_19_ext[3]), 
                           yrange = c(bc_temp_19_ext[2], bc_temp_19_ext[4])))

# Get Coordinates and Create ppp objects 
coords_rn17 <- st_coordinates(bc_rain_17)
coords_rn18 <- st_coordinates(bc_rain_18)
coords_rn19 <- st_coordinates(bc_rain_19)

coords_t17 <- st_coordinates(bc_temp_17)
coords_t18 <- st_coordinates(bc_temp_18)
coords_t19 <- st_coordinates(bc_temp_19)

precip17.ppp <- ppp(x = coords_rn17[,1], y = coords_rn17[,2], window = window_rn17)
precip18.ppp <- ppp(x = coords_rn18[,1], y = coords_rn18[,2], window = window_rn18)
precip19.ppp <- ppp(x = coords_rn19[,1], y = coords_rn19[,2], window = window_rn19)

temp17.ppp <- ppp(x = coords_t17[,1], y = coords_t17[,2], window = window_t17)
temp18.ppp <- ppp(x = coords_t18[,1], y = coords_t18[,2], window = window_t18)
temp19.ppp <- ppp(x = coords_t19[,1], y = coords_t19[,2], window = window_t19)


################################################## Nearest Neighbour Analysis  
# Conduct Nearest Neighbour Analysis
nearestNeighbour_rn17 <- nndist(precip17.ppp)
nearestNeighbour_rn18 <- nndist(precip18.ppp)
nearestNeighbour_rn19 <- nndist(precip19.ppp)

nearestNeighbour_t17 <- nndist(temp17.ppp)
nearestNeighbour_t18 <- nndist(temp18.ppp)
nearestNeighbour_t19 <- nndist(temp19.ppp)

nearestNeighbour_rn17 = as.data.frame(as.numeric(nearestNeighbour_rn17))
nearestNeighbour_rn18 = as.data.frame(as.numeric(nearestNeighbour_rn18))
nearestNeighbour_rn19 = as.data.frame(as.numeric(nearestNeighbour_rn19))

nearestNeighbour_t17 = as.data.frame(as.numeric(nearestNeighbour_t17))
nearestNeighbour_t18 = as.data.frame(as.numeric(nearestNeighbour_t18))
nearestNeighbour_t19 = as.data.frame(as.numeric(nearestNeighbour_t19))

# Change column name to "Distance"
colnames(nearestNeighbour_rn17) = "Distance"
colnames(nearestNeighbour_rn18) = "Distance"
colnames(nearestNeighbour_rn19) = "Distance"

colnames(nearestNeighbour_t17) = "Distance"
colnames(nearestNeighbour_t18) = "Distance"
colnames(nearestNeighbour_t19) = "Distance"

# Add NND Distance data 
bc_rain_17$NND <- nearestNeighbour_rn17$Distance
bc_rain_18$NND <- nearestNeighbour_rn18$Distance
bc_rain_19$NND <- nearestNeighbour_rn19$Distance

bc_temp_17$NND <- nearestNeighbour_t17$Distance
bc_temp_18$NND <- nearestNeighbour_t18$Distance
bc_temp_19$NND <- nearestNeighbour_t19$Distance

### Calculate the nearest neighbor statistic to test for a random spatial distribution.
# Calculate the mean nearest neighbor
nnd_rn17 = sum(nearestNeighbour_rn17$Distance)/nrow(nearestNeighbour_rn17)
nnd_rn18 = sum(nearestNeighbour_rn18$Distance)/nrow(nearestNeighbour_rn18)
nnd_rn19 = sum(nearestNeighbour_rn19$Distance)/nrow(nearestNeighbour_rn19)

nnd_t17 = sum(nearestNeighbour_t17$Distance)/nrow(nearestNeighbour_t17)
nnd_t18 = sum(nearestNeighbour_t18$Distance)/nrow(nearestNeighbour_t18)
nnd_t19 = sum(nearestNeighbour_t19$Distance)/nrow(nearestNeighbour_t19)

# Calculate the mean, standard deviation, and Z-score 
studyArea <- area(BC)

# Precipitation 2017
pointDensity_rn17 <- nrow(nearestNeighbour_rn17) / studyArea
r_nnd_rn17 = 1 / (2 * sqrt(pointDensity_rn17))
d_nnd_rn17 = 1.07453 / sqrt(pointDensity_rn17)
R_rn17 = nnd_rn17 / r_nnd_rn17
sd_nnd_rn17 <- .26136 / sqrt(nrow(nearestNeighbour_rn17) * pointDensity_rn17)
z_rn17 <- (nnd_rn17 - r_nnd_rn17) / sd_nnd_rn17
p_value_rn17 <- 2 * (1 - pnorm(abs(z_rn17)))

# Precipitation 2018
pointDensity_rn18 <- nrow(nearestNeighbour_rn18) / studyArea
r_nnd_rn18 = 1 / (2 * sqrt(pointDensity_rn18))
d_nnd_rn18 = 1.07453 / sqrt(pointDensity_rn18)
R_rn18 = nnd_rn18 / r_nnd_rn18
sd_nnd_rn18 <- .26136 / sqrt(nrow(nearestNeighbour_rn18) * pointDensity_rn18)
z_rn18 <- (nnd_rn18 - r_nnd_rn18) / sd_nnd_rn18
p_value_rn18 <- 2 * (1 - pnorm(abs(z_rn18)))

# Precipitation 2019
pointDensity_rn19 <- nrow(nearestNeighbour_rn19) / studyArea
r_nnd_rn19 = 1 / (2 * sqrt(pointDensity_rn19))
d_nnd_rn19 = 1.07453 / sqrt(pointDensity_rn19)
R_rn19 = nnd_rn19 / r_nnd_rn19
sd_nnd_rn19 <- .26136 / sqrt(nrow(nearestNeighbour_rn19) * pointDensity_rn19)
z_rn19 <- (nnd_rn19 - r_nnd_rn19) / sd_nnd_rn19
p_value_rn19 <- 2 * (1 - pnorm(abs(z_rn19)))

# Temperature 2017
pointDensity_t17 <- nrow(nearestNeighbour_t17) / studyArea
r_nnd_t17 = 1 / (2 * sqrt(pointDensity_t17))
d_nnd_t17 = 1.07453 / sqrt(pointDensity_t17)
R_t17 = nnd_t17 / r_nnd_t17
sd_nnd_t17 <- .26136 / sqrt(nrow(nearestNeighbour_t17) * pointDensity_t17)
z_t17 <- (nnd_t17 - r_nnd_t17) / sd_nnd_t17
p_value_t17 <- 2 * (1 - pnorm(abs(z_t17)))

# Temperature 2018
pointDensity_t18 <- nrow(nearestNeighbour_t18) / studyArea
r_nnd_t18 = 1 / (2 * sqrt(pointDensity_t18))
d_nnd_t18 = 1.07453 / sqrt(pointDensity_t18)
R_t18 = nnd_t18 / r_nnd_t18
sd_nnd_t18 <- .26136 / sqrt(nrow(nearestNeighbour_t18) * pointDensity_t18)
z_t18 <- (nnd_t18 - r_nnd_t18) / sd_nnd_t18
p_value_t18 <- 2 * (1 - pnorm(abs(z_t18)))

# Temperature 2019
pointDensity_t19 <- nrow(nearestNeighbour_t19) / studyArea
r_nnd_t19 = 1 / (2 * sqrt(pointDensity_t19))
d_nnd_t19 = 1.07453 / sqrt(pointDensity_t19)
R_t19 = nnd_t19 / r_nnd_t19
sd_nnd_t19 <- .26136 / sqrt(nrow(nearestNeighbour_t19) * pointDensity_t19)
z_t19 <- (nnd_t19 - r_nnd_t19) / sd_nnd_t19
p_value_t19 <- 2 * (1 - pnorm(abs(z_t19)))

#Create a Table for results
nndResults <- data.frame(
  . = c("Precipitation in 2017", "Temperature in 2017", "Precipitation in 2018", "Temperature in 2018" ),
  Random_NND = c(round(r_nnd_rn17, 4), round(r_nnd_t17, 4), round(r_nnd_rn18, 4), round(r_nnd_t18, 4)),
  Disperse_NND = c(round(d_nnd_rn17, 4),  round(d_nnd_t17, 4), round(d_nnd_rn18, 4), round(d_nnd_t18, 4)),
  Observed_NND = c( round(nnd_rn17, 4), round(nnd_t17, 4), round(nnd_rn18, 4), round(nnd_t18, 4)),
  Z_score = c(round(z_rn17, 4), round(z_t17, 4), round(z_rn18, 4), round(z_t18, 4) ),
  Ratio = c(round(R_rn17, 4), round(R_t17, 4), round(R_rn18, 4), round(R_t18, 4)),
  p_value = c(round(p_value_rn17, 4), "p < 0.0001", round(p_value_rn18, 4), "p < 0.0001"))

#Create a Table for results 2019
nndResults_19 <- data.frame(
  . = c("Precipitation in 2019", "Temperature in 2019", "Precipitation in 2018", "Temperature in 2018" ),
  Random_NND = c(round(r_nnd_rn19, 4), round(r_nnd_t19, 4), round(r_nnd_rn18, 4), round(r_nnd_t18, 4)),
  Disperse_NND = c(round(d_nnd_rn19, 4),  round(d_nnd_t19, 4), round(d_nnd_rn18, 4), round(d_nnd_t18, 4)),
  Observed_NND = c( round(nnd_rn19, 4), round(nnd_t19, 4), round(nnd_rn18, 4), round(nnd_t18, 4)),
  Z_score = c(round(z_rn19, 4), round(z_t19, 4), round(z_rn18, 4), round(z_t18, 4) ),
  Ratio = c(round(R_rn19, 4), round(R_t19, 4), round(R_rn18, 4), round(R_t18, 4)),
  p_value = c("p < 0.0001", "p < 0.0001", round(p_value_rn18, 4), "p < 0.0001"))

kable(nndResults, caption = "Nearest Neighbor Analysis Results for BC (Study Area: 944,735 km²)")
kable(nndResults_19, caption = "Nearest Neighbor Analysis Results for BC (Study Area: 944,735 km²)")

################################################## Mapping NND 
# Precip 2017
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = bc_rain_17, aes(color = NND), size = 1) + 
  scale_color_gradient(low = "blue", high = "red", name = "NND (m)") +  
  labs(
    title = "Nearest Neighbor Distance Analysis",
    subtitle = "Weather Stations Measuring Precipitation in BC (2017)"
  ) +
  theme_minimal() +  
  coord_sf() +  
  annotation_north_arrow(location = "tr") +  
  annotation_scale()  

# Precip 2018
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = bc_rain_18, aes(color = NND), size = 1) +  
  scale_color_gradient(low = "blue", high = "red", name = "NND (m)") +  
  labs(
    title = "Nearest Neighbor Distance Analysis",
    subtitle = "Weather Stations Measuring Precipitation in BC (2018)"
  ) +
  theme_minimal() +  
  coord_sf() +  
  annotation_north_arrow(location = "tr") +  
  annotation_scale()  

# Precip 2019
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = bc_rain_19, aes(color = NND), size = 1) +  
  scale_color_gradient(low = "blue", high = "red", name = "NND (m)") +  
  labs(
    title = "Nearest Neighbor Distance Analysis",
    subtitle = "Weather Stations Measuring Precipitation in BC (2019)"
  ) +
  theme_minimal() +  
  coord_sf() +  
  annotation_north_arrow(location = "tr") +  
  annotation_scale()  

# temp 2017
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = bc_temp_17, aes(color = NND), size = 1) + 
  scale_color_gradient(low = "blue", high = "red", name = "NND (m)") +  
  labs(
    title = "Nearest Neighbor Distance Analysis",
    subtitle = "Weather Stations Measuring Temperature in BC (2017)"
  ) +
  theme_minimal() +  
  coord_sf() +  
  annotation_north_arrow(location = "tr") +  
  annotation_scale()  

# temp 2018
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = bc_temp_18, aes(color = NND), size = 1) +  
  scale_color_gradient(low = "blue", high = "red", name = "NND (m)") +  
  labs(
    title = "Nearest Neighbor Distance Analysis",
    subtitle = "Weather Stations Measuring Temperature in BC (2018)"
  ) +
  theme_minimal() +  
  coord_sf() +  
  annotation_north_arrow(location = "tr") +  
  annotation_scale()

# temp 2019
ggplot() +
  geom_sf(data = BC, fill = "white", color = "black") +  
  geom_sf(data = bc_temp_18, aes(color = NND), size = 1) +  
  scale_color_gradient(low = "blue", high = "red", name = "NND (m)") +  
  labs(
    title = "Nearest Neighbor Distance Analysis",
    subtitle = "Weather Stations Measuring Temperature in BC (2019)"
  ) +
  theme_minimal() +  
  coord_sf() +  
  annotation_north_arrow(location = "tr") +  
  annotation_scale()

################################################## Quadrat Analysis
## Set quads 
quads <- 15
qcount_rn17 <- quadratcount(precip17.ppp, nx = quads, ny = quads)
qcount_rn18 <- quadratcount(precip18.ppp, nx = quads, ny = quads)
qcount_rn19 <- quadratcount(precip19.ppp, nx = quads, ny = quads)

qcount_t17 <- quadratcount(temp17.ppp, nx = quads, ny = quads)
qcount_t18 <- quadratcount(temp18.ppp, nx = quads, ny = quads)
qcount_t19 <- quadratcount(temp19.ppp, nx = quads, ny = quads)

# Transform qcount to a dataframe.
df_qcount_rn17 <- as.data.frame(qcount_rn17)
df_qcount_rn18 <- as.data.frame(qcount_rn18)
df_qcount_rn19 <- as.data.frame(qcount_rn19)

df_qcount_t17 <- as.data.frame(qcount_t17)
df_qcount_t18 <- as.data.frame(qcount_t18)
df_qcount_t19 <- as.data.frame(qcount_t19)

# Count the number of quadrats with a distinct number of points
df_qcount_rn17 <- plyr::count(df_qcount_rn17,'Freq')
df_qcount_rn18 <- plyr::count(df_qcount_rn18,'Freq')
df_qcount_rn19 <- plyr::count(df_qcount_rn19,'Freq')

df_qcount_t17 <- plyr::count(df_qcount_t17,'Freq')
df_qcount_t18 <- plyr::count(df_qcount_t18,'Freq')
df_qcount_t19 <- plyr::count(df_qcount_t19,'Freq')

# Change the column names
colnames(df_qcount_rn17) <- c("x","f")
colnames(df_qcount_rn18) <- c("x","f")
colnames(df_qcount_rn19) <- c("x","f")
colnames(df_qcount_t17) <- c("x","f")
colnames(df_qcount_t18) <- c("x","f")
colnames(df_qcount_t19) <- c("x","f")
################################################## Calculating Quadrat Analysis statistics
# precip 2017
M_rn17 <- sum(df_qcount_rn17$f)                                     # Total frequency
N_rn17 <- sum(df_qcount_rn17$x * df_qcount_rn17$f)                  # Weighted sum
sumf_x2_rn17 <- sum(df_qcount_rn17$f * df_qcount_rn17$x^2)          # Weighted sum of squares
sumfx_2_rn17 <- N_rn17^2                                            # Square of weighted sum
VAR_rn17 <- (sumf_x2_rn17 - (sumfx_2_rn17 / M_rn17)) / (M_rn17 - 1) # Variance
MEAN_rn17 <- N_rn17 / M_rn17                                        # Mean
VMR_rn17 <- VAR_rn17 / MEAN_rn17                                    # Variance-to-mean ratio

# precip 2018
M_rn18 <- sum(df_qcount_rn18$f)                                     # Total frequency
N_rn18 <- sum(df_qcount_rn18$x * df_qcount_rn18$f)                  # Weighted sum
sumf_x2_rn18 <- sum(df_qcount_rn18$f * df_qcount_rn18$x^2)          # Weighted sum of squares
sumfx_2_rn18 <- N_rn18^2                                            # Square of weighted sum
VAR_rn18 <- (sumf_x2_rn18 - (sumfx_2_rn18 / M_rn18)) / (M_rn18 - 1) # Variance
MEAN_rn18 <- N_rn18 / M_rn18                                        # Mean
VMR_rn18 <- VAR_rn18 / MEAN_rn18                                    # Variance-to-mean ratio

# precip 2019
M_rn19 <- sum(df_qcount_rn19$f)                                     # Total frequency
N_rn19 <- sum(df_qcount_rn19$x * df_qcount_rn19$f)                  # Weighted sum
sumf_x2_rn19 <- sum(df_qcount_rn19$f * df_qcount_rn19$x^2)          # Weighted sum of squares
sumfx_2_rn19 <- N_rn19^2                                            # Square of weighted sum
VAR_rn19 <- (sumf_x2_rn19 - (sumfx_2_rn19 / M_rn19)) / (M_rn19 - 1) # Variance
MEAN_rn19 <- N_rn19 / M_rn19                                        # Mean
VMR_rn19 <- VAR_rn19 / MEAN_rn19                                    # Variance-to-mean ratio

# TEMP 2017
M_t17 <- sum(df_qcount_t17$f)                                    # Total frequency
N_t17 <- sum(df_qcount_t17$x * df_qcount_t17$f)                  # Weighted sum
sumf_x2_t17 <- sum(df_qcount_t17$f * df_qcount_t17$x^2)          # Weighted sum of squares
sumfx_2_t17 <- N_t17^2                                           # Square of weighted sum
VAR_t17 <- (sumf_x2_t17 - (sumfx_2_t17 / M_t17)) / (M_t17 - 1)   # Variance
MEAN_t17 <- N_t17 / M_t17                                        # Mean
VMR_t17 <- VAR_t17 / MEAN_t17                                    # Variance-to-mean ratio

# TEMP 2018
M_t18 <- sum(df_qcount_t18$f)                                   # Total frequency
N_t18 <- sum(df_qcount_t18$x * df_qcount_t18$f)                 # Weighted sum
sumf_x2_t18 <- sum(df_qcount_t18$f * df_qcount_t18$x^2)         # Weighted sum of squares
sumfx_2_t18 <- N_t18^2                                          # Square of weighted sum
VAR_t18 <- (sumf_x2_t18 - (sumfx_2_t18 / M_t18)) / (M_t18 - 1)  # Variance
MEAN_t18 <- N_t18 / M_t18                                       # Mean
VMR_t18 <- VAR_t18 / MEAN_t18                                   # Variance-to-mean ratio

# TEMP 2019
M_t19 <- sum(df_qcount_t19$f)                                   # Total frequency
N_t19 <- sum(df_qcount_t19$x * df_qcount_t19$f)                 # Weighted sum
sumf_x2_t19 <- sum(df_qcount_t19$f * df_qcount_t19$x^2)         # Weighted sum of squares
sumfx_2_t19 <- N_t19^2                                          # Square of weighted sum
VAR_t19 <- (sumf_x2_t19 - (sumfx_2_t19 / M_t19)) / (M_t19 - 1)  # Variance
MEAN_t19 <- N_t19 / M_t19                                       # Mean
VMR_t19 <- VAR_t19 / MEAN_t19                                   # Variance-to-mean ratio


################################################## Compute chi-square and p-value
# Chi-square value
chi_square_rn17 = VMR_rn17 * (M_rn17 - 1)
chi_square_rn18 = VMR_rn18 * (M_rn18 - 1)
chi_square_rn19 = VMR_rn19 * (M_rn19 - 1)

chi_square_t17 = VMR_t17 * (M_t17 - 1)
chi_square_t18 = VMR_t18 * (M_t18 - 1)
chi_square_t19 = VMR_t19 * (M_t19 - 1)

# P-value
pvalue_rn17 = 1 - pchisq(chi_square_rn17, (M_rn17 - 1))
pvalue_rn18 = 1 - pchisq(chi_square_rn18, (M_rn18 - 1))
pvalue_rn19 = 1 - pchisq(chi_square_rn19, (M_rn19 - 1))

pvalue_t17 = 1 - pchisq(chi_square_t17, (M_t17 - 1))
pvalue_t18 = 1 - pchisq(chi_square_t18, (M_t18 - 1))
pvalue_t19 = 1 - pchisq(chi_square_t19, (M_t19 - 1))

# Create Table for results
num_qrads = quads * quads
quadResults <- data.frame(
  . = c("Precipitation in 2017", "Temperature in 2017", "Precipitation in2018", "Temperature in 2018" ),
  Quadrats = c(num_qrads, num_qrads, num_qrads, num_qrads),
  Variance = c(round(VAR_rn17, 4), round(VAR_t17, 4), round(VAR_rn18, 4), round(VAR_t18, 4)),
  Mean = c(round(MEAN_rn17, 4), round(MEAN_t17, 4), round(MEAN_rn18, 4), round(MEAN_t18, 4)),
  VMR = c(round(VMR_rn17, 4), round(VMR_t17, 4), round(VMR_rn18, 4), round(VMR_t18, 4)),
  Chi_square = c(round(chi_square_rn17, 4), round(chi_square_t17, 4), round(chi_square_rn18, 4), round(chi_square_t18, 4)),
  p_value = c("p < 0.001",  "p < 0.001",  "p < 0.001",  "p < 0.001")
)

quadResults19 <- data.frame(
  . = c("Precipitation in 2019", "Temperature in 2019", "Precipitation in2018", "Temperature in 2018" ),
  Quadrats = c(num_qrads, num_qrads, num_qrads, num_qrads),
  Variance = c(round(VAR_rn19, 4), round(VAR_t19, 4), round(VAR_rn18, 4), round(VAR_t18, 4)),
  Mean = c(round(MEAN_rn19, 4), round(MEAN_t19, 4), round(MEAN_rn18, 4), round(MEAN_t18, 4)),
  VMR = c(round(VMR_rn19, 4), round(VMR_t19, 4), round(VMR_rn18, 4), round(VMR_t18, 4)),
  Chi_square = c(round(chi_square_rn19, 4), round(chi_square_t19, 4), round(chi_square_rn18, 4), round(chi_square_t18, 4)),
  p_value = c("p < 0.001",  "p < 0.001",  "p < 0.001",  "p < 0.001")
)


#Print a table of the results.
kable(quadResults, caption = "Quadrat Analysis Results for BC (Study Area: 944,735 km²).")
kable(quadResults19, caption = "Quadrat Analysis Results for BC (Study Area: 944,735 km²).")

################################################## K-FUNCTION 
# Create a basic k-function
k_fun_rn17 <- Kest(precip17.ppp, correction = "Ripley")
k_fun_rn18 <- Kest(precip18.ppp, correction = "Ripley")
k_fun_rn19 <- Kest(precip19.ppp, correction = "Ripley")

k_fun_t17 <- Kest(temp17.ppp, correction = "Ripley")
k_fun_t18 <- Kest(temp18.ppp, correction = "Ripley")
k_fun_t19 <- Kest(temp19.ppp, correction = "Ripley")

# Plot K-function
plot(k_fun_rn17)
plot(k_fun_t17)
plot(k_fun_rn18)
plot(k_fun_t18)
plot(k_fun_rn19)
plot(k_fun_t19)

# Use simulation to test the point pattern against CSR
k_fun_e_rn17 <- envelope(precip17.ppp, Kest, nsim = 99, correction = "Ripley", verbose = FALSE)
plot(k_fun_e_rn17, main = "Weather Stations for Measuring Precipitation in BC (2017)")

k_fun_e_rn18 <- envelope(precip18.ppp, Kest, nsim = 99, correction = "Ripley", verbose = FALSE)
plot(k_fun_e_rn18, main = "Weather Stations for Measuring Precipitation in BC (2018)")

k_fun_e_rn19 <- envelope(precip19.ppp, Kest, nsim = 99, correction = "Ripley", verbose = FALSE)
plot(k_fun_e_rn19, main = "Weather Stations for Measuring Precipitation in BC (2019)")

k_fun_e_t17 <- envelope(temp17.ppp, Kest, nsim = 99, correction = "Ripley", verbose = FALSE)
plot(k_fun_e_t17, main = "Weather Stations for Measuring Temperature in BC (2017)")

k_fun_e_t18 <- envelope(temp18.ppp, Kest, nsim = 99, correction = "Ripley", verbose = FALSE)
plot(k_fun_e_t18, main = "Weather Stations for Measuring Temperature in BC (2018)")

k_fun_e_t19 <- envelope(temp19.ppp, Kest, nsim = 99, correction = "Ripley", verbose = FALSE)
plot(k_fun_e_t19, main = "Weather Stations for Measuring Temperature in BC (2019)")
