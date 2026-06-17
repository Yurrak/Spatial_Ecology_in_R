#目的是建立这个意识：
#做空间分析之前，必须先"告诉R这是空间数据"，否则后续的一切——叠加地图、提取环境变量、建立分布模型——都无从谈起。
#就像你要导航，先得让手机知道你在地球上，而不是在一张白纸上。

# creating points
# Load the terra package

library(terra)

# Real coordinates
x <- c(50000, 505000, 607000, 708000)
y <- c(4500000, 4465000, 4677000, 4708000)
occurrence <- c(1,1,1,0)
#表示每个点的物种出现情况：1 = 该位置有物种出现（presence）0 = 该位置无物种出现（absence）

# Dataframe
df <- data.frame(x=x, y=y, occurrence=occurrence)

# spatvector
spat_vector <- vect(df, geom = c("x", "y"))
#把普通数据框（data.frame）转换成空间矢量对象（SpatVector）
# 转成 SpatVector 后，才有空间功能 ， plot(spat_vector)知道这是地图上的点
plot(spat_vector)

#------

# Virtual species

# Set seed for reproducibility
set.seed(42)
#为了让随机数可重复。
#42 只是个习惯用的数字，写 set.seed(1) 或 set.seed(999) 效果一样，目的是让别人运行你的代码能得到完全相同的结果。

# Generate random X and Y coordinates
num_points <- 10
X <- sample(1:10, num_points, replace = TRUE)  # Random x-coordinates between 1 and 10
Y <- sample(1:10, num_points, replace = TRUE)  # Random y-coordinates between 1 and 10
#replace = TRUE 是干什么的？控制抽样时"抽完是否放回"
#replace = FALSE（不放回）：每个数字最多出现一次

# Generate random occurrence values (0 or 1)
occurrence <- sample(c(0, 1), num_points, replace = TRUE)
#R 的默认行为是不放回，所以如果你不写，R 就会按 replace = FALSE 执行，直接报错。

# Create a data frame with X, Y, and occurrence
df <- data.frame(x = X, y = Y, occurrence = occurrence)

# Create a SpatVector with the points and occurrence values
spat_vector <- vect(df, geom = c("x", "y"))

# Add the occurrence as an attribute
spat_vector$occurrence <- df$occurrence
#其实这一步是多余的，可以删掉。因为前面 vect() 已经把 occurrence 包含进去了
#vect() 会把 df 中除了坐标列以外的所有列都自动变成属性，所以 occurrence 已经存在于 spat_vector 里了。

# View the SpatVector
spat_vector

plot(spat_vector)
