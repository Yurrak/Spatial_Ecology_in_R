# This code is related to multivariate analysis of RS data
#这课是在丰富图像的描述维度，光谱告诉你"颜色"，纹理告诉你"结构"，两者结合让分类更准确。
#原始Sentinel图像（3波段）
#↓
#重命名波段，明确NIR/Red/Green
#↓
#pairs() 探索波段相关性 → 发现Red和Green高度冗余
#↓
#PCA降维 → 提取PC1（去冗余、综合信息）
#↓
#focal() 提取纹理特征（局部标准差）
#├── sd3：基于NIR的纹理
#└── pcsd3：基于PC1的纹理
#↓
#可视化对比两种纹理特征




library(terra)
library(imageRy)
library(ggplot2)
library(patchwork)
library(viridis)

sent <- im.import("sentinel.png")
sent

p1 <- im.ggplot(sent[[1]])
p2 <- im.ggplot(sent[[2]])
p3 <- im.ggplot(sent[[3]])

p1 + p2 + p3
#不显示，用下面code代替
library(gridExtra)
grid.arrange(p1, p2 , p3, ncol=2, nrow=2)

pairs(sent)
#波段相关性（上三角数字）
#波段1 vs 波段2：0.06 → 几乎不相关
#波段1 vs 波段3：0.049 → 几乎不相关
#波段2 vs 波段3：0.98 → 极高度正相关

#散点图（下三角）
#波段2 和 波段3 的散点图呈现近乎完美的对角线，与 0.98 的相关系数吻合
#波段1 与其他两个波段的散点图则较为分散

# names of the bands
names(sent) <- c("b01_nir", "b02_red", "b03_green")
#波段1是NIR，所以它和其他两个波段相关性很低（0.06/0.049）
#因为NIR和可见光反射特性差异大。

pairs(sent)

sentpc <- im.pca(sent)
#im.pca() 是对这三个波段做主成分分析，去除冗余，尤其是解决波段2和3之间 0.98 相关性的问题

pcsd3 <- focal(sentpc[[1]], w=3, fun="sd")
plot(pcsd3)
#sentpc[[1]]取PCA结果的第一主成分 PC1
#w=3以每个像素为中心，取 3×3 的滑动窗口
#fun="sd"在这个窗口内计算标准差
#值大区域）= 局部像素变化大 = 地物复杂/边缘
#值小区域）= 局部像素变化小 = 地物均匀单一

sd3 <- focal(sent[[1]], w=3, fun="sd")

p1 <- im.ggplot(sd3)
p2 <- im.ggplot(pcsd3)

p1 + p2
grid.arrange(p1, p2, ncol=2)
#最直观的差异：色条范围不同，NIR波段的像素值本身就在0~255范围内，标准差自然大；而PC1经过PCA变换后数值范围被压缩了，所以标准差也小很多。但这不影响纹理模式的比较，只是量纲不同。
#两张图的亮线、亮点位置高度吻合：这其实印证了之前 pairs() 的结论——PC1本身就主要由NIR波段主导（因为NIR与其他两个波段相关性低，信息独特，PCA后大部分方差集中在PC1里），所以两者纹理图长得很像。
#右图（PC1）的纹理线条看起来稍微更细、更锐利一些，因为PC1综合了三个波段去除冗余后的信息，噪声相对更少。
#两张图传达的纹理信息基本一致，NIR单波段纹理已经能很好代表整体纹理特征，PC1纹理是它的"精炼版"。
