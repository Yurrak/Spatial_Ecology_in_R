# This code will calculate spatial variability in remotely sensed imagery
#用遥感影像的空间变异性来预测生物多样性
#卫星影像（Sentinel）
#↓
#计算NIR波段的局部标准差（focal SD）
#↓
#SD高的地方 = 环境异质性高
#↓
#环境异质性高 = 能支持更多物种
#↓
#得到一张"预测生物多样性"的地图


library(terra)
library(imageRy)
library(ggplot2)
library(patchwork)
library(viridis)

# list of files
im.list()

# import the file
sent <- im.import("sentinel.png")
# layer 1 = NIR, layer 2 = red, layer 3 =green

im.plotRGB(sent, r=1, g=2, b=3)
im.plotRGB(sent, r=2, g=1, b=3)
im.plotRGB(sent, r=2, g=3, b=1)

sentmean <- focal(sent[[1]], w=3, fun="mean")

nir <- sent[[1]]
sd3 <- focal(sent[[1]], w=3, fun="sd")

p1 <- im.ggplot(nir)
p2 <- im.ggplot(sentmean)# 均值滤波后 → 更平滑，边界模糊
p3 <- im.ggplot(sd3)# 标准差 → 亮的地方=变异大=纹理丰富
#sd高：邻近像素差异大森林边缘、建筑物、农田边界
#sd低：邻近像素差异小均一森林内部、水体、裸地
#环境异质性越高 → 能支持的物种越多
#SD高的区域（环境变异大）→ 更多不同的微生境→ 更高的物种多样性

p1 + p2 + p3
#不显示，用下面code代替
library(gridExtra)
grid.arrange(p1, p2 , p3, ncol=2, nrow=2)

plot(sd3, col=magma(100))

# copy the im.ggplotRGB function from:
# https://github.com/ducciorocchini/imageRy/blob/main/R/im.ggplotRGB.R

p0 <- im.ggplotRGB(sent, r=2, g=1, b=3)
p0
p0 + p1 + p2 + p3
grid.arrange(p0, p1, p2 , p3, ncol=2, nrow=2)

#基础R绘图（im.plotRGB）= 打印机直接打印→ 按下按钮就出纸，没有"草稿"可以保存
#ggplot2（im.ggplotRGB）= 先写好Word文档，再点打印→ 文档可以存储、修改、复制、拼图

sd5 <- focal(nir, w=21, fun="sd")
#w=3 → 只看周围9个像素的差异
#w=5 → 看周围25个像素的差异
#w=21 → 像隔着毛玻璃看  → 只能看到大尺度的变异模式
#窗口越大→ 纳入更多邻近像素→ 局部差异被"稀释"→ 亮区扩散但单个亮线变粗

p4 <- im.ggplot(sd5)

p3 + p4
grid.arrange(p3, p4, ncol=2)


p0 + p3 + p4
grid.arrange(p0, p3, p4, ncol=2, nrow=2)
