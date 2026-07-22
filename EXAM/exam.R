
# Vegetation Response to the 2022 Extreme Heat and Drought in Chongqing China"
# Spatial Ecology in R 2025
# Wei Gao  0001179082
# July 23, 2026

#------------------------------------------------

# Summary:
# Data Collection and Working Environment Setup
# 01 Investigating the vegetation degradation in 2022 summer
# 02 Inter-annual Comparison of August Vegetation State (2020–2024)

# ===============================================
# Data Collection and Working Environment Setup
# ===============================================

# Image download
# --------------
# Study area: Sentinel-2 tile covering southern Chongqing,
# including diverse vegetation, urban, and mountainous areas
#
# The images were downloaded through the [Copernicus Data Space Ecosystem]
# (https://dataspace.copernicus.eu/) website.
#
# Sentinel-2 bands used in this analysis (20 m resolution, R20):
#   - Band 2 (B2): Blue band
#   - Band 3 (B3): Green band
#   - Band 4 (B4): Red band
#   - Band 8A (B8A): Narrow near-infrared (NIR) band
#
# Note: Since all data are at 20 m resolution (R20), B8A is used
#       instead of B8 (which is native 10 m for Sentinel-2).


# Loading packages
# ----------------
library(terra)
library(viridis)
library(imageRy)
library(ggplot2)
library(gridExtra)  #instead of "patchwork" for compatibility with older versions of R.

# Setting the working directory
# -----------------------------
setwd("/Users/depp/Unibo/Spatial_Ecology_in_R")

# Defining color palettes
# -----------------------
cols1 <- hcl.colors(100, "Viridis")
cols2 <- hcl.colors(100, "RdYlGn")


# =========================================================
# 01 Investigating the vegetation degradation in 2022 summer 
# =========================================================


# Importing Sentinel-2 images
# ---------------------------
# The Sentinel-2 images used in this section covers the study area 
#     for two time periods: July and August 2022.  


b2_2022_07 <- rast("20220707_B02.jp2")
b3_2022_07 <- rast("20220707_B03.jp2")
b4_2022_07 <- rast("20220707_B04.jp2")
b8_2022_07 <- rast("20220707_B8A.jp2")

b2_2022_08 <- rast("20220811_B02.jp2")
b3_2022_08 <- rast("20220811_B03.jp2")
b4_2022_08 <- rast("20220811_B04.jp2")
b8_2022_08 <- rast("20220811_B8A.jp2")


# Visualizing individual spectral bands
# -------------------------------------
# Displaying the four spectral bands (B2, B3, B4, B8A) 
# allow visual inspection of raw reflectance.
# Based on the inspection of potential outliers, 
# a range parameter of 0–8000 (for visible bands) and 0–10000 (for NIR) 
# was applied to enhance visual contrast for reflectance value inspection. 

png("Bands_plot_2022.png", width = 2000, height = 1000, res = 300)
par(mfrow = c(2, 4))

plot(b2_2022_07, col = cols1, range = c(0,8000), main = "B2 202207")
plot(b3_2022_07, col = cols1, range = c(0,8000), main = "B3 202207")
plot(b4_2022_07, col = cols1, range = c(0,8000), main = "B4 202207")
plot(b8_2022_07, col = cols1, range = c(0,10000), main = "B8 202207")

plot(b2_2022_08, col = cols1, range = c(0,8000), main = "B2 202208")
plot(b3_2022_08, col = cols1, range = c(0,8000), main = "B3 202208")
plot(b4_2022_08, col = cols1, range = c(0,8000), main = "B4 202208")
plot(b8_2022_08, col = cols1, range = c(0,10000), main = "B8 202208")

dev.off()


# Composing Multi-Band rasters
# ----------------------------
# Combine the individual spectral bands into multi-layer SpatRaster objects
# The bands are ordered as: Red (B4), Green (B3), Blue (B2), and Near-Infrared (B8A).

img_2022_07 <- c(b4_2022_07, b3_2022_07, b2_2022_07, b8_2022_07)
img_2022_08 <- c(b4_2022_08, b3_2022_08, b2_2022_08, b8_2022_08)


# True color display (RGB)
# ------------------------
# Creating a multiframe panel to display the images of July and August   
# Using the im.plotRGB() function from the imageRy package 

