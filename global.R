# INICIALIZAR
library(shiny)
library(dplyr)
library(lubridate)
library(scales) # formato porcentaje
library(tools) # texto capital
library(stringr) # familia apply
library(ggplot2)
library(DT) # para tablas
library(tidyr) # función spread
library(shinyWidgets) # sliderTextInput

# directorio de datos
path <- "C:/Users/Edgar/Documents/Agroasemex/SISTEMA_INFORMACION_OPORTUNA/SIO"
# nombre del archivo
file_name <- "/ER.csv"
rds_name <- "/ER_manipulado.rds"
# Carga la base de datos en formato RDS
df <- readRDS(paste0(path, rds_name))

# opciones
opciones_institucion <- sort(unique(df$INSTITUCION))
opciones_operacion <- sort(unique(df$OPERACION))
opciones_descripcion <- sort(unique(df$DESCRIPCION))
opciones_fecha <- unique(df$TRIMESTRE)