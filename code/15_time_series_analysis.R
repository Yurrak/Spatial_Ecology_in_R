# Code for performing time series analysis on satellite data
#这节课的核心是学习如何用R对遥感卫星图像进行时间序列分析，通过对比不同时间点的卫星数据，量化地球表面的变化。
#具体来说，以格陵兰冰盖融化和植被季节变化为例，学习了三种分析手段：第一是差值图（如EN01-EN13、gr[[1]]-gr[[3]]），直接用像素相减来定位和量化变化发生的位置与幅度；第二是山脊线图（im.ridgeline()），从统计分布的角度观察整体像素值随时间的偏移趋势；第三是多图拼合（patchwork），把空间图和分布图放在一起对比，让变化的"在哪里"和"变了多少"同时呈现。
#本质上是在用数学和可视化的方法，让肉眼难以察觉的长期环境变化变得客观、直观、可量化，这正是遥感在气候变化研究中最核心的价值。

library(terra)
library(imageRy)
library(ggridges) # install.packages("ggridges")
library(ggplot2)
library(viridis)
library(patchwork)


# listing files
im.list()

EN01 <- im.import("EN_01.png")
EN01 <- flip(EN01)
#flip() 在这里是一个坐标系修正步骤，确保卫星图像显示方向正确。
EN01
# The radiometric resolution of EN01 is 8 bit.
#8-bit 意味着什么？每个像素的值可以在 0 ~ 255 之间取整数值，共 256个灰度等级。

EN13 <- im.import("EN_13.png")
EN13 <- flip(EN13)
plot(EN13)

diffEN = EN01[[1]] - EN13[[1]]
plot(diffEN)#【逐像素相减】→ diffEN → plot() → 直观看到哪里变了、变了多少

# Ridgeline plots
#绘制山脊线图（Ridgeline Plot），用来可视化 NDVI 值在不同时间层（波段）之间的分布变化。
ndvi <- im.import("NDVI_2020")
#归一化植被指数（Normalized Difference Vegetation Index）
#NDVI=（NIR−Red）/（NIR+Red）
#-1 ~ 0水体、裸土、建筑
#0 ~ 0.3稀疏植被
#0.3 ~ 0.6中等植被
#0.6 ~ 1茂密植被（森林）

im.ridgeline(ndvi, scale=1)
nlyr(ndvi)   # 查看有几个波段
names(ndvi)  # 查看各波段名称

names(ndvi) = c("02_feb", "05_may", "08_aug", "11_nov")
ndvi

im.ridgeline(ndvi, scale=1)
#完美捕捉到了植被的年内生长节律，与北半球温带地区的物候规律完全吻合
im.ridgeline(ndvi, scale=2)
im.ridgeline(ndvi, scale=3)
im.ridgeline(ndvi, scale=4)
im.ridgeline(ndvi, scale=10)
#scale是山脊的高度缩放比例
#scale=0.5  # 山脊矮，互不重叠，适合层数很多时
#scale=1    # 默认，平衡美观
#scale=2    # 山脊高，有重叠，峰形更戏剧化、视觉冲击强
#scale=3    # 大量重叠，像真正的"山脉"现实中并不会放大到10

# Ice melt in Greenland
gr <- im.import("greenland")

gr

plot(gr)
names(gr) 

names(gr) <- c("y2000", "y2005", "y2010")
#数量不对，应该有四个
names(gr) <- c("2000", "2005", "2010", "2015")


difgr = gr[[1]] - gr[[3]] 

plot(difgr)
plot(difgr, col=magma(100))
#比较第一个和第三个时间节点的变化
#正值（亮色）第1期比第3期亮 → 冰盖减少了
#负值（暗色）第1期比第3期暗 → 冰盖增加了
#接近0该区域基本没有变化

im.ridgeline(gr, scale=2)
#右侧高值峰逐渐变小，左侧低值峰逐渐变大，这正是冰盖融化的信号——高反射率的冰雪像素在减少，低反射率的裸露地表在增加。
names(gr) <- c("2000", "2005", "2010", "2015")
im.ridgeline(gr, scale=2)
# 届时Y轴会直接显示年份，趋势一目了然
#右峰减小 → 完整冰盖面积缩小 ✓（冰在融化）
#左峰减小 → 开阔水体面积也在缩小，可能是因为部分海域被季节性海冰或融水覆盖状态改变
#中峰增大 → 过渡状态的像素增多，即更多区域处于冰雪和裸地之间的混合状态


