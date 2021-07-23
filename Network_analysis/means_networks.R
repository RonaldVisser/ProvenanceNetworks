library(igraph)
library(tidyverse)
library(ggpubr)

source("clique_community_names.R")
source("gn_names.R")

#load and analyse networks (degree)
for (n in 1:4) {
  assign(paste0("means_", n), read.csv(paste0("data/means_network_", n, ".csv")))
  assign(paste0("means_", n, "_netw"), get(paste0("means_", n)) %>% select(1, 3))
  assign(paste0("means_", n, "_netw"), unique(get(paste0("means_", n, "_netw"))))
  write.csv(get(paste0("means_", n, "_netw")),paste0("data/means_network_", n, "_simple.csv"),row.names = FALSE)
  assign(paste0("g_means_",n), graph.data.frame(get(paste0("means_", n, "_netw")), directed=FALSE))
  assign(paste0("g_means_",n), igraph::simplify(get(paste0("g_means_",n))))
  assign(paste0("g_means_",n,"_deg"), as.data.frame(table(degree(get(paste0("g_means_",n))))))
  assign(paste0("g_means_",n,"_deg"), setNames(get(paste0("g_means_",n, "_deg")), c('degree','count')))
  write.csv(get(paste0("g_means_",n, "_deg")), file = paste0("export/means_network_", n , "_degree_dist.csv"))
  assign(paste0("g_means_",n,"_degree_powerlaw"), fit_power_law(degree(get(paste0("g_means_",n)))))
}

g_means_1_deg$network <- 1
g_means_2_deg$network <- 2
g_means_3_deg$network <- 3
g_means_4_deg$network <- 4
degree_total <- rbind(g_means_1_deg, g_means_2_deg, g_means_3_deg, g_means_4_deg)
degree_total$degree <- as.numeric(degree_total$degree)

ggplot(degree_total, aes(x=degree,y=count,colour=factor(network))) +
  geom_point() + scale_y_log10() + scale_x_log10() +
  geom_smooth(method = "lm", se = FALSE) + labs(colour = "Network type")# +
ggsave("export/means_network_powerlaw.png", width = 10, height = 8, dpi = 600)


# find communities (CPM and Girvan/Newman)

for (n in 1:4) {
  for (i in 3:clique_num(get(paste0("g_means_",n)))) {
    assign(paste0("g_means_", n, "_cpm_k",i), clique_community_names(get(paste0("g_means_",n)),i))
    if (i==3) {
      assign(paste0("g_means_", n, "_com"), get(paste0("g_means_", n, "_cpm_k",i)))}
    else {
      assign(paste0("g_means_", n, "_com"), rbind(get(paste0("g_means_", n, "_com")),get(paste0("g_means_", n, "_cpm_k",i))))
    }
  }
  assign(paste0("g_means_", n, "_cpm_com_table"), get(paste0("g_means_", n, "_com")) %>% count(node, com_name) %>% spread(com_name, n)) 
  assign(paste0("g_means_", n, "_gn"), gn_names(get(paste0("g_means_",n))))
  assign(paste0("g_means_", n, "_com"), rbind(get(paste0("g_means_", n, "_com")),get(paste0("g_means_", n, "_gn"))))
  assign(paste0("g_means_", n, "_com"), get(paste0("g_means_", n, "_com")) %>% add_column(networktype = n))
  write.csv(get(paste0("g_means_", n, "_com")),paste0("export/mean_communities_type", n, ".csv"))
}

mean_com <- rbind(g_means_1_com,g_means_2_com,g_means_3_com,g_means_4_com)
write.csv(mean_com,"export/mean_communities.csv", row.names = FALSE)

count_coms <- mean_com %>% 
  group_by(networktype, com_name) %>% 
  count(com_name)
write.csv(count_coms,"export/mean_communities_count.csv")
