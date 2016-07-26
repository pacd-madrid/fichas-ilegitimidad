# Script para crear las fichas de ilegtimidad de la PACD

# URL de la hoja de cálculo con los datos
url.data <- "https://docs.google.com/spreadsheets/d/1zda2z0b09o-XUY-RdOWpcKgg-tbgn3d3syDijnKtX4s/pub?gid=176454935&single=true&output=csv"
library(RCurl)
library(rmarkdown)
library(yaml)

# Librería para la realización de mapas con google maps.
#library(plotGoogleMaps)

options(scipen=999)

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
n <- ncol(data)-4

# Función que obiene el nombre normalizado para una ficha. 
getName <- function (x) {
  name <- gsub(" ", "-", tolower(iconv(x, to='ASCII//TRANSLIT')))
  name <- gsub("/", "-", name)
  return(name)
}

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
  require(imager)
  file.name <- paste(getName(y[2]), ".Rmd", sep="")
  file.create(file.name)
  yamlheader <- as.yaml(list(title=as.character(y[2]), date=substr(y[1],1,10)))
  write(paste("---\n", yamlheader,"---\n\n", sep=""), file=file.name, append=T)
  write(unlist(Map(render.field, x[3:n], y[3:n])), file=file.name, append=T)
  # Descargar fotos
  url.photos <- trimws(unlist(strsplit(gsub("open\\?", "uc?export=download&", y[20]), ",")))
  photos <- NULL
  if (length(url.photos)>0) {
    for (i in 1:length(url.photos)) {
      photos[i] <- paste("img/", getName(y[2]), "-", i, ".jpg", sep="")
      download.file(url.photos[i], photos[i], method="wget", mode="w")
      photo <- load.image(photos[i])
      photo <- resize(photo, size_x = -300/width(photo)*100, size_y = -300/width(photo)*100)
      save.image(photo, paste("img/", getName(y[2]), "-small-", i, ".jpg", sep=""))
      write(paste('<img src="', photos[i], '"> <br/>', sep=""), file = file.name, append = T)
    }
  } 
  render_site(file.name)
}

lapply(1:nrow(data), function(i) render.record(headers, data[i,]))

render_site()

# Envío de correos al Ayuntamiento
library(mailR)
fichas-
sender <- "asalber@gmail.com"
recipients <- c("asalber@gmail.com")
baseurl <- "http://pacd-madrid.github.io/fichas-ilegitimidad/"
for (x in data[2,])
send.mail(from = sender,
          to = recipients,
          subject=paste("Ficha de presunta ilegitimidad:", x),
          body = paste("Les remitimos una nueva ficha de presunta ilegitimidad de la Auditoría Ciudadana del Ayuntamiento de Madrid. 
          Pueden acceder a la ficha por medio del siguiente enlace:\n", getName(x)),
          smtp = list(host.name = "smtp.gmail.com", port = 465, 
                      user.name="asalber@gmail.com", passwd="pzdhzsducwjelxyi", ssl=TRUE),
          authenticate = TRUE,
          send = TRUE)
