library(knitcitations)
library(bibtex)
library(stringr)

# download data-file from publication
temp <- tempfile()
download.file("https://doi.org/10.5334/jcaa.79.s1", temp, mode="wb")
unz(temp, "s1-jcaa-79_visser/79-1922-1-SP.csv")
cited_data <- read.csv(unz(temp, "s1-jcaa-79_visser/79-1922-1-SP.csv"))
unlink(temp)

#cited_data <- read.csv("data/79-1922-1-SP.csv")

for (i in 1:nrow(cited_data)) {
  citet(str_remove(cited_data$DOI[i], "https://doi.org/"))
}

write.bibtex(file = "export/data_citation.bib") 
