# Beta diversity calculate
#
# The function named 'BetaDiv'
# which do beta-diversity analysis including PCoA, NMDS, LDA, DCA, CCA, RDA, MDS, PCA
#
# You can learn more about package at:
#
#   https://github.com/microbiota/amplicon

#' @title Beta diversity plotting
#' @description Input otutab, metadata and tree or phyloseq object; support 47 distance type (bray, unifrac, wunifrac ...),  8 ordination method (PCoA, NMDS, ...); output ggplot2 figure, data and statistical test result.
#' @param otu OTU/ASV table;
#' @param map Sample metadata;
#' @param tree tree/nwk file;
#' @param dist distance type, including "unifrac" "wunifrac" "dpcoa" "jsd" "manhattan" "euclidean"   "canberra" "bray" "kulczynski"  "jaccard" "gower" "altGower" "morisita" "horn" "mountford"  "raup" "binomial"  "chao"  "cao" "w"  "-1"  "c" "wb"  "r"   "I"  "e" "t" "me"   "j"  "sor"  "m"   "-2"  "co";
#' @param group group ID;
#' @param method DCA, CCA, RDA, NMDS, MDS, PCoA, PCA, LDA;
#' @param pvalue.cutoff Pvalue threshold;
#' @param Micromet statistics by adonis/anosim/MRPP;
#' @details
#' By default, input phyloseq object include metadata, otutab and tree
#' The available diversity indices include the following:
#' \itemize{
#' \item{most used indices: bray, unifrac, wunifrac}
#' \item{other used indices: manhattan, euclidean, jaccard ...}
#' }
#' @return list object including plot, stat table
#' @author Contact: Tao Wen \email{2018203048@@njau.edu.cn}, Yong-Xin Liu \email{yxliu@@genetics.ac.cn}
#' @references
#'
#' Jingying Zhang, Yong-Xin Liu, Na Zhang, Bin Hu, Tao Jin, Haoran Xu, Yuan Qin, Pengxu Yan, Xiaoning Zhang, Xiaoxuan Guo, Jing Hui, Shouyun Cao, Xin Wang, Chao Wang, Hui Wang, Baoyuan Qu, Guangyi Fan, Lixing Yuan, Ruben Garrido-Oter, Chengcai Chu & Yang Bai.
#' NRT1.1B is associated with root microbiota composition and nitrogen use in field-grown rice.
#' Nature Biotechnology, 2019(37), 6:676-684, DOI: \url{https://doi.org/10.1038/s41587-019-0104-4}
#'
#' @seealso beta_pcoa beta_cpcoa
#' @examples
#'
#' BetaDiv(otu = otutab_rare, map = metadata, tree = tree, group = "Group", dist = "bray", method = "PCoA", Micromet = "adonis", pvalue.cutoff = 0.05)
#'
#' @export

