# LIBRER�AS
library(data.table)
library(dplyr)
library(lubridate) # fechas
library(scales) # formato porcentaje
library(tools) # texto capital
library(stringr) # familia apply

# LECTURA DEL ARCHIVO
# directorio de datos
path <- "C:/Users/Edgar/Documents/Agroasemex/SISTEMA_INFORMACION_OPORTUNA/SIO"
# nombre del archivo
file_name <- "/ER.csv"
rds_name <- "/ER_manipulado.rds"
# carga del dataframe
df <- fread(paste0(path,file_name))

#' Limpiar dataframe
#' 
#' Esta funci�n toma un dataframe y lo devuelve limpiado y codificado.
#' 
#' @param df el dataframe le�do de la base.
#' @param cambiar_cod un booleano para determinar si se quiere o no codificar.
#' @return un dataframe con las columnas en formatos:
#' "TRIMESTRE":Date, "INSTITUCION":char, "OPERACION":char, 
#' "DESCRIPCION":char, "IMPORTE":num
#' @examples
#' limpiar_df(df, T): cambia codificaci�n
#' suma(df, F): no cambia codificaci�n
limpiar_df <- function(df, cambiar_cod) {
  # Cambiar codificaci�n en caso de necesitar
  if(cambiar_cod){
    df[, c("NOMBRE_CORTO", "DESC_OPERACION", "DESCRIPCION")] <- lapply(df[, c("NOMBRE_CORTO", "DESC_OPERACION", "DESCRIPCION")], 
                                                                       iconv, from = "LATIN1", to = "UTF-8")
  }
  # homologamos fechas a formato Date
  df$FECHA_CORTE <- ymd(df$FECHA_CORTE)
  # Formato title para los nombres cortos
  df$NOMBRE_CORTO <- str_to_title(tolower(df$NOMBRE_CORTO))
  # Quitamos s�mbolos *
  df$DESC_OPERACION <- gsub("[*]", "", df$DESC_OPERACION)
  # seleccionamos las columnas que necesitamos
  new_df <- df %>% 
    select(FECHA_CORTE, NOMBRE_CORTO, DESC_OPERACION, DESCRIPCION, IMPORTE)
  # cambiamos los nombres de las columnas
  colnames(new_df) <- c("TRIMESTRE", "INSTITUCION", "OPERACION", 
                        "DESCRIPCION", "IMPORTE")
  return(new_df)
}
# aplicamos la funci�n de limpieza
new_df <- limpiar_df(df, T)
# vemos c�mo est� el dataframe
str(new_df)
# guardamos en formato RDS
saveRDS(new_df, paste0(path, rds_name))

#' Creaci�n de tablas
#' 
#' Esta funci�n toma un dataframe y los criterios para la creaci�n de la 
#' tabla din�mica.
#' 
#' @param df el dataframe limpiado.
#' @param operacion char con el texto de la descripci�n de la operaci�n.
#' @param descripcion char con el texto de la descripci�n.
#' @param fecha char con el texto del trimestre.
#' @return un dataframe con la tabla din�mica
#' @examples
#' crear_tabla(new_df, "Agr�cola y de animales", "Tomado", "2019-12-31")
#' crear_tabla(new_df, "Riesgos Catastr�ficos", "Directo", "2020-06-30")
crear_tabla <- function(df, operacion, descripcion, fecha){
  td <- df %>%
    # filtrado
    filter(OPERACION == operacion) %>%
    filter(DESCRIPCION == descripcion) %>%
    filter(TRIMESTRE == ymd(fecha)) %>%
    # agrupaci�n por instituci�n
    group_by(INSTITUCION) %>%
    summarise(PRIMA = sum(IMPORTE)) %>%
    # primas y su porcentaje
    mutate(PORCENTAJE = percent(PRIMA/sum(PRIMA), accuracy=0.01)) %>% 
    # ordenamos
    arrange(-PRIMA)
  # cambiamos cambiamos nombres
  colnames(td) <- c("Instituci�n", "Prima", "Porcentaje")  
  return(td)
}

crear_tabla(new_df, "Agr�cola y de animales", "Tomado", "2019-12-31")
crear_tabla(new_df, "Riesgos Catastr�ficos", "Directo", "2020-06-30")
