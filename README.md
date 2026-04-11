## Requisitos previos

- R (versión 4.0 o superior)
- RStudio (recomendado)

### Instalar dependencias

Todos los paquetes necesarios están listados en el archivo `requirements.txt`. Para instalarlos, ejecuta en la consola de R:

```r
paquetes <- readLines("requirements.txt")
install.packages(paquetes)
```

---

## Cómo ejecutar la app

### Opción 1 — Desde RStudio
1. Clona el repositorio:
```bash
git clone https://github.com/tu-usuario/tu-repositorio.git
```
2. Abre RStudio y establece la carpeta del proyecto como directorio de trabajo:
```r
setwd("ruta/a/la/carpeta")
```
3. Abre `ui.R` o `server.R` y haz clic en **Run App**

### Opción 2 — Desde la consola de R
```r
library(shiny)
runApp("ruta/a/la/carpeta")
```

---
