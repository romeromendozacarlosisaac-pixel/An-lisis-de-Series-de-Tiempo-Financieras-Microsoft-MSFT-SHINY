# --- Archivo: global.R ---
library(shiny)
library(shinydashboard)
library(tidyverse)
library(DT)
library(plotly)
library(dplyr)
library(lubridate)
library(zoo)
library(forecast)


# ── Datos históricos ──────────────────────────────────────────
msft     <- read.csv("MSFT_data.csv")
msft$Date  <- as.Date(msft$Date)
msft$Close <- as.numeric(msft$Close)
msft_raw   <- msft[order(msft$Date), ]

year_min <- lubridate::year(min(msft$Date))
year_max <- lubridate::year(max(msft$Date))

# ── Modelo ARIMA — carga UNA sola vez ─────────────────────────
bundle <- readRDS("arima_bundle.rds")
modelo <- bundle$modelo



cat("Datos y modelo cargados correctamente\n")