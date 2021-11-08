library(RPostgreSQL)
library(getPass)

pg_db <- 'romhout'

choice_tbl <- readline(prompt = "Do you have a comparison of a) means; b) means and series; or c) series?")

# choose data table
# and make rownames same as field names in db for easier import
if (choice_tbl == "a" | choice_tbl == "A") {
  db_tbl <- 'mean_with_mean'
  colnames(total) <- c("Mean_A","Radius_A","Mean_B","Radius_B","overlap","r","r_wuchs","t","t_wuchs","SGC","SSGC","p")
} else if (choice_tbl == "b" | choice_tbl == "B") {
  db_tbl <- 'series_with_means'
  colnames(total) <- c("Mean","Mean_Radius","Series","Series_Radius","overlap","r","r_wuchs","t","t_wuchs","SGC","SSGC","p")
} else if (choice_tbl == "c" | choice_tbl == "C") {
  db_tbl <- 'series_with_series'
  colnames(total) <- c("Series_A","Radius_A","Series_B","Radius_B","overlap","r","r_wuchs","t","t_wuchs","SGC","SSGC","p")
} else {
  choice_tbl <- readline(prompt = "Wrong choice. Do you have a comparison of a) means; b) means and series; or c) series?")
}

#
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user='postgres', password=getPass::getPass(), dbname=pg_db)
#

#total <- total[!is.infinite(total$t),]
#total <- total[!is.infinite(total$t_wuchs),]

dbWriteTable(con, db_tbl, as.data.frame(total), append=TRUE, row.names = FALSE)
