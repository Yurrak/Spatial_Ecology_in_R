# Spectral indices from satellite images
#这课的目的是：用NDVI对比1992年和2006年的卫星图，量化亚马逊森林砍伐的程度，同时解释为什么NDVI比DVI更科学可靠。

library(terra)
library(imageRy)
library(viridis)

# List
im.list()

m1992 <- im.import("matogrosso_l5_1992219_lrg.jpg")
# layer 1 = NIR, layer 2 = red, layer = green
im.plotRGB(m1992, r=1, g=2, b=3)
im.plotRGB(m1992, r=2, g=1, b=3)
im.plotRGB(m1992, r=2, g=3, b=1)

# Exercise: import the newest image - 2006
m2006 <- im.import("matogrosso_ast_2006209_lrg.jpg")
im.plotRGB(m2006, r=1, g=2, b=3)

# DVI 1992
# 100 NIR
# 0 red
# dvi = NIR - red = 100

# 60 NIR
# 20 red
# dvi = NIR - red = 40

dvi1992 <- m1992[[1]] - m1992[[2]] / m1992[[1]] + m1992[[2]]#应该是写错了
dvi1992 <- m1992[[1]] - m1992[[2]]
dvi2006 <- m2006[[1]] - m2006[[2]]

par(mfrow=c(1,2))
plot(dvi1992, col=inferno(100))
plot(dvi2006, col=inferno(100))
#DVI = NIR - red
#植被：NIR >> red → 正值大 → 图里亮色；裸地：red >> NIR → 负值  → 图里暗色
#1992：大片正值 → 森林覆盖广，植被健康
#2006：负值增多 → 大量植被消失，变成裸地/农田
#用数字客观记录了：马托格罗索州1992→2006年间，亚马逊雨林被大规模砍伐，转变为农业用地（主要是大豆种植）

ndvi1992 <- im.ndvi(m1992, 1, 2)
ndvi2006 <- im.ndvi(m2006, 1, 2)

plot(ndvi1992, col=inferno(100))
plot(ndvi2006, col=inferno(100))

#DVI只是告诉你"变少了"，NDVI因为标准化在-1到1之间，还能进一步：
#精确量化减少了多少
#跟其他地区、其他年份比较
#计算具体有多少公顷森林消失

#DVI vs NDVI 的区别
#DVI：NIR - red无固定范围受传感器亮度影响，不同卫星无法比较
#NDVI：(NIR-red)/(NIR+red)，永远-1到1，标准化，任何卫星都可比较

# range of ndvi
# 0-100
# ndvi = (nir - red) / (nir + red) = (100-0)/(100+0) = 1
# ndvi = (nir - red) / (nir + red) = (0-100)/(0+100) = -1
# ndvi will always range from -1 to 1

# 0-200
# ndvi = (nir - red) / (nir + red) = (200-0)/(200+0) = 1
# ndvi = (nir - red) / (nir + red) = (0-200)/(0+200) = -1
# ndvi will always range from -1 to 1


# 0-100
# dvi = (nir - red) = (100-0) = 100
# dvi = (nir - red) = (0-100) = -100

# 0-200
# dvi = (nir - red) = (200-0) = 200
# dvi = (nir - red) = (0-200) = -200



