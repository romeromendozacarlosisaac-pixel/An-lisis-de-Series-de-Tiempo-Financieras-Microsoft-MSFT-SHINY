# Análisis de Series de Tiempo Financieras — Microsoft (MSFT)

Aplicación interactiva desarrollada en R Shiny para el análisis exploratorio de series de tiempo financieras del dataset de Microsoft (MSFT).

> Proyecto desarrollado por **Carlos Romero** y **Paula Gómez** — Grupo 1.

---

## Cómo ejecutar la app localmente

### Requisitos previos

Tener instalado **R** y **RStudio**:
- Descargar R: [cran.r-project.org](https://cran.r-project.org)
- Descargar RStudio: [posit.co/download/rstudio-desktop](https://posit.co/download/rstudio-desktop/)

---

### Paso 1 — Instalar los paquetes necesarios

Abre RStudio y ejecuta esto en la **consola** (panel inferior izquierdo):

```r
install.packages(c("shiny", shinydashboard", "tidyverse", "DT", "plotly", "lubridate", "dplyr", "zoo", "forecast"))
```

---

### Paso 2 — Descargar y ejecutar la app

Copia y pega el siguiente bloque completo en la consola de RStudio y presiona **Enter**:

```r
temp <- tempfile()
download.file(
  "https://github.com/romeromendozacarlosisaac-pixel/An-lisis-de-Series-de-Tiempo-Financieras-Microsoft-MSFT-SHINY/archive/refs/heads/main.zip",
  destfile = paste0(temp, ".zip"),
  mode = "wb"
)
unzip(paste0(temp, ".zip"), exdir = temp)
shiny::runApp(file.path(temp, "An-lisis-de-Series-de-Tiempo-Financieras-Microsoft-MSFT-SHINY-main"))
```

La app se abrirá automáticamente en tu navegador.

---

## Estructura del repositorio

```
├── ui.R              # Interfaz de usuario
├── server.R          # Lógica del servidor
├── global.R          # Variables y librerías globales
├── MSFT_data.csv     # Dataset de Microsoft
├── www/              # Recursos estáticos (imágenes, estilos)
└── requirements.txt  # Lista de paquetes requeridos
```

---

## Solución de problemas

**Error al descargar:** Verifica tu conexión a internet e intenta de nuevo.

**Error de paquete no encontrado:** Instala el paquete faltante con `install.packages("nombre_del_paquete")` y vuelve a correr el Paso 2.

**La app no abre en el navegador:** RStudio puede abrir la app en su propio visor. Busca el botón **"Open in Browser"** en la parte superior del visor para verla en tu navegador.