png("plot07_08.png", width=2000, height=1000, res=300)
layout(matrix(c(1, 0, 2), nrow = 1), widths = c(1, 0.5, 1)) 
im.plotRGB(img_2022_07, r=1, g=2, b=3, title="2022_07")
im.plotRGB(img_2022_08, r=1, g=2, b=3, title="2022_08")
dev.off()


# False color display
# ------------------
# False color (NIR, Red, Green) highlights vegetation in red

png("plot07_08_falsecol.png", width=2000, height=1000, res=300)
layout(matrix(c(1, 0, 2), nrow = 1), widths = c(1, 0.5, 1)) 
im.plotRGB(img_2022_07, r=4, g=1, b=2, title="2022_07")
im.plotRGB(img_2022_08, r=4, g=1, b=2, title="2022_08")
dev.off()


# DVI analysis
# -------------
# DVI = NIR - Red
# Calculate DVI for both periods and compare their difference in a single composite image

dvi_2022_07 <- (b8_2022_07 - b4_2022_07) 
dvi_2022_08 <- (b8_2022_08 - b4_2022_08) 

dvi_diff08 <- dvi_2022_08 - dvi_2022_07 # 

png("2022_DVI.png", width=2000, height=700, res=300)
par(mfrow=c(1,3))
plot(ndvi_2022_07, col=cols1, main="DVI 202207")
plot(ndvi_2022_08, col=cols1, main="DVI 202208")
plot(ndvi_diff08, col=cols2 , main="ΔDVI 202208 - 202207", range=c(-0.2, 0.2))
#a range parameter was applied to enhance visual contrast
dev.off()



# NDVI analysis
# -------------
# NDVI = (NIR - RED) / (NIR + RED)

ndvi_2022_07 <- (b8_2022_07 - b4_2022_07) / (b8_2022_07 + b4_2022_07)
ndvi_2022_08 <- (b8_2022_08 - b4_2022_08) / (b8_2022_08 + b4_2022_08)

ndvi_diff08 <- ndvi_2022_08 - ndvi_2022_07

png("2022 NVDI.png", width=2000, height=700, res=300)
par(mfrow=c(1,3))
plot(ndvi_2022_07, col=cols1, main="NDVI 202207")
plot(ndvi_2022_08, col=cols1, main="NDVI 202208")
plot(ndvi_diff08, col=cols2 , main="ΔNDVI 202208 - 202207", range=c(-0.2, 0.2))

dev.off()


# Ridgeline plot
# ---------------
# Ridgeline plot visualizing the shift in NDVI frequency distribution 
# from July to August 2022
# Using the im.ridgeline() function from the imageRy package 
# Scale = 2 is used to emphasize the distributional shift.

im.ridgeline(c(ndvi_2022_07, ndvi_2022_08), scale = 2)


# Classification analysis
# --------------------------
# Two classification thresholds(0.3,0.4) were selected to do classification analysis

# a. threshold <- 0.3
# --------------------------
# NDVI threshold 0.3 is a widely used threshold for distinguishing 
# moderate/dense vegetation from sparse/non-vegetated areas.

threshold <- 0.3

# Classify NDVI into binary classes (0: non-vegetated, 1: vegetated) using terra::classify().
veg_map_07 <- classify(ndvi_2022_07, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_08 <- classify(ndvi_2022_08, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))

