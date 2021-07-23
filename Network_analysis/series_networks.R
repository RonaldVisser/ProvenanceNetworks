library(igraph)
library(tidyverse)
library(ggpubr)

source("clique_community_names.R")
source("gn_names.R")

#load and analyse networks (degree)

for (n in 1:4) {
  assign(paste0("series_", n), read.csv(paste0("data/series_network_", n, ".csv")))
  assign(paste0("series_", n, "_netw"), get(paste0("series_", n)) %>% select(1, 3))
  assign(paste0("series_", n, "_netw"), unique(get(paste0("series_", n, "_netw"))))
  write.csv(get(paste0("series_", n, "_netw")),paste0("data/series_network_", n, "_simple.csv"),row.names = FALSE)
  assign(paste0("g_series_",n), graph.data.frame(get(paste0("series_", n, "_netw")), directed=FALSE))
  assign(paste0("g_series_",n), igraph::simplify(get(paste0("g_series_",n))))
  assign(paste0("g_series_",n,"_deg"), as.data.frame(table(degree(get(paste0("g_series_",n))))))
  assign(paste0("g_series_",n,"_deg"), setNames(get(paste0("g_series_",n, "_deg")), c('degree','count')))
  write.csv(get(paste0("g_series_",n, "_deg")), file = paste0("export/series_network_", n , "_degree_dist.csv"))
  assign(paste0("g_series_",n,"_degree_powerlaw"), fit_power_law(degree(get(paste0("g_series_",n)))))
  write.csv(get(paste0("g_series_",n, "_degree_powerlaw")), file = paste0("export/series_network_", n , "_degree_powerlaw.csv"))
}

g_series_1_deg$network <- 1
g_series_2_deg$network <- 2
g_series_3_deg$network <- 3
g_series_4_deg$network <- 4
degree_series_total <- rbind(g_series_1_deg, g_series_2_deg, g_series_3_deg, g_series_4_deg)
degree_series_total$degree <- as.numeric(degree_series_total$degree)

ggplot(degree_series_total, aes(x=degree,y=count,colour=factor(network))) +
  geom_point() + scale_y_log10() + scale_x_log10() +
  geom_smooth(method = "lm", se = FALSE) + labs(colour = "Network type")# +
ggsave("export/series_network_powerlaw.png", width = 10, height = 8, dpi = 600)

# find communities (CPM and Girvan/Newman)
for (n in 1:4) {
  for (i in 3:clique_num(get(paste0("g_series_",n)))) {
    assign(paste0("g_series_", n, "_cpm_k",i), clique_community_names(get(paste0("g_series_",n)),i))
    if (i==3) {
      assign(paste0("g_series_", n, "_com"), get(paste0("g_series_", n, "_cpm_k",i)))}
    else {
      assign(paste0("g_series_", n, "_com"), rbind(get(paste0("g_series_", n, "_com")),get(paste0("g_series_", n, "_cpm_k",i))))}
  }
  assign(paste0("g_series_", n, "_cpm_com_table"), get(paste0("g_series_", n, "_com")) %>% count(node, com_name) %>% spread(com_name, n)) 
  assign(paste0("g_series_", n, "_gn"), gn_names(get(paste0("g_series_",n))))
  assign(paste0("g_series_", n, "_com"), rbind(get(paste0("g_series_", n, "_com")),get(paste0("g_series_", n, "_gn"))))
  assign(paste0("g_series_", n, "_com"), get(paste0("g_series_", n, "_com")) %>% add_column(networktype = n))
  write.csv(get(paste0("g_series_", n, "_com")),paste0("export/series_communities_type", n, ".csv"))
}  

mean_com <- rbind(g1_com,g2_com,g3_com,g4_com)
write.csv(mean_com,"export/series_communities.csv")

# percentage of degree of in network
sum(g_series_4_deg$count[as.numeric(g_series_4_deg$degree) >= 10])/sum(g_series_4_deg$count)
sum(g_series_4_deg$count[as.numeric(g_series_4_deg$degree) <= 4])/sum(g_series_4_deg$count)

sum(g_series_1_deg$count[as.numeric(g_series_1_deg$degree) >= 10])/sum(g_series_1_deg$count)
sum(g_series_1_deg$count[as.numeric(g_series_1_deg$degree) <= 2])/sum(g_series_1_deg$count)

