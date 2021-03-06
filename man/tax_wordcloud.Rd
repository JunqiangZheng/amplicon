% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tax_wordcloud.R
\name{tax_wordcloud}
\alias{tax_wordcloud}
\title{Wordcloud plot relative abundance of taxonomy}
\usage{
tax_wordcloud(
  otu = otutab,
  map = metadata,
  tax = taxonomy,
  ps = NULL,
  j = "Phylum",
  group = "Group",
  facet = F,
  abundance = T,
  rand = 1
)
}
\arguments{
\item{otu}{OTU/ASV table;}

\item{map}{Sample metadata;}

\item{tax}{taxonomy file;}

\item{j}{taxonomy annotation classification level, typical including "Phylum","Class","Order","Family","Genus"}

\item{group}{group ID;}

\item{facet}{FALSE/F, if TURE/T, facet with Phylum in one of the "Class","Order","Family","Genus" level}

\item{abundance}{TRUE/T, show abundance in label, turn off in FLASE/F;}

\item{rand}{set reproducible layout, default 1, can set any integer;}
}
\value{
list object including plot and data table
}
\description{
Input otutab, metadata and taxonomy or phyloseq object; plot wordcloud to visualize compositional microbial community data
}
\details{
By default, input phyloseq object include metadata, otutab and metadata
The available classification level include the following:
\itemize{
\item{most used classification level was Phylum}
\item{other classification level include: Class, Order, Family, Genus }
}
}
\examples{
# Input feature table, metadata, taxonomy, group column name, and taxonomic level
# Output each group Phylum wordcloud with relative abundance in bracket
tax_wordcloud(otu = otutab, map = metadata, tax = taxonomy, group = "Group", j = "Phylum")
# Input feature table, metadata, taxonomy, group column name, and taxonomic level
# in Class, facet by Phylum, not show abundance, layout in seed 2
tax_wordcloud(otu = otutab, map = metadata, tax = taxonomy, group = "Group", j = "Class", facet = T, abundance = F, rand = 2)
}
\references{
Jingying Zhang, Yong-Xin Liu, Na Zhang, Bin Hu, Tao Jin, Haoran Xu, Yuan Qin, Pengxu Yan, Xiaoning Zhang, Xiaoxuan Guo, Jing Hui, Shouyun Cao, Xin Wang, Chao Wang, Hui Wang, Baoyuan Qu, Guangyi Fan, Lixing Yuan, Ruben Garrido-Oter, Chengcai Chu & Yang Bai.
NRT1.1B is associated with root microbiota composition and nitrogen use in field-grown rice.
Nature Biotechnology, 2019(37), 6:676-684, DOI: \url{https://doi.org/10.1038/s41587-019-0104-4}
}
\seealso{
wordcloud plot
}
\author{
Contact: Tao Wen \email{2018203048@njau.edu.cn}, Yong-Xin Liu \email{yxliu@genetics.ac.cn}
}
