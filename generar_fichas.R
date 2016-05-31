# Script para crear las fichas de ilegtimidad de la PACD

url.data <- "https://docs.google.com/spreadsheets/d/1zda2z0b09o-XUY-RdOWpcKgg-tbgn3d3syDijnKtX4s/pub?gid=176454935&single=true&output=csv"
library(RCurl)
library(rmarkdown)
library(rmdformats)
# Carga de los datos
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)

print.field <- function(name, field){
  return(paste("## ", name, "\n", field, "\n\n", sep=""))
}

print.fields <- function(x, y){
  file.name <- paste("fichas/", gsub(" ", "-", y[2]), ".Rmd", sep="")
  file.create(file.name)
  write(gsub("TITULO", y[2], readChar("plantilla.Rmd", file.info("plantilla.Rmd")$size)), file=file.name, append=T)
  write(unlist(Map(print.field, x, y)), file=file.name, append=T)
  render(file.name)
}




#create.doc("index2", makefile=F)
render("index2/index2.Rmd")
rmarkdown::html_document(toc=TRUE, toc_depth = 2, template = "plantilla/ficha.html")



