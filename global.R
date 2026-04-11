# --- Archivo: global.R ---

# Cargar las librerías necesarias
library(shiny)
library(tidyverse)
library(DT) # Para tablas interactivas
library(plotly) # Para gráficos interactivos
library(dplyr)
library(lubridate)

# Cargar y preparar los datos
msft <- read.csv("MSFT_data.csv")

# Calculo del retorno logaritmico 
msft$Date <- as.Date(msft$Date)
msft$Close <- as.numeric(msft$Close)


year_min <- year(min(msft$Date))
year_max <- year(max(msft$Date))

# Mensaje de confirmación en la consola
cat("Datos cargados y preprocesados en global.R\n")