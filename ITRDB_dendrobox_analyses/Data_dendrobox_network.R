#library(RPostgreSQL)
library(RPostgres)
library(ggplot2)
library(tcltk)
library(getPass)
library(scales)
library(RColorBrewer)

# non scientific numbers                                                      
options(scipen=999)
# set working directory
folder_docs <- tk_choose.dir(default = "", caption = "Select working directory")
setwd(folder_docs)
# cite loaded packages
sink("cited_packages.bib")
out <- sapply(names(sessionInfo()$otherPkgs), 
              function(x) print(citation(x), style = "Bibtex"))
# connect to database
drv <- dbDriver("Postgres")
con <- dbConnect(drv, user='postgres', password=getPass::getPass(), dbname='dendrobox')
network_4 <- dbGetQuery(con, "select * from network_4")
network_4_qusp <- dbGetQuery(con, "select distinct * from (select * from distance_statistics_qusp
  where   r >= 0.5   AND overlap >= 50  and p <= 0.0001
  union
  select * from distance_statistics_qusp   where   r >= 0.5  AND overlap >= 50  and sgc >= 70)
  as tbl_oak")
network_4_abal <- dbGetQuery(con, "select distinct * from (select * from distance_statistics_abal
  where   r >= 0.5   AND overlap >= 50  and p <= 0.0001
                            union
                            select * from distance_statistics_abal   where   r >= 0.5  AND overlap >= 50  and sgc >= 70)
                            as tbl_abal")
network_4_pisy <- dbGetQuery(con, "select distinct * from (select * from distance_statistics_pisy
  where   r >= 0.5   AND overlap >= 50  and p <= 0.0001
                             union
                             select * from distance_statistics_pisy where   r >= 0.5  AND overlap >= 50  and sgc >= 70)
                             as tbl_pisy")


network_4_species <- dbGetQuery(con, "select distinct * from (select * from distance_statistics_species
  where   r >= 0.5   AND overlap >= 50  and p <= 0.0001
                             union
                             select * from distance_statistics_species where   r >= 0.5  AND overlap >= 50  and sgc >= 70)
                             as tbl_species where species in ('PISY','PCAB','QUSP','ABAL')")

# all species (LOG: `geom_smooth()` using method = 'gam' and formula 'y ~ s(x, bs = "cs")')
ggplot(network_4, aes(x=distance_m)) + geom_histogram() + scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_distance_histogram.png")
ggplot(network_4, aes(x=distance_m)) + 
  geom_density(fill = "grey", alpha = .5) + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001), limits = c(0,750000)) +
  xlab("distance")
ggsave("Network_4_distance_density.png", width = 5.5)
ggplot(network_4, aes(y=distance_m)) + geom_boxplot() + scale_y_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_distance_boxplot.png")

ggplot(network_4, aes(x=sgc)) + geom_density()
ggsave("Network_4_sgc_density.png")
ggplot(network_4, aes(x=ssgc)) + geom_density()
ggsave("Network_4_ssgc_density.png")
ggplot(network_4, aes(x=r)) + geom_density()
ggsave("Network_4_r_density.png")
ggplot(network_4, aes(x=overlap)) + geom_density()
ggsave("Network_4_overlap_density.png")

ggplot(network_4_qusp, aes(x=distance_m)) + geom_density() + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_QUSP_distance_density.png")
ggplot(network_4_qusp, aes(x=distance_m)) + geom_histogram() + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_QUSP_distance_histogram.png")
ggplot(network_4_qusp, aes(x=distance_m)) + geom_histogram(binwidth = 10000) + geom_density(aes(y=20000 * ..count..)) + scale_x_continuous(label=unit_format(unit="km", scale=0.001))  + ggtitle("QUSP") + theme(plot.title = element_text(hjust=0.5))
ggsave("Network_4_QUSP_distance_histogram_density.png")

ggplot(network_4_abal, aes(x=distance_m)) + geom_density() + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_ABAL_distance_density.png")
ggplot(network_4_abal, aes(x=distance_m)) + geom_histogram() + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_ABAL_distance_histogram.png")
ggplot(network_4_abal, aes(x=distance_m)) + geom_histogram(binwidth = 10000) + geom_density(aes(y=20000 * ..count..)) + scale_x_continuous(label=unit_format(unit="km", scale=0.001)) + ggtitle("ABAL") + theme(plot.title = element_text(hjust=0.5))
ggsave("Network_4_ABAL_distance_histogram_density.png")

ggplot(network_4_pisy, aes(x=distance_m)) + geom_density() + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_PISY_distance_density.png")
ggplot(network_4_pisy, aes(x=distance_m)) + geom_histogram() + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001))
ggsave("Network_4_PISY_distance_histogram.png")
ggplot(network_4_pisy, aes(x=distance_m)) + geom_histogram(binwidth = 10000) + geom_density(aes(y=20000 * ..count..)) + scale_x_continuous(label=unit_format(unit="km", scale=0.001)) + ggtitle("PISY") + theme(plot.title = element_text(hjust=0.5))
ggsave("Network_4_PISY_distance_histogram_density.png")

ggplot(network_4_species, aes(x=distance_m, fill = species)) + 
  geom_density(alpha=.5) + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001), limits = c(0,750000)) +
  xlab("distance")
ggsave("Network_4_Species_distance_density.png", width = 6.35)
#ggplot(network_4_species, aes(x=distance_m, fill = species)) + geom_density(alpha=.5) + scale_x_continuous(label=unit_format(unit="km", scale=0.001)) + scale_fill_brewer(palette="Dark2")
#ggplot(network_4_species, aes(x=distance_m, fill = species)) + geom_density(alpha=.5) + scale_x_continuous(label=unit_format(unit="km", scale=0.001)) + scale_fill_manual(values=c("#000000", "#009E73",  "#0072B2", "#D55E00")) 
#ggplot(network_4_species, aes(x=distance_m, color = species, alpha=.5)) + geom_density() + scale_x_continuous(label=unit_format(unit="km", scale=0.001)) + scale_color_manual(values=c("#000000", "#009E73",  "#0072B2", "#D55E00")) 


#ggplot(network_4_# all and species
ggplot(network_4_species, aes(x=distance_m, fill = species)) +
  geom_density(data=network_4, fill = 'grey', alpha=.5) + 
  geom_density(alpha=.5) + 
  geom_density(data=network_4, fill = 'grey', alpha=.5) + 
  scale_x_continuous(label=unit_format(unit="km", scale=0.001), limits = c(0,600000))

