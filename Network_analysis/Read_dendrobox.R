library(tcltk)
library(dplyr)
library(RPostgreSQL)
library(dplR)
library(reshape2)
library(getPass)

folder_csv <- tk_choose.dir(default = "", caption = "Select directory with csv-files from dendrobox")
setwd(folder_csv)
#sub_dirs <- list.dirs()
file_names <- list.files(pattern = "\\.csv$", ignore.case=TRUE)

#
# csv2rwl does not work on csv with single column

#errordir <- file.path(folder_csv,"errors")

for(i in 1:length(file_names)) {
  dat <- read.table(file_names[i], header=TRUE, sep=",")
  rownames(dat) <- as.character(dat[,1])
  colnames(dat) <- rep(gsub('.{4}$', '', file_names[i]),2)
  # check for missing rings and add those in data frame as NA
  if (length(dat[,1]) != max(dat[,1])-min(dat[,1])+1) {
    years <- data.frame(min(dat[,1]):max(dat[,1]))
    rownames(years) <- as.character(years[,1])
    dat2 <- merge(years, dat, by = "row.names", all = TRUE)
    rownames(dat2) <- rownames(years)
    # correct column names altered by merge
    colnames(dat2)[4] <- colnames(dat2)[3]
    dat <- dat2[,c(1,4)]
    # replace missing rings (NA) with 0
    dat[is.na(dat)] <- 0
  }
  if (i==1){
    treering <- dat[,2, drop=F]
  } else {
      treering <- combine.rwl(treering, dat[,2, drop=F])
  }
}
# remove duplicate tree ring series
treering_duplicated <- treering[, duplicated(t(treering)), drop=F]
treering <- treering[, !duplicated(t(treering))]

write.rwl(treering, "all_trees.rwl", format = "tucson")

# check for missing rings
missing_rings <- treering == 0
#nzeros <- table(missing_rings)["TRUE"] 
# check for missing rings
if (length(missing_rings) > 0) {
  missing_rings <- apply(missing_rings,2,which)
  missing_rings <- lapply(missing_rings,length)
  # place series with too many missing rings in seperate dataframe
  max_missing = 5
  ex_mr = missing_rings[missing_rings>=max_missing]
  vec_ex_mr <- unlist(names(ex_mr))
  treering_mr <- treering[ ,names(treering) %in% vec_ex_mr]
  # continue analysis with series with less dan "max_missing" rings
  treering <- treering[ ,!names(treering) %in% vec_ex_mr]
}
write.rwl(treering, "all_trees_less5mr.rwl", format = "tucson")
write.rwl(treering_mr, "all_trees_more5mr.rwl", format = "tucson")
write.tridas(treering, fname = "all_trees_less5mr.tridas", prec = 0.01)

# source: https://github.com/cran/dplR/blob/master/R/rwi.stats.running.R
# method = c("spearman", "pearson", "kendall")
cor.with.limit <- function(limit, x, y, method) {
  n.x <- ncol(x) # caller makes sure that n.x
  n.y <- ncol(y) # and n.y >= 1
  r.mat <- matrix(NA_real_, n.x, n.y)
  for (i in seq_len(n.x)) {
    this.x <- x[, i]
    good.x <- !is.na(this.x)
    for (j in seq_len(n.y)) {
      this.y <- y[, j]
      good.y <- !is.na(this.y)
      good.both <- which(good.x & good.y)
      n.good <- length(good.both)
      if (n.good >= limit && n.good > 0) {
        r.mat[i, j] <- cor(this.x[good.both], this.y[good.both],
                           method = method)
      }
    }
  }
  r.mat
}
# end function
# calculate spearman correlation matrix
corr_treering <- cor.with.limit(25,treering,treering,"spearman")
colnames(corr_treering) <- rownames(corr_treering) <- colnames(treering)
# list with names and correlation
list_cor <- subset(melt(corr_treering,value.name = "r"))

# SGC
GC_result <- GC_par(treering,overlap=25)
SGC_mat <- GC_result[[1]]
SSGC_mat <- SGC_mat
# mirror lower triagle to upper
SSGC_mat[upper.tri(SSGC_mat)] <- t(SSGC_mat)[upper.tri(SSGC_mat)]
diag(SSGC_mat) <- 0
list_SSGC <- subset(melt(SSGC_mat), value.name = "SSGC")
# mirror upper triangle to lower
SGC_mat[lower.tri(SGC_mat)] <- t(SGC_mat)[lower.tri(SGC_mat)]
diag(SGC_mat) <- 1
list_SGC <- subset(melt(SGC_mat), value.name = "SGC")
Overlap_n <- GC_result[[2]]
Overlap_n[lower.tri(Overlap_n)] <- t(Overlap_n)[lower.tri(Overlap_n)]
list_overlap <- subset(melt(Overlap_n,value.name = "overlap"))

# p.matrix 
size_ol <- dim(Overlap_n)
q <- matrix(1,size_ol[1],size_ol[2]) 
s_mtx= q /(2*sqrt(Overlap_n));
z_mtx=(SGC_mat-0.5)/s_mtx;
p_mtx=2*(1-pnorm(z_mtx,0,1));
list_p<- subset(melt(p_mtx,value.name = "p"))

total <- merge(list_cor,list_SGC,by=c("Var1","Var2"))
total <- merge(total,list_SSGC,by=c("Var1","Var2"))
total <- merge(total,list_overlap,by=c("Var1","Var2"))
total <- merge(total,list_p,by=c("Var1","Var2")) 
colnames(total) <- c("series_a","series_b","r","sgc","ssgc","overlap","p")

# connect to database
drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, user='postgres', password=getPass::getPass(), dbname='dendrobox')

dbWriteTable(con, "similarities", total, append=TRUE, row.names = FALSE)
