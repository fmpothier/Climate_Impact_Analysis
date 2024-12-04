library("terra")
library("lubridate")
library("gtable")
library("grid")
library("gridExtra")
library("ggplot2")
library("dplyr")
library("raster")
library("sp")
library("st")
library("sf")
library("stringr")
library("e1071")

# Setting working Dir
dir <- "~/Downloads/classes/2024/Fall/GEOG 418/Final Project"
setwd(dir)

# # # Cleaning Fire data
# Fire_2019 <- "BC_Fire_Point_2019-point.shp"
# shapefile_2019 <- st_read(Fire_2019)
# # Clean and filter rows
# filtered_shp <- shapefile_2019 %>%
#   filter(CURRENT_SI != 0, FIRE_YEAR == 2019)
# 
# filtered_shp <- filtered_shp %>%
#    mutate(
#     IGNITION_D = str_trim(IGNITION_D)  # Trim leading and trailing spaces
#     ) %>%
#    filter(
#      !is.na(IGNITION_D),  # Remove rows with NA in the date column
#      str_detect(IGNITION_D, "^\\d{4}/\\d{2}/\\d{2}$")  # Keep only rows matching the YYYY/MM/DD format
#    )
# 
# # # Saving Cleaned shapefile
# output_shapefile_path <- "./Cleaned_data/BC_Fire_2019.shp"
# st_write(filtered_shp, output_shapefile_path, delete_layer = TRUE)

# Opeing the shapefile
fire_2017 <- vect("./Cleaned_data/BC_Fire_2017.shp")
fire_2018 <- vect("./Cleaned_data/BC_Fire_2018.shp")
fire_2019 <- vect("./Cleaned_data/BC_Fire_2019.shp")

# Turning the shapefile into a dataframe
fire_2017_df <- as.data.frame(fire_2017) 
fire_2018_df <- as.data.frame(fire_2018) 
fire_2019_df <- as.data.frame(fire_2019) 

# Convert Date formate
fire_2017_df$IGNITION_D<- as.Date(fire_2017_df$IGNITION_D, format = "%Y/%m/%d")
fire_2018_df$IGNITION_D<- as.Date(fire_2018_df$IGNITION_D, format = "%Y/%m/%d")
fire_2019_df$IGNITION_D<- as.Date(fire_2019_df$IGNITION_D, format = "%Y/%m/%d")

# Parse Data
fire_2017_df$IGN_Day_2017 <- yday(fire_2017_df$IGNITION_D) 
fire_2017_df$IGN_Month_2017 <- month(fire_2017_df$IGNITION_D, label = TRUE, abbr = TRUE) 
fire_2017_df$IGN_Year_2017 <- year(fire_2017_df$IGNITION_D) 

fire_2018_df$IGN_Day_2018 <- yday(fire_2018_df$IGNITION_D) 
fire_2018_df$IGN_Month_2018 <- month(fire_2018_df$IGNITION_D, label = TRUE, abbr = TRUE) 
fire_2018_df$IGN_Year_2018 <- year(fire_2018_df$IGNITION_D) 

fire_2019_df$IGN_Day_2019 <- yday(fire_2019_df$IGNITION_D) 
fire_2019_df$IGN_Month_2019 <- month(fire_2019_df$IGNITION_D, label = TRUE, abbr = TRUE) 
fire_2019_df$IGN_Year_2019 <- year(fire_2019_df$IGNITION_D) 


# Fires in only desired year (2017, 2018)
fire_2017_df <- fire_2017_df[which(fire_2017_df$IGN_Year_2017 == 2017),] 
fire_2018_df <- fire_2018_df[which(fire_2018_df$IGN_Year_2018 == 2018),] 
fire_2019_df <- fire_2019_df[which(fire_2019_df$IGN_Year_2019 == 2019),] 

# Fire season (May to October)
df_May_Oct_2017 <- subset(fire_2017_df, IGN_Day_2017 >= 121 & IGN_Day_2017 <= 305) 
df_May_Oct_2018 <- subset(fire_2018_df, IGN_Day_2018 >= 121 & IGN_Day_2018 <= 305) 
df_May_Oct_2019 <- subset(fire_2019_df, IGN_Day_2019 >= 121 & IGN_Day_2019 <= 305) 


