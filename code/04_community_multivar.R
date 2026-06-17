# Code for performing multivariate analysis with community abundance matrices
#适合 PCA 的数据：✅ 环境变量本身（土壤pH、温度、含水量）✅ 形态测量数据（身高、体重、翅展）✅ 基因表达数据✅ 梯度很短时的物种数据（轴长 < 2 SD）
#适合 DCA 的数据：✅ 物种组成数据（出现/不出现，丰度）✅ 含有大量零值的矩阵✅ 梯度较长时（轴长 > 2~3 SD）

#PCA 问的是"哪个方向方差最大"， DCA 问的是"物种沿哪条生态梯度更替"。 前者是数学最优，后者是生态现实。
#你的 dune 数据，轴长约3.7 SD，物种组成矩阵含大量零值，DCA 是更合适的选择，这也解释了为什么你的 DCA 图比 PCA 图清晰得多。




# install.packages("vegan")
library(vegan)

data(dune)
head(dune)

# Multivariate analysis
multivar <- decorana(dune)
multivar

dcal1 = 3.7004
dcal2 = 3.1166 
dcal3 = 1.30055
dcal4 = 1.47888

total = dcal1 + dcal2 + dcal3 + dcal4
# or:
total <- sum(c(dcal1, dcal2, dcal3, dcal4))

total

percdca1 = dcal1 * 100 / total
percdca2 = dcal2 * 100 / total

percdca1 + percdca2

par(mfrow = c(1, 2))
plot(multivar)

# 注意：vegan 中用 rda() 做 PCA
multipca <- rda(dune, scale = TRUE)  
plot(multipca)

# Principal component analysis
multipca <- pca(dune)
plot(multipca)


#以下是deepseek教的
library(vegan)
data(dune)
data(dune.env)
# DCA 分析
multivar <- decorana(dune)
# 画图
plot(multivar, type = "n")
# 添加环境因子来解释轴的含义
ef <- envfit(multivar ~ A1 + Moisture, data = dune.env, perm = 999)
plot(ef, add = TRUE, col = "blue", cex = 1.2)
# 结果解读：
# - 如果湿度箭头指向 DCA1 正方向 → DCA1 轴反映湿度梯度
# - 如果 Eleopalu 在 DCA1 正方向 → 它喜欢高湿度环境
ef







multivar <- decorana(dune)
multivar

dca1l = 3.7004
dca2l = 3.1166
dca3l = 1.30055
dca4l = 1.47888

# get the percentage of the range detected (explained variability) by each axis

total = dca1l + dca2l + dca3l + dca4l

total = sum(c(dca1l, dca2l, dca3l, dca4l))

percdca1 = dca1l * 100 / total
percdca2 = dca2l * 100 / total

percdca1 + percdca2
#  71.03683

#multipca <- pca(dune)
#vegan 里没有 pca(),用下面的：
library(labdsv)
multipca <- pca(dune)

plot(multivar)
plot(multipca)