# ridgeline plotting with external images
# https://science.nasa.gov/video-detail/amf-9ed6be7f-0fbc-43f3-b689-e5fe24d8b21e/
setwd("~/Desktop/")
# C://Desktop/
getwd()

p2 <- rast("p2.png")
p2
p2 <- c(p2$p2_1, p2$p2_2, p2$p2_3)
#第4个波段是Alpha透明度通道，不携带实际地物信息，所以只取前三个。
plot(p2)#显示3张独立的灰度图
im.plotRGB(p2, 1, 2, 3)#把上面3张灰度图叠加融合，还原成人眼看到的自然色彩效果
im.ridgeline(p2, scale=2)

p1 <- rast("p1.png")
p1
p1 <- c(p1$p1_1, p1$p1_2, p1$p1_3)
plot(p1)
im.plotRGB(p1, 1, 2, 3)
#123为波段通道，分别是红绿蓝
im.ridgeline(p1, scale=2)

# tidyverse
plot1 <- im.ggplot(p1[[1]])
plot2 <- im.ggplot(p2[[1]])
plot3 <- im.ridgeline(p1, scale=2)
plot4 <- im.ridgeline(p2, scale=2)


plot1 + plot2 + plot3 + plot4
#版本问题，无法显示

library(gridExtra)
grid.arrange(plot1, plot2 , plot3 , plot4, ncol=2, nrow=2)



# copy paste im.ggplotRGB from imageRy in GitHub
# https://github.com/ducciorocchini/imageRy/blob/main/R/im.ggplotRGB.R
im.ggplotRGB <- function(input_image, r = 1, g = 2, b = 3,
                         stretch = "lin",
                         quantiles = c(0.02, 0.98),
                         title = "",
                         downsample = 1) {
  
  if (!inherits(input_image, "SpatRaster")) {
    stop("input_image should be a SpatRaster object.")
  }
  
  if (downsample == 1) {
    rgb_small <- input_image
  } else {
    rgb_small <- terra::aggregate(input_image, fact = downsample)
  }
  
  rgb_df <- terra::as.data.frame(rgb_small, xy = TRUE, na.rm = TRUE)
  band_names <- names(rgb_df)[-(1:2)]
  
  red   <- rgb_df[[band_names[r]]]
  green <- rgb_df[[band_names[g]]]
  blue  <- rgb_df[[band_names[b]]]
  
  scale01 <- function(x, probs = c(0.02, 0.98)) {
    q <- stats::quantile(x, probs = probs, na.rm = TRUE)
    x <- (x - q[1]) / (q[2] - q[1])
    pmin(pmax(x, 0), 1)
  }
  
  if (stretch == "lin") {
    red   <- scale01(red, quantiles)
    green <- scale01(green, quantiles)
    blue  <- scale01(blue, quantiles)
  } else {
    maxval <- max(c(red, green, blue), na.rm = TRUE)
    red   <- red / maxval
    green <- green / maxval
    blue  <- blue / maxval
  }
  
  rgb_df$rgb_col <- grDevices::rgb(red, green, blue)
  
  ggplot2::ggplot(rgb_df) +
    ggplot2::geom_raster(
      ggplot2::aes(x = x, y = y, fill = rgb_col)
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::coord_equal() +
    ggplot2::labs(title = title) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = 12, face = "bold"),
      axis.text = ggplot2::element_text(size = 8),
      panel.grid = ggplot2::element_blank()
    )
}

plot5 <- im.ggplotRGB(p1, 1, 2, 3)
plot6 <- im.ggplotRGB(p2, 1, 2, 3)

plot5
plot6

plot5 + plot6 + plot3 + plot4
#不行，用下面的
grid.arrange(plot5, plot6 , plot3 , plot4, ncol=2, nrow=2)


# you can also download the script with the function and then recall it by
source("im.ggplotRGB.R")










