# Code for graph theory in ecology

# install.packages("igraph") # run once
library(igraph)

species <- c("Algae", "Zooplankton", "Small Fish", "Large Fish", "Bird")

predator <- c("Zooplankton", "Small Fish", "Large Fish", "Bird", "Bird")
prey <- c("Algae", "Zooplankton", "Small Fish", "Small Fish", "Large Fish")

interactions <- data.frame(predator, prey)
#两个向量一一对应，共同描述5条捕食关系
#这一步的目的是把零散的物种和关系数据整理成结构化的表格，为下一步用 igraph 构建生态网络图做准备。

g <- graph_from_data_frame(interactions, vertices = species, directed = T)
#graph_from_data_frame()igraph 包的核心函数，专门用来从数据框创建图结构
#igraph 默认把数据框的第一列当捕食者（起点），第二列当猎物（终点）
plot(g)


g <- graph_from_data_frame(interactions, vertices = species, directed = F)
plot(g)
#每次运行都会重新随机计算节点的布局位置，R 没有记忆上一次的摆放方式。所以图方向会变


# set.seed() function
set.seed(42) 
# 固定随机种子，每次布局相同
g <- graph_from_data_frame(interactions, vertices = species, directed = T)
plot(g)

g <- graph_from_data_frame(interactions, vertices = species, directed = F)
plot(g)


#以下为自学内容：
# 或者手动指定布局算法
layout <- layout_with_fr(g)  # 先计算好位置
plot(g, layout = layout)     # 每次用同一个位置
g <- graph_from_data_frame(interactions, vertices = species, directed = T)
plot(g)

g <- graph_from_data_frame(interactions, vertices = species, directed = F)
plot(g)



g <- graph_from_data_frame(interactions, vertices = species, directed = T)
plot(g)

degree(g) # 计算每个节点有多少条边连接，找出网络中最"重要"的物种
degree(g, mode = "in")   # 入度：被多少物种捕食
degree(g, mode = "out")  # 出度：捕食了多少物种
degree(g, mode = "all")  # 总度数
#入出度必须在有方向directed为t的时候才成立，否则会得到同样的结果
#度数高意味着连接很多物种 = 可能是关键种;Algae度数低 = 处于食物链底端

is_connected(g)          # 整个网络是否连通？返回 TRUE/FALSE
components(g)            # 有几个独立的子网络？
#连通性高 → 物种间联系紧密 → 生态系统牵一发动全身
#连通性低 → 存在孤立物种  → 局部灭绝影响较小


transitivity(g, type = "local")   # 每个物种的局部聚类系数
transitivity(g, type = "global")  # 整个网络的平均聚类系数
#聚类系数高 → 物种形成紧密的小群落（如某些共生群落）
#聚类系数低 → 物种关系较为分散、独立
#AlgaeNaN只有1条边，无法计算（邻居之间无法形成三角形）
#Zooplankton0.000邻居之间完全没有直接联系
#Small Fish0.333邻居之间有一定联系
#Large Fish1.000邻居之间全部互相连接
#Bird1.000邻居之间全部互相连接

#全局聚类系数 = 0.5 处于中间水平，说明这个生态网络：
#整体上有一定的"抱团"现象
#既不是完全线性的食物链（系数≈0）
#也不是高度复杂的网络（系数≈1）