BetaDiv = function(otu = otutab, map = metadata, tree = tree, ps = NULL,
                   group = "Group", dist = "bray", method ="PCoA",
                   Micromet = "adonis", pvalue.cutoff = 0.05){

  # 需要的R包
  library(phyloseq)
  library(vegan)
  library(ggplot2)

  # 读取默认参数
  # otu = otutab
  # map = metadata
  # tree = tree
  # ps = NULL
  # group = "Group"
  # dist = "bray"
  # method ="PCoA"
  # Micromet = "adonis"
  # pvalue.cutoff = 0.05

  # 根据距离编号转换名称
  # dist_methods = unlist(phyloseq::distanceMethodList)
  # dist = dist_methods[dist]
  # dist

  # 数据导入PhyloSeq格式
  if (is.null(otu)&is.null(map)) {
    ps = ps
  }else{
    #导入otu表格
    otu = as.matrix(otu)
    # str(otu)
    # #导入注释文件
    # tax = as.matrix(tax)
    # taxa_names(tax)

    #导入分组文件
    # colnames(map) = gsub(group, "AA", colnames(map))
    # map$Group = map$AA
    map$Group = map[, group]
    map$Group = as.factor(map$Group)
    # map$Group
    # #导入进化树
    # tree = read.tree("./otus.tree")
    # tree
    ps = phyloseq(otu_table(otu, taxa_are_rows=TRUE),
                   sample_data(map)
                   # phy_tree(tree)
    )
  }

  # 只有使用树相关的距离算法时，读取树
  # dist_methods = unlist(distanceMethodList)
  if (dist %in% c("unifrac" , "wunifrac",  "dpcoa")) {
    phy_tree(ps) = tree
  }

# 求取相对丰度#----
ps1_rela = transform_sample_counts(ps, function(x) x / sum(x) )
# ps1_rela

# 排序方法选择#----

#---------如果选用DCA排序
if (method == "DCA") {
  # method = "DCA"
  ordi = phyloseq::ordinate(ps1_rela, method=method, distance=dist)
  #提取样本坐标
  points = ordi$rproj[,1:2]
  colnames(points) = c("x", "y") #命名行名
  #提取特征值
  eig = ordi$evals^2
}

#---------CCA排序#----
if (method == "CCA") {
  # method = "CCA"
  ordi = ordinate(ps1_rela, method=method, distance=dist)
  #样本坐标,这里可选u或者v矩阵
  points = ordi$CA$v[,1:2]
  colnames(points) = c("x", "y") #命名行名
  #提取特征值
  eig = ordi$CA$eig^2
}

#---------RDA排序#----
if (method == "RDA") {
  # method ="RDA"
  ordi = ordinate(ps1_rela, method=method, distance=dist)
  #样本坐标,这里可选u或者v矩阵
  points = ordi$CA$v[,1:2]
  colnames(points) = c("x", "y") #命名行名
  #提取特征值
  eig = ordi$CA$eig
}

#---------DPCoA排序#----
# 不用做了，不选择这种方法了，这种方法运行太慢了

#---------MDS排序#----
if (method == "MDS") {
  # method = "MDS"
  # ordi = ordinate(ps1_rela, method=ord_meths[i], distance=dist)
  ordi = ordinate(ps1_rela, method=method, distance=dist)
  #样本坐标
  points = ordi$vectors[,1:2]
  colnames(points) = c("x", "y") #命名行名
  #提取解释度
  eig = ordi$values[,1]
}

#---------PCoA排序#----
if (method == "PCoA") {
  # method = "PCoA"
  unif = phyloseq::distance(ps1_rela , method=dist, type="samples")
  #这里请记住pcoa函数
  pcoa = cmdscale(unif, k=2, eig=T) # k is dimension, 3 is recommended; eig is eigenvalues
  points = as.data.frame(pcoa$points) # 获得坐标点get coordinate string, format to dataframme
  colnames(points) = c("x", "y") #命名行名
  eig = pcoa$eig
}

#----PCA分析#----
vegan_otu =  function(physeq){
  OTU =  otu_table(physeq)
  if(taxa_are_rows(OTU)){
    OTU =  t(OTU)
  }
  return(as(OTU,"matrix"))
}

otu_table = as.data.frame(t(vegan_otu(ps1_rela )))
# head(otu_table)
# method = "PCA"
if (method == "PCA") {
  otu.pca = prcomp(t(otu_table), scale. = TRUE)
  #提取坐标
  points = otu.pca$x[,1:2]
  colnames(points) = c("x", "y") #命名行名
  # #提取荷载坐标
  # otu.pca$rotation
  # 提取解释度,这里提供的并不是特征值而是标准差，需要求其平方才是特征值
  eig=otu.pca$sdev
  eig=eig*eig
}

# method = "LDA"
#---------------LDA排序#----
if (method == "LDA") {
  #拟合模型
  library(MASS)
  data = t(otu_table)
  # head(data)
  data = as.data.frame(data)
  # data$ID = row.names(data)
  data = scale(data, center = TRUE, scale = TRUE)
  dim(data)
  data1 = data[,1:10]
  map = as.data.frame(sample_data(ps1_rela))
  model = lda(data, map$Group)

  # 提取坐标
  ord_in = model
  axes = c(1:2)
  points = data.frame(predict(ord_in)$x[, axes])
  colnames(points) = c("x", "y") #命名行名
  # 提取解释度
  eig= ord_in$svd^2
}

#---------------NMDS排序#----
# method = "NMDS"
if (method == "NMDS") {
  #---------如果选用NMDS排序
  # i = 5
  # dist = "bray"
  ordi = ordinate(ps1_rela, method=method, distance=dist)
  #样本坐标,
  points = ordi$points[,1:2]
  colnames(points) = c("x", "y") #命名行名
  #提取stress
  stress = ordi$stress
  stress= paste("stress",":",round(stress,2),sep = "")
}


#---------------t-sne排序#----
# method = "t-sne"
if (method == "t-sne") {
  data = t(otu_table)
  # head(data)
  data = as.data.frame(data)
  # data$ID = row.names(data)
  #
  data = scale(data, center = TRUE, scale = TRUE)

  dim(data)
  map = as.data.frame(sample_data(ps1_rela))
  row.names(map)
  #---------tsne
  # install.packages("Rtsne")
  library(Rtsne)

  tsne = Rtsne(data,perplexity = 3)

  # 提取坐标
  points = as.data.frame(tsne$Y)
  row.names(points) =  row.names(map)
  colnames(points) = c("x", "y") #命名行名
  stress= NULL
}


#----差异分析#----

#----整体差异分析#----
title1 = MicroTest(ps = ps1_rela, Micromet = Micromet, dist = dist)
title1

#----两两比较#----
pairResult = pairMicroTest(ps = ps1_rela, Micromet = Micromet, dist = dist)


#----绘图#----
map = as.data.frame(sample_data(ps1_rela))
map$Group = as.factor(map$Group)
colbar = length(levels(map$Group))

points = cbind(points, map[match(rownames(points), rownames(map)), ])
# head(points)
points$ID = row.names(points)

#---定义配色#----
# 改为使用Rcolorbrewer的颜色组合
mi = colorRampPalette(c( "#CBD588", "#599861", "orange","#DA5724", "#508578", "#CD9BCD",
                         "#AD6F3B", "#673770","#D14285", "#652926", "#C84248",
                         "#8569D5", "#5E738F","#D1A33D", "#8A7C64","black"))(colbar)
# mi

#----定义图形通用样式#----
main_theme = theme(panel.grid.major=element_blank(),panel.grid.minor=element_blank(),
      plot.title = element_text(vjust = -8.5,hjust = 0.1),
      axis.title.y =element_text(size = 7,face = "bold",colour = "black"),
      axis.title.x =element_text(size = 7,face = "bold",colour = "black"),
      axis.text = element_text(size = 7,face = "bold"),
      axis.text.x = element_text(colour = "black",size = 7),
      axis.text.y = element_text(colour = "black",size = 7),
      legend.text = element_text(size = 7,face = "bold")
      #legend.position = "none"#是否删除图例
)

if (method %in% c("DCA", "CCA", "RDA",  "MDS", "PCoA","PCA","LDA")) {
  p2 =ggplot(points, aes(x=x, y=y, fill = Group)) +
    geom_point(alpha=.7, size=5, pch = 21) +
    labs(x=paste0(method," 1 (",format(100*eig[1]/sum(eig),digits=4),"%)"),
         y=paste0(method," 2 (",format(100*eig[2]/sum(eig),digits=4),"%)"),
         title=title1) +
    stat_ellipse(linetype=2,level=0.68,aes(group=Group, colour=Group))+
    scale_colour_manual(values = mi,guide = guide_legend(title = NULL))+
    scale_fill_manual(values = mi,guide = guide_legend(title = NULL))+
    guides(color=guide_legend(title = NULL),shape=guide_legend(title = NULL))
  # p2
  p2 = p2+theme_bw()+
    geom_hline(aes(yintercept=0), colour="black", linetype=2) +
    geom_vline(aes(xintercept=0), colour="black", linetype="dashed") +
    main_theme
  p2
  library(ggrepel)
  p3 = p2+geom_text_repel(aes(label=points$ID),size = 5)
  p3
}


if (method %in% c("NMDS","t-sne")) {
  p2 =ggplot(points, aes(x=x, y=y, fill = Group)) +
    geom_point(alpha=.7, size=5, pch = 21) +
    labs(x=paste(method,"1", sep=""),
         y=paste(method,"2",sep=""),
         title=stress)+
    stat_ellipse( linetype = 2,level = 0.65,aes(group  =Group, colour =  Group))+
    scale_colour_manual(values = mi,guide = guide_legend(title = NULL))+
    scale_fill_manual(values = mi,guide = guide_legend(title = NULL))+
    guides(color=guide_legend(title = NULL),shape=guide_legend(title = NULL))
  p2
  p2 = p2+theme_bw()+
    geom_hline(aes(yintercept=0), colour="black", linetype=2) +
    geom_vline(aes(xintercept=0), colour="black", linetype="dashed") +
    main_theme
  library(ggrepel)
  p3 = p2+geom_text_repel( aes(label=points$ID),size=4)
  p3
  if (method %in% c("t-sne")) {
    supp_lab = labs(x=paste(method,"1", sep=""),y=paste(method,"2",sep=""),title=title)
   p2 = p2 + supp_lab
   p3 = p3 + supp_lab
  }
  p2
}

# 返回结果：标准图，数据，标签图，成对比较结果，整体结果
return(list(p2,points,p3,pairResult,title1))
}