############################################################### stats for 2017 
fire_2017_df <- fire_2017_df %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))

fire_2018_df <- fire_2018_df %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))

fire_2019_df <- fire_2019_df %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI))

df_May_Oct_2017 <- df_May_Oct_2017 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI)) 

df_May_Oct_2018 <- df_May_Oct_2018 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI)) 

df_May_Oct_2019 <- df_May_Oct_2019 %>%
  mutate(CURRENT_SI = as.numeric(CURRENT_SI)) 

#calucate total sum of burned areas:
total_sum17 <- sum(fire_2017_df$CURRENT_SI, na.rm = TRUE)
total_sum18 <- sum(fire_2018_df$CURRENT_SI, na.rm = TRUE)
total_sum19 <- sum(fire_2019_df$CURRENT_SI, na.rm = TRUE)
print(total_sum17)
print(total_sum18)
print(total_sum19)

# 2017 full year and fire season Basic stats
meanPop_2017 <- mean(fire_2017_df$CURRENT_SI)
meanSummer_2017 <- mean(df_May_Oct_2017$CURRENT_SI)

sdPop_2017 <- sd(fire_2017_df$CURRENT_SI, na.rm = TRUE) 
sdSummer_2017 <- sd(df_May_Oct_2017$CURRENT_SI, na.rm = TRUE) 

modePop_2017 <- as.numeric(names(sort(table(fire_2017_df$CURRENT_SI), decreasing = TRUE))[1]) 
modeSummer_2017 <- as.numeric(names(sort(table(df_May_Oct_2017$CURRENT_SI), decreasing = TRUE))[1])

medPop_2017 <- median(fire_2017_df$CURRENT_SI, na.rm = TRUE)
medSummer_2017 <- median(df_May_Oct_2017$CURRENT_SI, na.rm = TRUE)

skewPop_2017 <- skewness(fire_2017_df$CURRENT_SI, na.rm = TRUE)[1]
skewSummer_2017 <- skewness(df_May_Oct_2017$CURRENT_SI, na.rm = TRUE)[1]

kurtPop_2017 <- kurtosis(fire_2017_df$CURRENT_SI, na.rm = TRUE)[1]
kurtSummer_2017 <- kurtosis(df_May_Oct_2017$CURRENT_SI, na.rm = TRUE)[1]

CoVPop_2017 <- (sdPop_2017 / meanPop_2017) * 100
CoVSummer_2017 <- (sdSummer_2017 / meanSummer_2017) * 100

# Normal distribution test
normPop_PVAL_2017 <- shapiro.test(fire_2017_df$CURRENT_SI)$p.value
normSummer_PVAL_2017 <- shapiro.test(df_May_Oct_2017$CURRENT_SI)$p.value

samples_2017 = c("Population", "Fire Season")
means_2017 = c(meanPop_2017, meanSummer_2017) #Create an object for the means
sd_2017 = c(sdPop_2017, sdSummer_2017) #Create an object for the standard deviations
median_2017 = c(medPop_2017, medSummer_2017) #Create an object for the medians
mode_2017 <- c(modePop_2017, modeSummer_2017) #Create an object for the modes
skewness_2017 <- c(skewPop_2017, skewSummer_2017) #Create an object for the skewness
kurtosis_2017 <- c(kurtPop_2017, kurtSummer_2017) #Create an object for the kurtosis
CoV_2017 <- c(CoVPop_2017, CoVSummer_2017) #Create an object for the CoV
normality_2017 <- c(normPop_PVAL_2017, normSummer_PVAL_2017) #Create an object for the normality PVALUE

# Round decimal
means_2017 <- round(means_2017, 3)
sd_2017 <- round(sd_2017, 3)
median_2017 <- round(median_2017, 3)
mode_2017 <- round(mode_2017,3)
skewness_2017 <- round(skewness_2017,3)
kurtosis_2017 <- round(kurtosis_2017,3)
CoV_2017 <- round(CoV_2017, 3)
normality_2017 <- round(normality_2017, 5)

# Creating tables
data.for.table1_2017 = data.frame(samples_2017, means_2017, sd_2017, median_2017, mode_2017)
data.for.table2_2017 = data.frame(samples_2017, skewness_2017, kurtosis_2017, CoV_2017, normality_2017)

