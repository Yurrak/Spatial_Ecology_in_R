# Code to visualize remote sensing data

# Zenodo set: https://zenodo.org/records/15645465
# install.packages("imageRy")

library(imageRy)
library(terra)
library(viridis)

# Listing data inside imageRy
im.list()

# importing the first band
b2 <- im.import("sentinel.dolomites.b2.tif")
plot(b2)
plot(b2, col=magma(100))

# green band
b3 <- im.import("sentinel.dolomites.b3.tif")
plot(b3)

cl <- colorRampPalette(c("black","grey","white"))(100)
plot(b3, col=cl)

# multiframe
par(mfrow=c(1,2))
# or
im.multiframe(1,2)
plot(b2, col=cl)
plot(b3, col=cl)

# the multiframe from the CRAN is not properly working, so use the GitHub version:
duccio <- function(x,y){
  par(mfrow=c(x,y))
}

plot(b2, col=cl)
plot(b3, col=cl)


dev.off()
plot(b2,b3)#b2,b3的相关函数
#图的基本信息
#X轴：b2波段的像素值（蓝光波段）
#Y轴：b3波段的像素值（绿光波段）
#每个点 = 图像中的一个像素，同时拥有b2和b3两个值
#强相关说明了什么？点几乎沿对角线紧密排列，两个波段高度同步变化
#这张图本质上是在告诉你：b2和b3"说的是差不多的话"，要获得更多信息需要引入其他波段。

# Exercise: import band 4
b4 <- im.import("sentinel.dolomites.b4.tif")
plot(b4)
plot(b4, col=cl)

# import band 8
b8 <- im.import("sentinel.dolomites.b8.tif")
plot(b8)

im.multiframe(1,2)#不起作用，必须用下面的code
par(mfrow=c(1,2))
plot(b4)
plot(b8)

# build your own function for plotting
duccio <- function(x,y){
  par(mfrow=c(x,y))
}

# Exercise: with the function duccio, build a multiframe of 2 rows and 2 columns and plot all the imported data
duccio(2,2)
plot(b2)
plot(b3)
plot(b4)
plot(b8)

# Exercise: create a multiframe with 1 row and 2 columns, plot one against the other 
# b2 b3
# b2 b8

duccio(1,2)
plot(b2,b3)
plot(b2,b8)
#生成图表示以下信息：
#b2和b3说的是同一件事（信息重复）
#b2和b8说的是不同的事（信息互补）
#蓝光反射高，近红外反射低→ 这是岩石、雪地、建筑等无植被地表→ 可见光强，NIR弱
#蓝光反射低，近红外反射高→ 这是植被！→ 植被吸收可见光（用于光合作用）→ 同时强烈反射近红外
#少数点靠近X轴 → 岩石、雪地（b2高，b8低），多数点靠近Y轴 → 植被覆盖区域（b2低，b8高）
#从像素数量来看，这张卫星图里植被像素反而更多，只是视觉上被中央白色山体吸引了注意力
#这就是为什么遥感需要NIR波段，它提供了可见光完全无法替代的新信息，也是假彩色图能揭示植被的根本原因

dev.off()

# creating colored images
sent <- c(b2, b3, b4, b8)

# layer 1 = original (from Sentinel-2) b2 = blue
# layer 2 = original (from Sentinel-2) b3 = green
# layer 3 = original (from Sentinel-2) b4 = red
# layer 4 = original (from Sentinel-2) b8 = NIR
im.plotRGB(sent, r=3, g=2, b=1)
#im.plotRGB(sent)函数没有默认值，必须定义rgb

# natural color image
im.plotRGB(sent, r=3, g=2, b=1, title='natural color')

# false color image 假彩色的本质：把不可见的信息"翻译"成可见颜色
im.plotRGB(sent, r=4, g=3, b=2, title='false color')#把不可见波长定义为红色
im.plotRGB(sent, r=3, g=4, b=2, title='false color')
im.plotRGB(sent, r=3, g=2, b=4, title='false color')
#b2（蓝光波段）的数据还在 sent 里，只是：
#没有被分配到任何通道
#所以它的信息没有参与这张图的显示

duccio(2,2)
im.plotRGB(sent, r=3, g=2, b=1, title='natural color')
im.plotRGB(sent, r=4, g=3, b=2, title='false color')
im.plotRGB(sent, r=3, g=4, b=2, title='false color')
im.plotRGB(sent, r=3, g=2, b=4, title='false color')


im.plotRGB(x, r, g, b, title = "")#这是老师写的函数模板，用来展示这个函数有哪些参数



