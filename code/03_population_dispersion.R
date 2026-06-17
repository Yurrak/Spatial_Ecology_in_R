#Ecology & SDM — Lesson 1 笔记
#今天这节课是物种分布模型（SDM）的入门基础课。我们的核心目标是：用已知的物种出现记录，结合环境变量数据，为后续建立预测模型做准备。
#具体来说，我们使用了 sdm 包自带的青蛙数据集作为练习素材。数据分为两类：一类是矢量数据（SpatVector），也就是青蛙的采样点，每个点记录了地理坐标和是否出现（Occurrence: 1=出现, 0=未出现）；另一类是栅格数据（SpatRaster），也就是覆盖整个研究区域的环境变量图层，包括海拔（elevation）、温度（temperature）、降雨（precipitation）和植被指数（vegetation）。
#我们学会了用 vect() 读取矢量数据，用 rast() 读取栅格数据，用 geom() 提取坐标，用 $ 提取属性字段，用 cbind() 合并数据框，用 write.csv() 导出数据，以及用 plot() 和 points() 在同一张图上叠加不同图层。
#这些操作在以后的建模流程中会反复用到：整理好的坐标+出现记录将作为模型的训练数据，环境变量图层将作为预测变量，最终目标是让模型学习青蛙偏好什么样的环境，然后预测研究区域内哪些地方适合青蛙生存。



library(terra)
library(sdm)
library(viridis)
file <- system.file("external/species.shp", package="sdm")
rana <- vect(file)
plot(rana)
# Assuming 'rana' is your SpatVector with points and attributes
# Extract coordinates using the geom() function
coordinates <- geom(rana)

# Convert the coordinates to a data frame
coordinates_df <- as.data.frame(coordinates)

#(转换前后的区别是class的区别，可以看以下两行结果)
class(coordinates)      # "matrix" "array"
class(coordinates_df)   # "data.frame"

# Extract the 'Occurrence' attribute from the SpatVector
occurrence_df <- as.data.frame(rana$Occurrence)

#看看整个rana的属性
# 查看属性表有哪些列
names(rana)        # 会显示 "Occurrence" 等字段
# 查看完整属性表
as.data.frame(rana)  # 会看到所有属性列，但不含坐标

# Combine the coordinates and the occurrence data into one data frame
final_df <- cbind(coordinates_df, occurrence_df)

# Export the final data frame to a CSV file
write.csv(final_df, "coordinates_with_occurrence.csv", row.names = FALSE)

#查看csv
getwd()

# View the first few rows of the final table (optional)
head(final_df)

# Add the attribute column (e.g., Occurrence) to the data frame
#这其实是另一种方式实现和之前 cbind() 一样的效果——直接把 Occurrence 列加到 coordinates_df 里。比之前的方法更简洁,结果是一样的，但这种写法更直接。不过要注意，这会修改原来的 coordinates_df，而不是创建新的数据框。

coordinates_df$Occurrence <- rana$Occurrence

# Export the data frame to a CSV file
write.csv(coordinates_df, "coordinates_with_occurrence.csv", row.names = FALSE)

#数据内容相同，但列名可能不同。如果之前没有手动改过列名的话，现在这个版本反而更整洁。
names(final_df)
names(coordinates_df)

# Occurrences
rana$Occurrence

# Selection of presences
pres <- rana[rana$Occurrence==1]

# Exercise: select all absences
abse <- rana[rana$Occurrence==0]
# or
abse <- rana[rana$Occurrence!=1]

# Ecercise: plot the presences with a color together with the absences with another color
plot(pres, col="#76EE00") # chartreuse1
# or
plot(pres, col="chartreuse1") 

plot(abse, col="#FF1493") # deeppink
# I cannot use plot but, rather, I would prefer using points()因为新的plot会覆盖上一个plot

plot(pres, col="chartreuse1") 
points(abse, col="#FF1493") # deeppink

# Exercise: do the same in a multiframe with the two sets: pres on top of abse
par(mfrow=c(2,1))
plot(pres)
plot(abse)

# Covariates
elev <- system.file("external/elevation.asc", package="sdm")
# [1] "/usr/local/lib/R/site-library/sdm/external/elevation.asc"

elevmap <- rast(elev)

# Exercise: change the colors of the elevation map by the colorRampPalette function
cl <- colorRampPalette(c("green","hotpink","mediumpurple"))(100)
plot(elevmap, col=cl)

# Exercise: plot the presnces together with elevation map
points(pres, pch=19)

# Exercise: import temperature and plot presences vs. temperature
temp <- system.file("external/temperature.asc", package="sdm")

tempmap <- rast(temp)
plot(tempmap)
points(pres)

plot(tempmap, col=mako(100))

# Exercise: plot elevation and temperature with presences one beside the other
par(mfrow=c(1,2))
plot(elevmap, col=mako(100))
points(pres)
plot(tempmap, col=mako(100))
points(pres)

# precipitation
prec <- system.file("external/precipitation.asc", package="sdm")

precmap <- rast(prec)
plot(precmap, col=mako(100))
points(pres)

# vegetation
vege <- system.file("external/vegetation.asc", package="sdm")
vegemap <- rast(vege)
vegemap        # 查看基本信息
summary(vegemap)  # 查看值的范围，帮助判断是连续值还是分类值
plot(vegemap)
points(pres)



# 方法1：手动排列成四个图
# Exercise: plot all the ancillary variable in a multiframe
par(mfrow=c(2,2))
plot(elevmap)
plot(tempmap)
plot(precmap)
plot(vegemap)

# 方法2：自动排列：自动识别4层，自动排成2x2
anci <- c(elevmap, tempmap, precmap, vegemap)
plot(anci)
plot(anci, col=magma(100))
