# Script para crear las fichas de ilegtimidad de la PACD
library(rmarkdown)
library(airtabler)
library(dplyr)

# Librería para la realización de mapas con google maps.
#library(plotGoogleMaps)

options(scipen=999)

# Carga de los datos desde Google Drive
# require(RCurl)
# url.data <- "https://docs.google.com/spreadsheets/d/1zda2z0b09o-XUY-RdOWpcKgg-tbgn3d3syDijnKtX4s/pub?gid=176454935&single=true&output=csv"
# data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)

# Carga de datos desde AIRTABLE
Sys.setenv(AIRTABLE_API_KEY="keyZOgDPeLEn3Me8q")
datos <- airtable(base = "appe7uLXI2oMZ033Y", tables = c("Distritos", "Fichas ilegitimidad"))
datos.distritos <- datos$Distritos$select()
datos.fichas <- datos$`Fichas ilegitimidad`$select()
# PREPOCESAMIENTO DE DATOS
datos.distritos$createdTime <- NULL
datos.fichas$createdTime <- NULL
# Añadir los distritos a las fichas desde la tabla de distritos
for (i in 1:nrow(datos.fichas)) {
  distritos <- c()
  for (j in unlist(datos.fichas[i,"Distrito"])) {
    distritos <- c(distritos, datos.distritos[datos.distritos$id==j,]$Nombre)
  }
  datos.fichas[[i,"Distrito"]] <- distritos
}

# GENERACIÓN DE FICHAS
for (i in 1:nrow(datos.fichas)){
  ficha = datos.fichas[i,]
  render('plantilla-ficha.Rmd',
         output_format = "md_document", 
         output_file =  paste0(gsub(" ","-",ficha$Título), ".Rmd"),
         output_dir = '.',
         quiet = TRUE)
}

render_site()
#clean_site()
