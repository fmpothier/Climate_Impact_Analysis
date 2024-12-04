# Climate_Impact_Analysis
<b>1.0 Introduction</b>

Over the past few decades, wildfires have burned millions of hectares of forest across British Columbia (BC), devastating the landscape. Notably, the four most severe wildfire seasons occurred in 2017, 2018, 2021, and 2023 (Parisien et al., 2023). Wildfires significantly impact ecosystems, including biodiversity, habitats, water systems, and human settlements (Haider et al., 2019). Additionally, the smoke from these fires severely affects air quality over vast distances (Douglas-Vail et al., 2023).
BC's complex topography encompasses diverse ecosystems and climates, characterized by variations in elevation, temperature, and vegetation. These environmental differences lead to significant spatial variations in wildfire intensity and extent (Meyn et al., 2013). Examining environmental factors at a spatial resolution that reflects this diversity is crucial to avoid obscuring these variations (Meyn et al., 2013). However, wildfire prediction and management remain challenging due to limited understanding of wildfires' roles in the Earth's system (Liu et al., 2024).

In BC, the area burned by wildfires appears to depend more strongly on precipitation than temperature (Meyn et al., 2013). Since precipitation patterns are inherently difficult to predict, projecting changes in wildfire severity in BC introduces greater uncertainties compared to regions where temperature is the primary limiting factor (Meyn et al., 2013). Therefore, it is vital to analyze fire-climate relationships at high spatial resolutions to capture variability in precipitation and temperature and their effects on wildfire extent (Meyn et al., 2013). Understanding whether temperature or precipitation plays a more significant role in wildfire severity is key to improving predictions and management strategies in BC (Meyn et al., 2013).

The wildfire seasons of 2017 and 2018 were among the worst in recent decades, with 1,216,053 hectares and 1,354,284 hectares burned, respectively. In stark contrast, 2019 saw a 98% decrease in burned area, with only 21,138 hectares affected. This raises the question: what made 2019 so different from the preceding two years?
This study seeks to deepen the understanding of the relationship between wildfires and climate by examining differences in climate conditions during 2017, 2018, and 2019. The goal is to determine whether temperature or precipitation played a greater role in the significant reduction of wildfire activity in 2019.

<b>2.0 Study Area and Data</b>

The study area for this research is British Columbia (BC), Canada, located between 48° and 60°N latitude and spanning 944,735 km² (Figure 4). BC is renowned for its diverse ecosystems, which range from coastal rainforests and alpine tundra to boreal forests and temperate grasslands. This ecological diversity is driven by significant variations in elevation, temperature, precipitation, soil type, and geographic location.

The coastal rainforests, situated along BC’s Pacific coastline, experience abundant precipitation, particularly during the winter months, and enjoy mild temperatures year-round. Winters typically range from 5 to 10°C, while summers vary between 15 and 20°C. The alpine tundra, found at higher elevations, is characterized by cold temperatures year-round, with low precipitation that primarily falls as snow. The boreal forests, prevalent in northern BC, receive moderate precipitation throughout the year, with cool summers and harsh winters that can dip to −40°C. In contrast, the temperate grasslands, located in interior regions such as the Okanagan Valley, receive low precipitation (mostly in spring), experience cold winters, and endure very hot summers, with temperatures often exceeding 35°C. These ecosystems reflect the complexity of BC's topography and climate, which play a critical role in shaping wildfire activity across the region.

This study utilizes secondary data obtained from two primary sources. The Fire data was collected from the BC Data Catalogue and includes the number of fires each year, the total area burned, and the geographic locations of the fires. Climate data was obtained from the Weather Station Data Portal and has the station name, elevation, location, total precipitation, average precipitation, and average temperature for each data point. Both fire and climate data are point data and were analyzed spatially and temporally to assess patterns and relationships.

One significant limitation of the climate data is the sparse distribution of weather stations across the study area. Only 200 to 400 weather stations provide data for a region as vast and topographically diverse as BC. This limited coverage introduces potential biases and gaps, particularly in remote or high-elevation regions where weather conditions can vary considerably over short distances.

The fire and climate datasets are essential to understanding the relationship between wildfires and climatic conditions. The fire data allows for spatial and temporal analysis of wildfire occurrences and their impact, while the climate data provides critical variables, such as precipitation and temperature, which influence wildfire behavior and intensity.

<b>3.0 Methods</b>

This study employs a range of spatial analysis methods to investigate the relationship between climate and wildfire activity in British Columbia (BC). The analysis includes examining the spatial distribution of weather stations and wildfires, as well as assessing spatial autocorrelation within each dataset. These methods are crucial for identifying patterns and dependencies in the spatial arrangement of data points.

To better understand climatic variability across BC, weather station data for temperature and precipitation were interpolated into continuous surfaces. This visualization enables a clearer representation of climate changes across the province’s diverse topography.

Finally, regression analyses were conducted to explore how temperature and precipitation influence the amount, severity, and spatial distribution of wildfires. These analyses include both traditional regression models and geographical regression, which accounts for spatial variability in the relationship between climate and wildfire activity.
By integrating these methods, the study aims to provide a comprehensive understanding of the fire-climate relationship in BC, highlighting the roles of temperature and precipitation in wildfire disturbance.

<b>3.1	Evaluating the Spatial Distribution of Weather Stations</b>

To assess the spatial distribution of weather stations in British Columbia (BC), three methods were utilized: Nearest Neighbor Distance Analysis, Quadrat Analysis, and K-Function Analysis. Nearest Neighbor Distance Analysis identifies whether the distribution of weather stations is random, uniform, or clustered by calculating the average distance between each station and its closest neighbor. Quadrat Analysis divides the study area into a grid of equal-sized cells to examine the density and dispersion of stations, revealing local variations in their distribution. K-Function Analysis builds on the nearest neighbor approach by evaluating spatial patterns at multiple scales, offering a more detailed perspective on clustering or dispersion across different distances. Each method contributes unique insights into the spatial arrangement of weather stations.

<b>Nearest Neighbour Distance</b>

The Nearest Neighbor Distance (NND) analysis is a widely used method to assess the spatial distribution of points across a study area. It tests whether the points fall into one of three categories: clustered, dispersed, or random. Points are considered clustered when they occur near one another. In the case of complete clustering, all the points in the study area would overlap, resulting in a Nearest Neighbor Distance mean of zero. This is because when measuring the distance between any two points, the result would be zero, as they would occupy the same location.

In contrast, a dispersed distribution occurs when points are spread out across the area. The mean Nearest Neighbor Distance dispersion varies for each study area and must be calculated to determine what the dispersion would look like if the points were perfectly distributed. To calculate the expected dispersion for a study area, the density of points must first be computed by dividing the total number of points by the area of study. This density is then used to calculate a theoretical perfectly dispersed distribution across the study area (1).

Equation 1: 
$$
\bar{NND_d} = \frac{1.07453}{\sqrt{\text{Density}}}
$$

To find the observed NND, the distance between each point and its nearest neighbor (the closest point) is measured (Clark & Evans, 1954). The sum of all these distances is then divided by the number of points in the study area, giving the average Nearest Neighbor Distance (2).

$$
I = \frac{\sum_{i=1}^n\sum_{j=1}^nW_{i,j}(x_i - \bar{x})(x_j - \bar{x})}{(\sum_{i=1}^n\sum_{j=1}^nW_{i,j})\sum_{i=1}^n(x_i - \bar{x})^2}
$$