png("Classification_202207_202208.png", width = 2000, height = 700, res = 300)
par(mfrow = c(1, 2))
# 0 = Non-Vegetation(tan)
# 1 = Vegetation(darkgreen)
plot(veg_map_07, col = c("tan", "darkgreen"),main = "Classification 2022_07")
plot(veg_map_08, col = c("tan", "darkgreen"),main = "Classification 2022_08")
dev.off()
# Count valid (non-NA) pixels
valid_07 <- global(veg_map_07, fun = "notNA")[1,1]
valid_08 <- global(veg_map_08, fun = "notNA")[1,1]
# Count vegetated pixels (class == 1)
veg_07 <- global(veg_map_07 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_08 <- global(veg_map_08 == 1, fun = "sum", na.rm = TRUE)[1,1]
# Compute vegetation percentage
veg_percent_07 <- veg_07 / valid_07 * 100
veg_percent_08 <- veg_08 / valid_08 * 100
# Compute vegetation degradation
degradation0.3 = veg_percent_07-veg_percent_08


# Bar plot of vegetation vs non-vegetation cover percentages (July vs August) 
# Using ggplot2.

# Create data frame for plotting
plot_data <- data.frame(
  Month = rep(c("202207", "202208"), each = 2),
  Class = rep(c("Vegetation", "Non-Vegetation"), 2),
  Percentage = c(veg_percent_07, 100 - veg_percent_07,
                 veg_percent_08, 100 - veg_percent_08)
)
# Build grouped bar chart
ggplot(plot_data, aes(x = Month, y = Percentage, fill = Class)) +
  # Draw dodged columns
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  # Add percentage labels above bars
  geom_text(aes(label = paste0(round(Percentage, 1), "%")),
            position = position_dodge(width = 0.7),
            vjust = -0.3, size = 4) +
  # Custom colors
  scale_fill_manual(values = c("Vegetation" = "#2E8B57", "Non-Vegetation" = "#D2B48C")) +
  labs(title = "Vegetation Cover  Classification (NDVI > 0.3)",
       x = NULL, y = "Area Percentage (%)") +
  # Apply minimal theme
  theme_minimal(base_size = 13) +
  theme(legend.title = element_blank(),
        legend.position = "top",
        plot.title = element_text(hjust = 0.5, face = "bold"))
# Export plot
ggsave("Vegetation_Comparison0.3.png", width = 8, height = 6, dpi = 300)


# b. threshold <- 0.3
#--------------------------
# NDVI threshold 0.4 was chosen based on the ridgeline plot
# where a marked increase in pixel density is observed.

threshold <- 0.4  

veg_map_07 <- classify(ndvi_2022_07, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_08 <- classify(ndvi_2022_08, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))

png("Classification_202207_202208_2.png", width = 2000, height = 700, res = 300)
par(mfrow = c(1, 2))

plot(veg_map_07, col = c("tan", "darkgreen"),main = "Classification 2022_07")

plot(veg_map_08, col = c("tan", "darkgreen"),main = "Classification 2022_08")

dev.off()

valid_07 <- global(veg_map_07, fun = "notNA")[1,1]
valid_08 <- global(veg_map_08, fun = "notNA")[1,1]

veg_07 <- global(veg_map_07 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_08 <- global(veg_map_08 == 1, fun = "sum", na.rm = TRUE)[1,1]

veg_percent_07 <- veg_07 / valid_07 * 100
veg_percent_08 <- veg_08 / valid_08 * 100

degradation0.4 = veg_percent_07-veg_percent_08

degradation0.4


plot_data <- data.frame(
  Month = rep(c("202207", "202208"), each = 2),
  Class = rep(c("Vegetation", "Non-Vegetation"), 2),
  Percentage = c(veg_percent_07, 100 - veg_percent_07,
                 veg_percent_08, 100 - veg_percent_08)
)

ggplot(plot_data, aes(x = Month, y = Percentage, fill = Class)) +
  geom_col(position = position_dodge(width = 0.7), width = 0.6) +
  geom_text(aes(label = paste0(round(Percentage, 1), "%")),
            position = position_dodge(width = 0.7),
            vjust = -0.3, size = 4) +
  scale_fill_manual(values = c("Vegetation" = "#2E8B57", "Non-Vegetation" = "#D2B48C")) +
  labs(title = "Vegetation Cover  Classification (NDVI > 0.4)",
       x = NULL, y = "Area Percentage (%)") +
  theme_minimal(base_size = 13) +
  theme(legend.title = element_blank(),
        legend.position = "top",
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("Vegetation_Comparison0.4.png", width = 8, height = 6, dpi = 300)


# c. Threshold effects
#--------------------------
# Calculate vegetation degradation rate for thresholds of 0.2, 0.5, and 0.6
# to examine the threshold dependency of this pattern

#threshold = 0.2
threshold <- 0.2

veg_map_07 <- classify(ndvi_2022_07, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_08 <- classify(ndvi_2022_08, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))

valid_07 <- global(veg_map_07, fun = "notNA")[1,1]
valid_08 <- global(veg_map_08, fun = "notNA")[1,1]

veg_07 <- global(veg_map_07 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_08 <- global(veg_map_08 == 1, fun = "sum", na.rm = TRUE)[1,1]

veg_percent_07 <- veg_07 / valid_07 * 100
veg_percent_08 <- veg_08 / valid_08 * 100

degradation0.2 = veg_percent_07-veg_percent_08


#threshold = 0.5
threshold <- 0.5

veg_map_07 <- classify(ndvi_2022_07, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_08 <- classify(ndvi_2022_08, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))

valid_07 <- global(veg_map_07, fun = "notNA")[1,1]
valid_08 <- global(veg_map_08, fun = "notNA")[1,1]

veg_07 <- global(veg_map_07 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_08 <- global(veg_map_08 == 1, fun = "sum", na.rm = TRUE)[1,1]

veg_percent_07 <- veg_07 / valid_07 * 100
veg_percent_08 <- veg_08 / valid_08 * 100

degradation0.5 = veg_percent_07-veg_percent_08


#threshold = 0.6
threshold <- 0.6

veg_map_07 <- classify(ndvi_2022_07, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_08 <- classify(ndvi_2022_08, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))

valid_07 <- global(veg_map_07, fun = "notNA")[1,1]
valid_08 <- global(veg_map_08, fun = "notNA")[1,1]

veg_07 <- global(veg_map_07 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_08 <- global(veg_map_08 == 1, fun = "sum", na.rm = TRUE)[1,1]

veg_percent_07 <- veg_07 / valid_07 * 100
veg_percent_08 <- veg_08 / valid_08 * 100

degradation0.6 = veg_percent_07-veg_percent_08


# visualize the results in bar chart
df <- data.frame(
  Threshold = factor(c("≥ 0.2", "≥ 0.3", "≥ 0.4", "≥ 0.5", "≥ 0.6"),
                     levels = c("≥ 0.2", "≥ 0.3", "≥ 0.4", "≥ 0.5", "≥ 0.6")),
  Degradation = c(degradation0.2, degradation0.3, degradation0.4, degradation0.5, degradation0.6)
)


p <- ggplot(df, aes(x = Threshold, y = Degradation, fill = Threshold)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_text(aes(label = paste0(round(Degradation, 1), "%")),
            vjust = -0.5, size = 4.5) +
  labs(title = "Vegetation Degradation by NDVI Threshold",
       subtitle = "July → August 2022",
       x = "NDVI Threshold", 
       y = "Vegetation Area Reduction (%)") +
  scale_fill_manual(values = c("lightgreen", "green", "forestgreen", "darkgreen", "green")) +
  theme_minimal(base_size = 13) +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5))

ggsave("degradation_by_threshold.png", plot = p, width = 8, height = 6, dpi = 300)


# Severe degradation and dense vegetation areas
#----------------------------------------------
# area with a relatively high NDVI value in July 
# and a significant NDVI decrease in August.

high_veg_cover <- ndvi_2022_07 > 0.6 
severe_degradation <- ndvi_2022_07 > 0.4 & ndvi_diff08 < -0.15
png("NDVI_Severe_Degradation_Area.png", width=2000, height=1000, res=300)
par(mfrow = c(1, 2))
plot(severe_degradation, main = "NDVI Severe Degradation Area")
plot(high_veg_cover, main = "Dense Vegetation Cover Area")
dev.off()




# ================================================================
# 02 Inter-annual Comparison of August Vegetation State (2020–2024)
# ================================================================

  
# Importing Sentinel-2 images
#-----------------------------
# To assess whether this decline represents a genuine anomaly 
# this section extends the analysis to include August imagery 
# from 2020, 2021, and 2024 as reference years
# The year 2023 was excluded due to the absence of Sentinel-2 scenes 
# with acceptable cloud cover (< 5%) during August.


b2_2020 <- rast("20200826_B02.jp2")
b3_2020 <- rast("20200826_B03.jp2")
b4_2020 <- rast("20200826_B04.jp2")
b8_2020 <- rast("20200826_B8A.jp2")

b2_2021 <- rast("20210801_B02.jp2")
b3_2021 <- rast("20210801_B03.jp2")
b4_2021 <- rast("20210801_B04.jp2")
b8_2021 <- rast("20210801_B8A.jp2")

b2_2022 <- rast("20220811_B02.jp2")
b3_2022 <- rast("20220811_B03.jp2")
b4_2022 <- rast("20220811_B04.jp2")
b8_2022 <- rast("20220811_B8A.jp2")

b2_2024 <- rast("20240820_B02.jp2")
b3_2024 <- rast("20240820_B03.jp2")
b4_2024 <- rast("20240820_B04.jp2")
b8_2024 <- rast("20240820_B8A.jp2")

# Composing Multi-Band rasters
#-----------------------------
img_2020 <- c(b4_2020, b3_2020, b2_2020, b8_2020)
img_2021 <- c(b4_2021, b3_2021, b2_2021, b8_2021)
img_2022 <- c(b4_2022, b3_2022, b2_2022, b8_2022)
img_2024 <- c(b4_2024, b3_2024, b2_2024, b8_2024)


# True color display
#-----------------------------
png("yearsplot.png", width=2000, height=700, res=300)
# layout images separately
layout(matrix(c(1, 0, 2, 0, 3, 0, 4), nrow = 1), widths = c(1, 0.1, 1, 0.1, 1, 0.1, 1))

im.plotRGB(img_2020, r=1, g=2, b=3, title="2020")
im.plotRGB(img_2021, r=1, g=2, b=3, title="2021")
im.plotRGB(img_2022, r=1, g=2, b=3, title="2022")
im.plotRGB(img_2024, r=1, g=2, b=3, title="2024")

dev.off()

# False color display
#-----------------------------
png("yearsplot_falsecol.png", width=2000, height=700, res=300)
layout(matrix(c(1, 0, 2, 0, 3, 0, 4), nrow = 1), widths = c(1, 0.1, 1, 0.1, 1, 0.1, 1))

im.plotRGB(img_2020, r=4, g=1, b=2, title="2020")
im.plotRGB(img_2021, r=4, g=1, b=2, title="2021")
im.plotRGB(img_2022, r=4, g=1, b=2, title="2022")
im.plotRGB(img_2024, r=4, g=1, b=2, title="2024")

dev.off()


# NDVI analysis
#-----------------------------
# Calculate NDVI of every year
ndvi_2020 <- (b8_2020 - b4_2020) / (b8_2020 + b4_2020)
ndvi_2021 <- (b8_2021 - b4_2021) / (b8_2021 + b4_2021)
ndvi_2022 <- (b8_2022 - b4_2022) / (b8_2022 + b4_2022)
ndvi_2024 <- (b8_2024 - b4_2024) / (b8_2024 + b4_2024)

# NDVI comparison map
#-----------------------------
png("years_NVDI.png", width=2000, height=700, res=300)
par(mfrow=c(1,4))

plot(ndvi_2020, col=cols1, main="NDVI 2020")
plot(ndvi_2021, col=cols1, main="NDVI 2021")
plot(ndvi_2022, col=cols1, main="NDVI 2022")
plot(ndvi_2024, col=cols1, main="NDVI 2024")
dev.off()

# Inter-annual NDVI difference maps
#----------------------------------
ndvi_diff20 <- ndvi_2020 - ndvi_2022
ndvi_diff21 <- ndvi_2021 - ndvi_2022
ndvi_diff24 <- ndvi_2024 - ndvi_2022

png("years_NVDI_diff.png", width=2000, height=700, res=300)
par(mfrow=c(1,3))

plot(ndvi_diff20, col=cols2 , main="ΔNDVI 2020 - 2022", range=c(-0.2, 0.2))
plot(ndvi_diff21, col=cols2 , main="ΔNDVI 2021 - 2022", range=c(-0.2, 0.2))
plot(ndvi_diff24, col=cols2 , main="ΔNDVI 2024 - 2022", range=c(-0.2, 0.2))

dev.off()

#Classification analysis
#-----------------------------

threshold <- 0.3  
# A threshold of NDVI = 0.3 was applied following the commonly used 
# boundary between sparse and moderate-to-dense vegetation cover.

veg_map_2020 <- classify(ndvi_2020, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_2021 <- classify(ndvi_2021, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_2022 <- classify(ndvi_2022, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))
veg_map_2024 <- classify(ndvi_2024, rcl = matrix(c(-Inf, threshold, 0, threshold, Inf, 1), ncol=3, byrow=TRUE))

# Plot classification maps
png("Classification_years.png", width = 2000, height = 700, res = 300)
par(mfrow = c(1, 4))

plot(veg_map_2020, col = c("tan", "darkgreen"), main = "2020")
plot(veg_map_2021, col = c("tan", "darkgreen"), main = "2021")
plot(veg_map_2022, col = c("tan", "darkgreen"), main = "2022")
plot(veg_map_2024, col = c("tan", "darkgreen"), main = "2024")

dev.off()

# Count valid (non-NA) pixels
valid_2020 <- global(veg_map_2020, fun = "notNA")[1,1]
valid_2021 <- global(veg_map_2021, fun = "notNA")[1,1]
valid_2022 <- global(veg_map_2022, fun = "notNA")[1,1]
valid_2024 <- global(veg_map_2024, fun = "notNA")[1,1]

# Count vegetated pixels (class == 1)
veg_2020 <- global(veg_map_2020 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_2021 <- global(veg_map_2021 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_2022 <- global(veg_map_2022 == 1, fun = "sum", na.rm = TRUE)[1,1]
veg_2024 <- global(veg_map_2024 == 1, fun = "sum", na.rm = TRUE)[1,1]

# Compute vegetation percentage
veg_percent_2020 <- veg_2020 / valid_2020 * 100
veg_percent_2021 <- veg_2021 / valid_2021 * 100
veg_percent_2022 <- veg_2022 / valid_2022 * 100
veg_percent_2024 <- veg_2024 / valid_2020 * 100


# Vegetation coverage statistics
#--------------------------------

# Organise vegetation coverage statistics into a data frame for visualisation
years <- c("2020", "2021", "2022", "2024")
veg_percent_all <- c(veg_percent_2020, veg_percent_2021, veg_percent_2022, veg_percent_2024)
veg_df <- data.frame(year = years, veg_percent = veg_percent_all)

# Bar chart: vegetation coverage (%) by year; 2022 highlighted in red
p1 <- ggplot(veg_df, aes(x = year, y = veg_percent, fill = year)) +
  geom_col(width = 0.6) +
  geom_text(aes(label = sprintf("%.1f%%", veg_percent)), vjust = -0.5, size = 4.5) +
  scale_fill_manual(values = c("#66BB6A","#66BB6A","#D84315","#66BB6A")) +  # 2022 in different color
  labs(title = "Vegetation Coverage (%)", x = NULL, y = "Coverage (%)") +
  ylim(0, 100) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none",
        plot.margin = margin(t = 10, r = 50, b = 10, l = 10)) 

# Calculate mean NDVI for each year across all valid pixels
ndvi_means <- c(
  global(ndvi_2020, fun="mean", na.rm=TRUE)[1,1],
  global(ndvi_2021, fun="mean", na.rm=TRUE)[1,1],
  global(ndvi_2022, fun="mean", na.rm=TRUE)[1,1],
  global(ndvi_2024, fun="mean", na.rm=TRUE)[1,1]
)
names(ndvi_means) <- years

# Line chart: mean NDVI trend across years; 2022 highlighted in red
p2 <- ggplot(veg_df, aes(x = year, y = ndvi_means, group = 1)) +
  geom_line(color = "#2E7D32", linewidth = 1) +
  geom_point(aes(color = year), size = 4) +
  geom_text(aes(label = sprintf("%.3f", ndvi_means)), vjust = -1.2, size = 4) +
  scale_color_manual(values = c("#66BB6A","#66BB6A","#D84315","#66BB6A")) +
  labs(title = "Mean NDVI", x = NULL, y = "NDVI") +
  ylim(0.35, 0.48) +
  theme_minimal(base_size = 13) +
  theme(legend.position = "none",
        plot.margin = margin(t = 10, r = 10, b = 10, l = 50)) 

# Arrange plots side by side and export
# Using arrangeGrob() from the gridExtra package.
g <- arrangeGrob(p1, p2, ncol = 2)
ggsave("veg_ndvi_years.png", g, width = 15, height = 5, dpi = 300)



# Inter-annual SD analysis
#-----------------------------
# The per-pixel standard deviation (SD) of NDVI was computed 
# to identify which areas experienced the greatest year-to-year fluctuation.

ndvi_stack <- c(ndvi_2020, ndvi_2021, ndvi_2022, ndvi_2024)
names(ndvi_stack) <- c("2020", "2021", "2022", "2024")

# Calculate per-pixel SD of NDVI across four August scenes (2020, 2021, 2022, 2024)
ndvi_sd <- app(ndvi_stack, fun = sd)

png("NDVI_SD_interannual_range.png", width = 1400, height = 1200, res = 300)
plot(ndvi_sd, col = viridis(255, direction = -1), main = "NDVI Inter-annual SD", range = c(0, 0.2))
dev.off()



# Identify vegetation recovery area
#----------------------------------
# Condition 1 - degradation: 2022 NDVI lower than 2020 (drought impact)
# Condition 2 - recovery: 2024 NDVI higher than 2022 (post-drought recovery)
# Pixels meeting both conditions are classified as "recovered"

recovered_area <- ndvi_2022 < ndvi_2020 & ndvi_2024 > ndvi_2022
png("NDVI_recovered_area.png", width=1400, height=1200, res=300)
plot(recovered_area, main = "NDVI Recovered Area")
dev.off()


