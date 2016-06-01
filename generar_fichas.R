# Script para crear las fichas de ilegtimidad de la PACD

# URL de la hoja de cálculo con los datos
url.data <- "https://docs.google.com/spreadsheets/d/1zda2z0b09o-XUY-RdOWpcKgg-tbgn3d3syDijnKtX4s/pub?gid=176454935&single=true&output=csv"
library(RCurl)
library(rmarkdown)

# Carga de los datos
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)
headers <- gsub(".", " ", names(data), fixed=T)
n <- ncol(data)-2

render.field <- function(name, field){
  return(paste("## ", name, "\n", field, "\n\n", sep=""))
}

render.record <- function(x, y){
  file.name <- paste(gsub(" ", "-", y[2]), ".Rmd", sep="")
  file.create(file.name)
  write(paste("---\ntitle: ", y[2], "\ndate: ", y[1], "\n---\n\n", sep=""), file=file.name, append=T)
  write(unlist(Map(print.field, x[3:n], y[3:n])), file=file.name, append=T)
  render_site(file.name)
}


render.site <- function(data){
  # Generar el índice
  file.create("index.Rmd")
  write("---\ntitle: Fichas de gastos presuntamente ilegítimos\n---\n\n", file="index.Rmd", append=T)
  write(unlist(lapply(data[,2], function(x) paste("- [", x, "](", gsub(" ", "-", x), ".html)\n", sep=""))), file="index.Rmd", append=T)
  # Generar las fichas
  lapply(1:nrow(data), function(i) render.record(headers, data[i,]))
}

render.site(data)

render_site()