# Creating csv files
outCSV_2017 <- data.frame(samples_2017, means_2017, sd_2017, median_2017, mode_2017, skewness_2017, kurtosis_2017, CoV_2017, normality_2017)
write.csv(outCSV_2017, "./FireDescriptiveStats_2017.csv", row.names = FALSE)

# Creating the table
table1_2017 <- tableGrob(data.for.table1_2017, rows = c("","")) #make a table "Graphical Object" (GrOb) 
t1Caption_2017 <- textGrob("Table 1: Measures of Central Tendency for fires in BC, 2017", gp = gpar(fontsize = 09))
padding <- unit(5, "mm")

table1_2017 <- gtable_add_rows(table1_2017, 
                          heights = grobHeight(t1Caption_2017) + padding, 
                          pos = 0)

table1_2017 <- gtable_add_grob(table1_2017,
                          t1Caption_2017, t = 1, l = 2, r = ncol(data.for.table1_2017) + 1)

table2_2017 <- tableGrob(data.for.table2_2017, rows = c("",""))
t2Caption_2017 <- textGrob("Table 2: Measures of Dispersion for fires in BC, 2017", gp = gpar(fontsize = 09))
padding <- unit(5, "mm")

table2_2017 <- gtable_add_rows(
  table2_2017,
  heights = grobHeight(t2Caption_2017) + padding,
  pos = 0
)

table2_2017 <- gtable_add_grob(table2_2017,
                               t2Caption_2017, t = 1, l = 2, r = ncol(data.for.table2_2017) + 1)
# Adding new pages 
grid.arrange(table1_2017, newpage = TRUE)
grid.arrange(table2_2017, newpage = TRUE)

# Export tables
png("Central_tendency_2017.png")
grid.arrange(table1_2017, newpage = TRUE)
dev.off() 

png("Measures_of_dispersion_2017.png") 
grid.arrange(table2_2017, newpage = TRUE)
dev.off()

# Making histogram
df_subset <- subset(fire_2017_df, fire_2017_df$CURRENT_SI > 1000)

options(scipen = 10, digits = 1)
hist(df_subset$CURRENT_SI, breaks = 100, main = "Frequency of Wild Fire Sizes above 1000 ha", xlab = "Size of Wild Fire (ha)") 
png("Histogram_fire_size.png")
dev.off()

