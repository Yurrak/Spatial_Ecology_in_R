# This code is analysing the temporal overlap between species
#时间重叠分析（temporal overlap analysis）是空间生态学中的重要补充工具，其核心思想是量化两个事件在时间上的相似程度。在生态学中，仅分析物种的空间分布是不够的——即使两个物种栖息地重叠，若它们的活动时间完全错开（如老虎在黎明活动、猕猴在白天活动），实际接触和竞争压力远低于空间数据所暗示的程度。因此，时间重叠分析是对空间重叠的重要修正，两者结合才能真实反映物种间的共存机制与竞争关系。该方法的应用不限于捕食者与猎物关系，还包括入侵物种与本地物种的竞争评估、人兽冲突的高风险时间窗口识别，以及栖息地共用模式分析。此外，这一分析中使用的核密度估计（kernel density estimation）思想在空间生态学的家域分析（home range analysis）中同样核心，区别仅在于从时间维度的密度转变为空间维度的密度。

# install.packages("overlap")

library(overlap)

data(kerinci)
#Kerinci 数据集来自印度尼西亚**克里希塞布拉特国家公园（Kerinci Seblat National Park）**的相机陷阱记录，收集了该公园内大型哺乳动物被"捕获"的时间数据。

circulartime <- kerinci$Time * 2 * pi   
#这一步是把时间转换成圆形坐标（弧度）
#时间数据有一个特殊性质：24:00 和 00:00 是同一个时刻，时间是循环的，不是直线的。
# 转换为弧度：0到2π（即0到6.28）
# 一个完整的圆 = 2π弧度

kerinci$Timecirc <- kerinci$Time * 2 * pi

tiger <- kerinci[kerinci$Sps=="tiger",]

densityPlot(tiger$Timecirc)

tigertime <- tiger$Timecirc

densityPlot(tigertime)

# Exercise: create a kernel density plot for the species called macaque

macaque <- kerinci[kerinci$Sps=="macaque",]

densityPlot(macaque$Timecirc)

macaquetime <- macaque$Timecirc

densityPlot(macaquetime)

overlapPlot(tigertime, macaquetime)


# seeing the overlap between times of different species
overlapPlot(tigertime, macaquetime)

overlapEst(tigertime, macaquetime)
# 会给出一个0到1之间的数字
# 0 = 完全不重叠
# 1 = 完全重叠
# 这张图目测大约在 0.5~0.6 之间，这个数字就是灰色面积占两条曲线总面积的比例
#   Dhat1     Dhat4     Dhat5 
#0.5320680 0.5280474 0.4974578 
#Dhat1 设计简单，样本少时稳定；样本量增大后，Dhat4和Dhat5能利用；更多数据信息，估计更精确


nrow(tiger)    # 看老虎的记录数
nrow(macaque)  # 看猕猴的记录数
# 两者都超过200，用Dhat5
#"老虎与猕猴的活动时间重叠系数为 Δ = 0.50（Dhat5，n tiger = 201，n macaque = 273），属于中等程度重叠，表明两者存在部分时间生态位分离，猕猴的昼行性活动模式可能在一定程度上降低了与老虎的直接接触风险。"


#----

# Get the unique species names
species_list <- unique(kerinci$Sps)

# Set up the plotting area with a grid (adjust n and m based on the number of species)
par(mfrow = c(3, 3))  # Example: 3 rows and 3 columns (adjust as needed)

# Loop through each species and create density plots
for (species in species_list) {
  # Subset data for the current species
  species_data <- kerinci[kerinci$Sps == species, ]
  
  # Create a density plot for the 'circ' variable of the current species
  plot(density(species_data$Timecirc), 
       main = paste("Density Plot for", species), 
       xlab = "Circumference")
}

#以下为claude推荐更好的函数densityplot：时钟时间（0:00~24:00）；圆形缝合，首尾连续；有灰色夜晚标注；适合发表

par(mfrow = c(3, 3))

for (species in species_list) {
  species_data <- kerinci[kerinci$Sps == species, ]
  
  densityPlot(species_data$Timecirc,    # ← 用这个函数
              main = paste(species),
              xlab = "Time (radians)")
}


# This code is related to the possibility to use AI to speed up coding practices

# Example with a for loop, let's take the code from the overlap example

# First: teach the process to chatGPT - example: density plots for two species

# Now ask chatGPT to speed up the process

# State something like:
# I would like to build a for loop to make the density plot of all of the species together in a multiframe


# Get unique species names
species_list <- unique(kerinci$Sps)

# Set up a multi-frame plot (e.g., 2 rows, 2 columns)
# Adjust the number of rows and columns based on the number of species
par(mfrow = c(2, 4))  # Change this if you have more species

# Loop through species list and plot density
for (species in species_list) {
  # Subset data for the current species
  species_data <- kerinci[kerinci$Sps == species, ]
  
  # Create the density plot for the current species
  densityPlot(species_data$Timecirc, 
              main = paste("Density Plot: ", species),
              col = "blue", 
              lwd = 2, #line width（线的粗细）= 2
              xlab = "Circumference Time (radians)", 
              ylab = "Density")
}


#延伸问题：画在同一张图上
# 转换为 circular time
kerinci$circ <- kerinci$Time * 2 * pi

# 物种列表
species <- unique(kerinci$Sps)

# 颜色（自动生成）
cols <- rainbow(length(species))

# 第一个物种（用于初始化图）
first_sp <- species[1]
first_data <- kerinci[kerinci$Sps == first_sp, ]

densityPlot(first_data$circ,
            col = cols[1],
            main = "Activity patterns of all species",
            xlab = "Time",
            ylab = "Density",
            lwd = 2)

# 循环叠加其他物种
for (i in 2:length(species)) {
  
  sp <- species[i]
  subset_data <- kerinci[kerinci$Sps == sp, ]
  
  densityPlot(subset_data$circ,
              add = TRUE,
              col = cols[i],
              lwd = 2)
}

# 图例
legend("topright",
       legend = species,
       col = cols,
       lwd = 2)
