# Envío de correos de las fichas de ilegitimidad al Ayuntamiento

# URL de la hoja de cálculo con los datos de las fichas
url.data <- "https://docs.google.com/spreadsheets/d/1zda2z0b09o-XUY-RdOWpcKgg-tbgn3d3syDijnKtX4s/pub?gid=176454935&single=true&output=csv"

# Carga de los datos
require(RCurl)
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)

# Función que obiene el nombre normalizado para una ficha. 
getName <- function (x) {
  name <- gsub(" ", "-", tolower(iconv(x, to='ASCII//TRANSLIT')))
  name <- gsub("/", "-", name)
  return(name)
}

load("fichas.enviadas.Rda")


enviar.ficha <- function (ficha){
  require(mailR)
  sender <- "madridauditamadrid@gmail.com"
  recipients <- c("auditoria@madrid.es")
  send.mail(from = sender,
            to = recipients,
            subject=paste("Nueva ficha de presunta ilegitimidad:", ficha), 
            body = paste("Desde la Auditoría Ciudadana de la Deuda del Ayuntamiento de Madrid os remitimos una nueva ficha de presunta ilegitmidad que hemos recibido. Podéis acceder a los detalles de la ficha a través del siguiente enlace:\n\n",
                         "http://pacd-madrid.github.io/fichas-ilegitimidad/", getName(ficha), ".html\n\n", "Un saludo.", sep=""),
            smtp = list(host.name = "smtp.gmail.com", port = 465, user.name = "madridauditamadrid@gmail.com", passwd = "audita16", ssl = TRUE),
            authenticate = TRUE,
            send = TRUE)
  
}

for (ficha in data[["Título"]]) {
  if (!any(grepl(ficha,fichas.enviadas[["ficha"]]))){
    enviar.ficha(ficha)
    fichas.enviadas <- rbind(fichas.enviadas, setNames(as.list(c(ficha)), names(fichas.enviadas)), stringsAsFactors=FALSE)
  }
}

save(fichas.enviadas, file="fichas.enviadas.Rda")


# URL de la hoja de cálculo con los datos de las peticiones de información
url.data <- "https://docs.google.com/spreadsheets/d/1L_kLylhVReaL7GiL1Q0PJjx_b6yWOf2EPuk4bxiOIEU/pub?gid=1250269168&single=true&output=csv"
# Carga de los datos
require(RCurl)
data <- read.csv(text = getURL(url.data, .encoding = "UTF-8"), encoding = "UTF-8", header = T, stringsAsFactors = F)

peticiones.enviadas = data.frame(peticion=character())
load("fichas.enviadas.Rda")


save(peticiones.enviadas, file="fichas.enviadas.Rda")

