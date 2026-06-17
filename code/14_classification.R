# This code can be used to classify satellite data
#这一课的学习目的:用卫星图像分类，把森林砍伐的程度变成具体的百分比数字。
#流程：卫星图像 → 像素分类 → 统计各类面积 → 计算百分比 → 可视化对比

library(terra)
library(imageRy)
library(ggplot2) # install.packages("ggplot2")
#install.packages("patchwork")
library(patchwork) 



im.list()

m1992 <- im.import("matogrosso_l5_1992219_lrg.jpg")
# from outside the imageRy package: rast() function from terra
# layers: 1 = NIR, 2 = red; 3 = green

plot(m1992) # rgb 123

# Exercise: import the image from 2006
m2006 <- im.import("matogrosso_ast_2006209_lrg.jpg")
plot(m2006)

# testing classification
sun <- im.import("Solar_Orbiter_s_first_views_of_the_Sun_pillars.jpg")
plot(sun)

sunc <- im.classify(sun, num_clusters=3) # unsupervised classification
#无监督分类（unsupervised classification）：
# 让算法自动把所有像素分成3组
# 相似颜色/亮度的像素归为一组
# 不需要人工告诉它每组是什么

par(mfrow=c(2,1))
plot(sun)
plot(sunc)
#为了对比分组的功能：
#原图：连续的颜色渐变，细节丰富
#分类图：只剩3种颜色，结构一目了然

# Apply the classification process to the Mato Grosso area

m1992c <- im.classify(m1992, num_clusters=2)
# class 1: human + water
# class 2: rainforest


# Exercise: classify the 2006 image
m2006c <- im.classify(m2006, num_clusters=2)
# class 1: rainforest
# class 2: human + water

#im.classify() 是无监督的
#编号不是按数量多少决定的，class1和class2的编号没有固定规律，完全是随机的
#2006年class顺序变了是因为数据量变了

# Calculating frequcnies
f1992 <- freq(m1992c)

# Proportions
# f/tot
tot1992c <- ncell(m1992c)#ncell() = number of cells，计算图像里像素的总数量
prop1992 = f1992$count / tot1992c
#freq()得到每类的像素数量÷ ncell()得到比例× 100 得到百分比


# Percentages
perc1992 = prop1992 * 100
# 1992: human = 17%, forest = 83%
perc1992
# You can calculate everything in a single line
perc1992 = freq(m1992c) * 100 / ncell(m1992c)
perc1992
# Exercise: calculate percentages of the image from 2006
perc2006 = freq(m2006c) * 100 / ncell(m2006c)
# 2006: forest = 45%, human = 55%
perc2006
# Let's implement a dataframe withthree columns: 
# class
# perc1992
# perc2006

class <- c("forest", "human")
perc1992 <- c(83, 17)
perc2006 <- c(45, 55)
tabout <- data.frame(class, perc1992, perc2006)
tabout # the dataframe is ready to go!

# Using the ggplot2 package for the final graph
p1 <- ggplot(tabout, aes(x=class, y=perc1992, color=class)) + 
  geom_bar(stat="identity", fill="white") +
  ylim(c(0,100)) +
  theme(legend.position = "none")
#p1 <- ggplot(...)  # 只是把图存进变量，不显示
# 要显示必须单独运行：
p1

# Exercise: make the same plot for 2006
p2 <- ggplot(tabout, aes(x=class, y=perc2006, color=class)) + 
  geom_bar(stat="identity", fill="white") +
  ylim(c(0,100))
p2

par(mfrow=c(2,1))
p1
p2
##par(mfrow=) 是基础R的图形系统
#ggplot2    是完全独立的图形系统
#两者互不兼容，所以不能用par

p1 + p2
p1 / p2
#将两图并列或者上下，但是patwork版本太低不显示，可以用下面的方法代替：

install.packages("gridExtra")
library(gridExtra)
grid.arrange(p1, p2, ncol=2)  # 左右并排
grid.arrange(p1, p2, nrow=2)  # 上下排列