# The sum of fire size in each month
sumJan = sum(subset(fire_2017_df, IGN_Month_2017 == "Jan")$CURRENT_SI, na.rm = TRUE) 
sumFeb = sum(subset(fire_2017_df, IGN_Month_2017 == "Feb")$CURRENT_SI, na.rm = TRUE) 
sumMar = sum(subset(fire_2017_df, IGN_Month_2017 == "Mar")$CURRENT_SI, na.rm = TRUE) 
sumApr = sum(subset(fire_2017_df, IGN_Month_2017 == "Apr")$CURRENT_SI, na.rm = TRUE) 
sumMay = sum(subset(fire_2017_df, IGN_Month_2017 == "May")$CURRENT_SI, na.rm = TRUE) 
sumJun = sum(subset(fire_2017_df, IGN_Month_2017 == "Jun")$CURRENT_SI, na.rm = TRUE) 
sumJul = sum(subset(fire_2017_df, IGN_Month_2017 == "Jul")$CURRENT_SI, na.rm = TRUE) 
sumAug = sum(subset(fire_2017_df, IGN_Month_2017 == "Aug")$CURRENT_SI, na.rm = TRUE) 
sumSep = sum(subset(fire_2017_df, IGN_Month_2017 == "Sep")$CURRENT_SI, na.rm = TRUE) 
sumOct = sum(subset(fire_2017_df, IGN_Month_2017 == "Oct")$CURRENT_SI, na.rm = TRUE) 
sumNov = sum(subset(fire_2017_df, IGN_Month_2017 == "Nov")$CURRENT_SI, na.rm = TRUE) 
sumDec = sum(subset(fire_2017_df, IGN_Month_2017 == "Dec")$CURRENT_SI, na.rm = TRUE) 
months = c("Jan", "Feb", "Mar","Apr","May","Jun","Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

# Making the bar graph
png("Output_BarGraph_2017.png") 
barplot(c(sumJan, sumFeb, sumMar,sumApr,sumMay, sumJun, sumJul, sumAug, sumSep, sumOct, sumNov, sumDec), names.arg = months, 
        main = "Total Burned Area by Month 2017", ylab = "Total Burned Area (ha)", xlab = "Month")
dev.off() 

# Graph
barGraph <- fire_2017_df %>% 
  group_by(IGN_Month_2017) %>%
  summarise(sumSize = sum(CURRENT_SI, na.rm = TRUE)) %>% 
  ggplot(aes(x = IGN_Month_2017, y = sumSize)) + 
  geom_bar(stat = "identity") + 
  labs(title = "Total Burned Area by Month 2017", x = "Month", y = "Total Burned Area (ha)", caption = "Figure 2: Total fire size by month in 2017") +
  theme_classic() + 
  theme(plot.title = element_text(face = "bold", hjust = 0.5), plot.caption = element_text(hjust = 0.5)) 
barGraph

png("Output_BarGraph_GG.png")
barGraph
dev.off()

############################################################ Stats for 2018

# 2018 Full year and fire season Basic stats
meanPop_2018 <- mean(fire_2018_df$CURRENT_SI)
meanSummer_2018 <- mean(df_May_Oct_2018$CURRENT_SI)

sdPop_2018 <- sd(fire_2018_df$CURRENT_SI, na.rm = TRUE) 
sdSummer_2018 <- sd(df_May_Oct_2018$CURRENT_SI, na.rm = TRUE) 

modePop_2018 <- as.numeric(names(sort(table(fire_2018_df$CURRENT_SI), decreasing = TRUE))[1]) 
modeSummer_2018 <- as.numeric(names(sort(table(df_May_Oct_2018$CURRENT_SI), decreasing = TRUE))[1])

medPop_2018 <- median(fire_2018_df$CURRENT_SI, na.rm = TRUE)
medSummer_2018 <- median(df_May_Oct_2018$CURRENT_SI, na.rm = TRUE)

skewPop_2018 <- skewness(fire_2018_df$CURRENT_SI, na.rm = TRUE)[1]
skewSummer_2018 <- skewness(df_May_Oct_2018$CURRENT_SI, na.rm = TRUE)[1]

kurtPop_2018 <- kurtosis(fire_2018_df$CURRENT_SI, na.rm = TRUE)[1]
kurtSummer_2018 <- kurtosis(df_May_Oct_2018$CURRENT_SI, na.rm = TRUE)[1]

CoVPop_2018 <- (sdPop_2018 / meanPop_2018) * 100
CoVSummer_2018 <- (sdSummer_2018 / meanSummer_2018) * 100

# Normal distribution test
normPop_PVAL_2018 <- shapiro.test(fire_2018_df$CURRENT_SI)$p.value
normSummer_PVAL_2018 <- shapiro.test(df_May_Oct_2018$CURRENT_SI)$p.value

samples_2018 = c("Population", "Fire Season")
means_2018 = c(meanPop_2018, meanSummer_2018) #Create an object for the means
sd_2018 = c(sdPop_2018, sdSummer_2018) #Create an object for the standard deviations
median_2018 = c(medPop_2018, medSummer_2018) #Create an object for the medians
mode_2018 <- c(modePop_2018, modeSummer_2018) #Create an object for the modes
skewness_2018 <- c(skewPop_2018, skewSummer_2018) #Create an object for the skewness
kurtosis_2018 <- c(kurtPop_2018, kurtSummer_2018) #Create an object for the kurtosis
CoV_2018 <- c(CoVPop_2018, CoVSummer_2018) #Create an object for the CoV
normality_2018 <- c(normPop_PVAL_2018, normSummer_PVAL_2018) #Create an object for the normality PVALUE

# Round decimal place
means_2018 <- round(means_2018, 3)
sd_2018 <- round(sd_2018, 3)
median_2018 <- round(median_2018, 3)
mode_2018 <- round(mode_2018,3)
skewness_2018 <- round(skewness_2018,3)
kurtosis_2018 <- round(kurtosis_2018,3)
CoV_2018 <- round(CoV_2018, 3)
normality_2018 <- round(normality_2018, 5)

# Creating tables
data.for.table1_2018 = data.frame(samples_2018, means_2018, sd_2018, median_2018, mode_2018)
data.for.table2_2018 = data.frame(samples_2018, skewness_2018, kurtosis_2018, CoV_2018, normality_2018)

# Creating csv files
outCSV_2018 <- data.frame(samples_2018, means_2018, sd_2018, median_2018, mode_2018, skewness_2018, kurtosis_2018, CoV_2018, normality_2018)
write.csv(outCSV_2018, "./FireDescriptiveStats_2018.csv", row.names = FALSE)

# Creating Seting up tables
table1_2018 <- tableGrob(data.for.table1_2018, rows = c("","")) #make a table "Graphical Object" (GrOb) 
t1Caption_2018 <- textGrob("Table 1: Measures of Central Tendency for fires in BC, 2018", gp = gpar(fontsize = 09))
padding <- unit(5, "mm")

table1_2018 <- gtable_add_rows(table1_2018, 
                               heights = grobHeight(t1Caption_2018) + padding, 
                               pos = 0)

table1_2018 <- gtable_add_grob(table1_2018,
                               t1Caption_2018, t = 1, l = 2, r = ncol(data.for.table1_2018) + 1)

table2_2018 <- tableGrob(data.for.table2_2018, rows = c("",""))
t2Caption_2018 <- textGrob("Table 2: Measures of Dispersion for fires in BC, 2018", gp = gpar(fontsize = 09))
padding <- unit(5, "mm")

table2_2018 <- gtable_add_rows(
  table2_2018,
  heights = grobHeight(t2Caption_2018) + padding,
  pos = 0
)

table2_2018 <- gtable_add_grob(table2_2018,
                               t2Caption_2018, t = 1, l = 2, r = ncol(data.for.table2_2018) + 1)

# Adding new pages 
grid.arrange(table1_2018, newpage = TRUE)
grid.arrange(table2_2018, newpage = TRUE)

# Export tables
png("Central_tendency_2018.png")
grid.arrange(table1_2018, newpage = TRUE)
dev.off() 

png("Measures_of_dispersion_2018.png") 
grid.arrange(table2_2018, newpage = TRUE)
dev.off()

# Making a histogram
df_subset <- subset(fire_2018_df, fire_2018_df$CURRENT_SI > 1000)
options(scipen = 10, digits = 1)
hist(df_subset$CURRENT_SI, breaks = 100, main = "Frequency of Wild Fire Sizes above 1000 ha", xlab = "Size of Wild Fire (ha)") 
png("Histogram_fire_size.png")
dev.off()

############################################################ Stats for 2019
# 2019 Full year and fire season Basic stats
meanPop_2019 <- mean(fire_2019_df$CURRENT_SI)
meanSummer_2019 <- mean(df_May_Oct_2019$CURRENT_SI)

sdPop_2019 <- sd(fire_2019_df$CURRENT_SI, na.rm = TRUE) 
sdSummer_2019 <- sd(df_May_Oct_2019$CURRENT_SI, na.rm = TRUE) 

modePop_2019 <- as.numeric(names(sort(table(fire_2019_df$CURRENT_SI), decreasing = TRUE))[1]) 
modeSummer_2019 <- as.numeric(names(sort(table(df_May_Oct_2019$CURRENT_SI), decreasing = TRUE))[1])

medPop_2019 <- median(fire_2019_df$CURRENT_SI, na.rm = TRUE)
medSummer_2019 <- median(df_May_Oct_2019$CURRENT_SI, na.rm = TRUE)

skewPop_2019 <- skewness(fire_2019_df$CURRENT_SI, na.rm = TRUE)[1]
skewSummer_2019 <- skewness(df_May_Oct_2019$CURRENT_SI, na.rm = TRUE)[1]

kurtPop_2019 <- kurtosis(fire_2019_df$CURRENT_SI, na.rm = TRUE)[1]
kurtSummer_2019 <- kurtosis(df_May_Oct_2019$CURRENT_SI, na.rm = TRUE)[1]

CoVPop_2019 <- (sdPop_2019 / meanPop_2019) * 100
CoVSummer_2019 <- (sdSummer_2019 / meanSummer_2019) * 100

# Normal distribution test
normPop_PVAL_2019 <- shapiro.test(fire_2019_df$CURRENT_SI)$p.value
normSummer_PVAL_2019 <- shapiro.test(df_May_Oct_2019$CURRENT_SI)$p.value

samples_2019 = c("Population", "Fire Season")
means_2019 = c(meanPop_2019, meanSummer_2019) #Create an object for the means
sd_2019 = c(sdPop_2019, sdSummer_2019) #Create an object for the standard deviations
median_2019 = c(medPop_2019, medSummer_2019) #Create an object for the medians
mode_2019 <- c(modePop_2019, modeSummer_2019) #Create an object for the modes
skewness_2019 <- c(skewPop_2019, skewSummer_2019) #Create an object for the skewness
kurtosis_2019 <- c(kurtPop_2019, kurtSummer_2019) #Create an object for the kurtosis
CoV_2019 <- c(CoVPop_2019, CoVSummer_2019) #Create an object for the CoV
normality_2019 <- c(normPop_PVAL_2019, normSummer_PVAL_2019) #Create an object for the normality PVALUE

# Round decimal place
means_2019 <- round(means_2019, 3)
sd_2019 <- round(sd_2019, 3)
median_2019 <- round(median_2019, 3)
mode_2019 <- round(mode_2019,3)
skewness_2019 <- round(skewness_2019,3)
kurtosis_2019 <- round(kurtosis_2019,3)
CoV_2019 <- round(CoV_2019, 3)
normality_2019 <- round(normality_2019, 5)

# Creating tables
data.for.table1_2019 = data.frame(samples_2019, means_2019, sd_2019, median_2019, mode_2019)
data.for.table2_2019 = data.frame(samples_2019, skewness_2019, kurtosis_2019, CoV_2019, normality_2019)

# Creating csv files
outCSV_2019 <- data.frame(samples_2019, means_2019, sd_2019, median_2019, mode_2019, skewness_2019, kurtosis_2019, CoV_2019, normality_2019)
write.csv(outCSV_2019, "./results/FireDescriptiveStats_2018.csv", row.names = FALSE)

# Creating Seting up tables
table1_2019 <- tableGrob(data.for.table1_2019, rows = c("","")) #make a table "Graphical Object" (GrOb) 
t1Caption_2019 <- textGrob("Table 1: Measures of Central Tendency for fires in BC, 2019", gp = gpar(fontsize = 09))
padding <- unit(5, "mm")

table1_2019 <- gtable_add_rows(table1_2019, 
                               heights = grobHeight(t1Caption_2019) + padding, 
                               pos = 0)

table1_2019 <- gtable_add_grob(table1_2019,
                               t1Caption_2019, t = 1, l = 2, r = ncol(data.for.table1_2019) + 1)

table2_2019 <- tableGrob(data.for.table2_2019, rows = c("",""))
t2Caption_2019 <- textGrob("Table 2: Measures of Dispersion for fires in BC, 2019", gp = gpar(fontsize = 09))
padding <- unit(5, "mm")

table2_2019 <- gtable_add_rows(
  table2_2019,
  heights = grobHeight(t2Caption_2019) + padding,
  pos = 0
)

table2_2019 <- gtable_add_grob(table2_2019,
                               t2Caption_2019, t = 1, l = 2, r = ncol(data.for.table2_2019) + 1)

# Adding new pages 
grid.arrange(table1_2019, newpage = TRUE)
grid.arrange(table2_2019, newpage = TRUE)

# Export tables
png("Central_tendency_2018.png")
grid.arrange(table1_2019, newpage = TRUE)
dev.off() 

png("Measures_of_dispersion_2018.png") 
grid.arrange(table2_2019, newpage = TRUE)
dev.off()

# Making a histogram
df_subset <- subset(fire_2019_df, fire_2019_df$CURRENT_SI > 1000)
options(scipen = 10, digits = 1)
hist(df_subset$CURRENT_SI, breaks = 100, main = "Frequency of Wild Fire Sizes above 1000 ha", xlab = "Size of Wild Fire (ha)") 
png("Histogram_fire_size.png")
dev.off()

