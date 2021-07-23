library(sf)
library(ggplot2)
library(dplyr)
library(RPostgres)
library(GetPass)
library(rpostgis)
library(igraph)



# run after means_networks.R

#
drv <- dbDriver("PostgreSQL")
con <- dbConnect(RPostgres::Postgres(),    
                      host = "localhost",   
                      port = 5432,   
                      dbname = "romhout",   
                      user = "postgres",   
                      password=getPass::getPass() )

#
lines_table <- dbGetQuery(con, "SELECT * FROM public.lines_from_groups")

lines_table <- pgGetGeom(con, name=c("public","lines_from_groups"), geom = "line_geom") %>%
  st_as_sf()

sitechronologies <- st_read("data/Site-chronologies.gpkg")

network_prefix <- "g_means_"

for (t in 1:4){
  #spatial locations
  assign(paste0(network_prefix, t, "_points"),
         data.frame(node = V(get(paste0(network_prefix,t)))$name) %>%
           left_join(get(paste0(network_prefix, t, "_cpm_com_table"))) %>%
           left_join(get(paste0(network_prefix, t, "_gn"))) %>%
           inner_join(sitechronologies, c('node'='SiteChronology')) %>%
           st_as_sf()
         )
  # create spatial lines between nodes
  assign(paste0(network_prefix, t, "_lines"), 
         as.data.frame(as_edgelist(get(paste0(network_prefix,t)))) %>%
           inner_join(lines_table, c('V1' = 'Mean_A','V2' = 'Mean_B')) %>%
           st_as_sf()
         )
  # plot spatial network
  ggplot(get((paste0(network_prefix, t, "_lines")))) + geom_sf(colour = "grey") + 
    geom_sf(data = get(paste0(network_prefix, t, "_points")), aes(colour = com_name)) 
  ggsave(paste0("export/network_", t, "_spatial.png"))
  # export edges and nodes to geopackage
  st_write(get(paste0(network_prefix, t, "_lines")), paste0("export/network_", t, ".gpkg"), paste0("network_", t, "_edges"))
  st_write(get(paste0(network_prefix, t, "_points")), paste0("export/network_", t, ".gpkg"), paste0("network_", t, "_nodes"), append = TRUE)
  # create density plots for distances with facet_wrap over degree
  as.data.frame.table(distances(get(paste0(network_prefix,t)))) %>% 
    inner_join(lines_table, c('Var1' = 'Mean_A','Var2' = 'Mean_B')) %>%
    mutate(distance_km = as.numeric(st_length(geometry))/1000) %>%
    ggplot(aes(x=distance_km)) + geom_density() + facet_wrap(~Freq)
  ggsave((paste0("export/network_", t, "_degree_distance_density.png")))
  # create density plots for distances with facet_wrap over degree
  as.data.frame.table(distances(get(paste0(network_prefix,t)))) %>% 
    inner_join(lines_table, c('Var1' = 'Mean_A','Var2' = 'Mean_B')) %>%
    mutate(distance_km = as.numeric(st_length(geometry))/1000) %>%
    ggplot(aes(x=distance_km)) + geom_histogram(binwidth = 50) + facet_wrap(~Freq)
  ggsave((paste0("export/network_", t, "_degree_distance_histogram.png")))
  }

dbDisconnect(con)
dbUnloadDriver(drv)



