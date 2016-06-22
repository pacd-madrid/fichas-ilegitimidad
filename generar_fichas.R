# Script para crear las fichas de ilegtimidad de la PACD

# URL de la hoja de cálculo con los datos
url.data <- "https://docs.google.com/spreadsheets/d/1zda2z0b09o-XUY-RdOWpcKgg-tbgn3d3syDijnKtX4s/pub?gid=176454935&single=true&output=csv"
library(RCurl)
library(rmarkdown)
library(yaml)
# Librería para la realización de mapas con google maps.
#library(plotGoogleMaps)

# Carga de los datos
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)
headers <- gsub(".", " ", names(data), fixed=T)

# Sustitución de comas por cambio de línea en campos de indicios
for (i in 7:13){
  data[,i] <- trimws(gsub(",", "\n-", data[,i]), "l")
  data[i] <- sapply(data[i], function(x) ifelse(is.na(x) | x=="", "", paste("-",x)))
}
# Añadir € al campo de Importe
data[,6] <- paste(format(data[,6], big.mark="."), "€")

# Número de columnas a procesar (las dos últimas no se procesan al tener datos confidenciales)
n <- ncol(data)-3

#' Title
#' Función que crea una cadena en formato Rmardown con el contenido de una sección de la ficha.
#'
#' @param name Cadena con el encabezado de la sección.
#' @param field Cadena con el contenido de la sección.
#'
#' @return Cadena con una sección de la ficha en formato Rmarkdown.
#' @export
#'
#' @examples
render.field <- function(name, field){
  return(paste("## ", name, "\n", field, "\n\n", sep=""))
}

#' Title
#' Función que crea un fichero con el contenido de una ficha en formato Rmarkdown. 
#' El nombre del fichero en formato Rmarkdown se toma del segundo campo que se supone es el título de ficha.
#' @param x Vector con los encabezados de sección.
#' @param y Vector con los contenidos de las secciones.
#'
#' @return None
#' @export
#'
#' @examples
render.record <- function(x, y){
  file.name <- paste(gsub(" ", "-", y[2]), ".Rmd", sep="")
  file.create(file.name)
  yamlheader <- as.yaml(list(title=as.character(y[2]), date=substr(y[1],1,10)))
  write(paste("---\n", yamlheader,"---\n\n", sep=""), file=file.name, append=T)
  write(unlist(Map(render.field, x[3:n], y[3:n])), file=file.name, append=T)
  render_site(file.name)
}


#' Función que genera todas las fichas en formato Rmarkdown.
#'
#' @param data Data frame con los registros de las fichas.
#'
#' @return None
#' @export
#'
#' @examples
render.all.records <- function(data){
  require(knitr)
  # Generar el índice
  file.create("index.Rmd")
  yamlheader <- "---
title: Fichas de gastos presuntamente ilegítimos
output:
  html_document:
    toc: false
    toc_float: false
    includes:
      before_body: doc_prefix_index.html
---\n\n"
  write(yamlheader, file="index.Rmd", append=T)
  write(unlist(lapply(data[,2], function(x) paste("- [", x, "](", gsub(" ", "-", x), ".html)\n", sep=""))), file="index.Rmd", append=T)
  write("\n\n## Mapa de gastos presuntamente ilegítimos", file="index.Rmd", append=T)
  write("\n```{r, echo=FALSE}
require(leaflet)
m <- leaflet() %>%
  setView(lng=-3.70453, lat=40.41358, zoom = 12) %>%
  addTiles()", file="index.Rmd", append=T)
  # Función que imprime un marcador para cada ilegitimidad
  coord <- function (x){
    co <- unlist(strsplit(x, ","))
    return (paste("lng=", co[2], ", lat=", co[1], sep=""))
  }
  write(unlist(lapply(data[,ncol(data)], function(x) paste("  addMarkers(", coord(x), ", popup=\"", x, "\")", sep=""))), file="index.Rmd", append=T)
  write("m\n```\n", file="index.Rmd", append=T)
  knit("index.Rmd")
  # Generar las fichas
  lapply(1:nrow(data), function(i) render.record(headers, data[i,]))
}

render.all.records(data)

render_site()

# Mapa de ilegitimidades
library(leaflet)



