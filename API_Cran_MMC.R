# Para instalar la API CRAN para acceder a todos los metadatos de los paquetes CRAN R
# library(devtools)
# devtools::install_github("metacran/crandb")

library(pkgsearch)
library(magrittr)

skip_lines <- function(text, head = 1e6, tail = 1e6) {
  text <- strsplit(text, "\n")[[1]]
  tail <- min(tail, max(0, length(text) - head))
  skip_text <- if (length(text) > head + tail) {
    paste("\n... not showing", length(text) - head - tail, "lines ...\n")
  } else {
    character()
  }
  c(head(text, head), skip_text, tail(text, tail)) %>%
    paste(collapse = "\n")
}
DB <- function(api, head = 1e6, tail = head) {
  paste0("http://crandb.r-pkg.org", "/", api) %>%
    httr::GET() %>%
    httr::content(as = "text", encoding = "UTF-8")
}

# Instala librería para conectarse con MongoDB
# install.packages("mongolite", dependencies = TRUE)

library(mongolite)
library(jsonlite)

m <- mongo(collection = "R_versions", db = "DB_CRAN")

#versions <- releases()
#versions
#m$insert(versions)

versions <- fromJSON(DB("/-/releases"))
m$insert(versions)

# Para contar el número de registros de la conexión
m$count()

# Insertando información de paquetes CRAN

m_pkgs <- mongo(collection = "R_packages", db = "DB_CRAN")

pkgs <- fromJSON(DB("/-/all"))

for(i in 1:length(pkgs) ) {
  m_pkgs$insert(pkgs[i])
}

#DB("/-/all?limit=1")