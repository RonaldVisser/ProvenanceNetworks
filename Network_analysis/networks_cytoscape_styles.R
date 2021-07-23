library(RCy3)
library(igraph)
library(RColorBrewer)

# run after means_networks.R

cytoscapePing() # check connection

# colour style for pie charts (community 1 = colour 1)
display.brewer.pal(n = 10, name = 'Paired')

# import style with grey nodes
importVisualStyles(filename = "cytoscape/GreyNodes.xml")

# delete default styles
deleteVisualStyle("Big Labels")
deleteVisualStyle("BioPAX")
deleteVisualStyle("BioPAX_SIF")
deleteVisualStyle("Curved")
deleteVisualStyle("default black")
deleteVisualStyle("Directed")
deleteVisualStyle("Gradient1")
deleteVisualStyle("Marquee")
deleteVisualStyle("Minimal")
deleteVisualStyle("Nested Network Style")
deleteVisualStyle("Ripple")
deleteVisualStyle("Sample1")
deleteVisualStyle("Sample2")
deleteVisualStyle("Sample3")
deleteVisualStyle("Solid")
deleteVisualStyle("Universe")


cyto_create_graph <- function(type = 1) {
  # due to errors on first creation tryCatch added that does remove and create network again
  tryCatch({createNetworkFromIgraph(get(paste0("g_means_", type)), paste0("means_", type), collection = paste0("Means_type_",type), style.name="GreyNodes")},
           error=function(cond){
             deleteNetwork()
             createNetworkFromIgraph(get(paste0("g_means_", type)), paste0("means_", type), collection = paste0("Means_type_",type), style.name="GreyNodes")
           })
  setVisualStyle("GreyNodes")
  loadTableData(get(paste0("g_means_", type, "_cpm_com_table")),data.key.column="node")
  loadTableData(get(paste0("g_means_", type, "_gn")),data.key.column="node")
  layoutNetwork(layout.name="kamada-kawai")
  setNodeLabelMapping("id", style.name="GreyNodes")
}

cyto_create_cpm_style <- function(type = 1, k=3) {
  copyVisualStyle("GreyNodes", paste0("Means_type_",type, "_CPM(k=", k, ")"))
  setNodeCustomPieChart(unique(get(paste0("g_means_", type, "_cpm_k", k))$com_name), 
                        colors = brewer.pal(10, "Paired"), 
                        style.name = paste0("Means_type_",type, "_CPM(k=", k, ")"))
  setVisualStyle(paste0("Means_type_",type, "_CPM(k=", k, ")"))  
}

cyto_create_gn_style <- function(type = 1) {
  setVisualStyle("GreyNodes")
  copyVisualStyle("GreyNodes", paste0("Means_type_",type, "_GN"))
  colourCount = length(unique(get(paste0("g_means_", type, "_gn"))$com_name))
  getPalette = colorRampPalette(brewer.pal(10, "Paired"))
  setNodeColorMapping(table.column = "com_name", 
                      table.column.values = unique(get(paste0("g_means_", type, "_gn"))$com_name), 
                      colors = getPalette(colourCount), 
                      mapping.type = "d",
                      style.name=paste0("Means_type_",type, "_GN"))
  setVisualStyle(paste0("Means_type_",type, "_GN"))  
}

for (t in 1:4){
  cyto_create_graph(t)
  cyto_create_gn_style(t)
  if (t>=3) {kmax = 8}
  else {kmax = 5}
  for (k in 3:kmax){
    cyto_create_cpm_style(t,k)
  }
}

deleteVisualStyle("size_rank")

closeSession(save.before.closing = TRUE, filename = "export/communities_means_simple.cys")
