# --- Archivo: ui.R  ---
library(shinydashboard)

# Define la UI (Interfaz de Usuario)
ui <- dashboardPage(skin = "purple",
    
    # 1. Cabecera del Dashboard
    dashboardHeader(
      title = tagList(
        # Usamos tags$img para añadir la imagen del logo
        tags$img(src = 'stock.svg', height = '45', style = "padding-right:10px;"),
        # Título de la App como texto simple
        "Análisis de Series de Tiempo Financieras — Microsoft (MSFT)"
      ),
      titleWidth = 700
    ),
    
    # 2. Barra Lateral de Navegación
    dashboardSidebar(
      width = 230,
      sidebarMenu(
        menuItem("Introducción",          tabName = "intro",      icon = icon("house")),
        menuItem("Objetivos",             tabName = "objetivos",  icon = icon("bullseye")),
        menuItem("Marco Teórico",         tabName = "marco",      icon = icon("book")),
        menuItem("Resultados Interactivos", tabName = "resultado", icon = icon("gears")),
        menuItem("Conclusiones",          tabName = "conclusiones", icon = icon("flag-checkered"))
      )
    ),
    
    
    
    # 3. Cuerpo del Dashboard
    
    
    dashboardBody(
      
      
      
      
      
      # --- CSS para centrar el contenido de las valueBox ---
      tags$head(
        tags$style(HTML("
.small-box .inner {
text-align: center;
}
.small-box h3, .small-box p {
text-align: center;
}
"))
      ),
      
      tabItems(
        tabItem(tabName = "intro",
                
                fluidRow(
                  column(12,
                         box(
                           title       = tagList(icon("house"), " Introducción"),
                           width       = 12,
                           status      = "primary",
                           solidHeader = TRUE,
                           
                           h4("Contexto General"),
                           p("El presente Análisis Exploratorio de Datos (EDA) tiene como objetivo estudiar el
                             comportamiento histórico de los precios de las acciones de Microsoft a partir de un conjunto
                             de datos diarios que incluye variables como los precios de apertura, máximo, mínimo y cierre
                             ajustado, así como el volumen de negociación. Este análisis se enmarca dentro del estudio de series
                             de tiempo financieras, donde el interés principal radica en comprender cómo evolucionan los precios
                             de una acción a lo largo del tiempo y qué patrones pueden identificarse en dicha evolución."),
                           
                           br(),
                           
                           h4("Contextualización"),
                           p("Microsoft fue fundada el 4 de abril de 1975 por Bill Gates y Paul Allen,
                             consolidándose como líder en el desarrollo de software. Un hito fundamental
                             fue su salida a bolsa el 13 de marzo de 1986, con un precio inicial de 21 USD por acción.
                             Este análisis trabaja con una serie temporal de frecuencia diaria, abarcando
                             desde el año 2000 hasta el 2026, lo que suma un total de 6,578 observaciones.
                             La serie se caracteriza por una tendencia alcista de largo plazo, con episodios
                             de alta volatilidad durante crisis financieras como la burbuja puntocom (2000-2002)
                             y la crisis financiera global (2008-2009). Además, se observa un crecimiento
                             exponencial reciente impulsado por servicios en la nube e inteligencia artificial."),
                           
                           br(),
                           
                           h4("Planteamiento del Problema"),
                           
                           p("El precio de las acciones de Microsoft (MSFT) constituye una serie de
  tiempo financiera con comportamientos complejos: tendencias de largo plazo,
  fluctuaciones abruptas y períodos de volatilidad diferenciada. Comprender
  esta dinámica histórica es esencial antes de aplicar cualquier modelo
  predictivo, ya que un análisis exploratorio riguroso permite identificar
  patrones, detectar anomalías y caracterizar estadísticamente el activo."),
                           
                           br(),
                           
                           p("Sin este paso previo, la aplicación de modelos de series de tiempo como
  ARIMA o GARCH carecería de fundamento empírico, aumentando el riesgo de
  modelar incorrectamente el comportamiento del precio."),
                           
                           br(),
                           
                           tags$div(
                             style = "background-color: #1a1a2e; border-left: 4px solid #7b61ff;
           padding: 15px; border-radius: 4px;",
                             tags$b(style = "color: #7b61ff;", "Pregunta de investigación:"),
                             br(), br(),
                             tags$em(style = "color: #ffffff;",
                                     "¿Qué patrones de retorno y volatilidad caracterizan el comportamiento
     histórico de la acción de Microsoft durante el período 2000–2026, y
     qué estructura presenta la serie como base para su modelación?"
                             )
                           )
                         )
                  )
                )
        ),
        
        # ── PESTAÑA 2: Objetivos y Justificación ────────────────────
        tabItem(tabName = "objetivos",
                
                fluidRow(
                  # Objetivo General
                  column(12,
                         box(
                           title       = tagList(icon("bullseye"), " Objetivo General"),
                           width       = 12,
                           status      = "primary",
                           solidHeader = TRUE,
                           
                           p("Evaluar la estructura estadística y la dinámica temporal de MSFT mediante un EDA robusto fundamentado en econometría financiera.")
                         )
                  )
                ),
                
                fluidRow(
                  # Objetivos Específicos
                  column(6,
                         box(
                           title       = tagList(icon("list-check"), " Objetivos Específicos"),
                           width       = 12,
                           status      = "info",
                           solidHeader = TRUE,
                           
                          
                           
                           tags$ul(
                             tags$li(
                               tags$b("Validar Estacionariedad: "),
                               "Aplicar la prueba ADF para identificar la presencia de raíces
     unitarias en la serie de precios de MSFT ",
                               tags$em("(Heimann, 2016)"), "."
                             ),
                             tags$li(
                               tags$b("Identificar Tendencia: "),
                               "Implementar medias móviles (\\(n=50\\), \\(n=200\\)) como herramienta
     de suavizamiento para mitigar el ruido en la serie temporal ",
                               tags$em("(Sureshkumar et al., 2013)"), "."
                             ),
                             tags$li(
                               tags$b("Analizar Riesgo: "),
                               "Determinar el grado de Leptocurtosis en la distribución de los
     retornos logarítmicos como medida del riesgo de cola ",
                               tags$em("(Mittnik et al., 2003)"), "."
                             ),
                             tags$li(
                               tags$b("Estabilizar la Serie: "),
                               "Transformar los precios en retornos logarítmicos para obtener
     una serie con varianza estable y propiedades estadísticas
     interpretables ",
                               tags$em("(Hudson y Litzenberg, 2015)"), "."
                             )
                           )
                         )
                  ),
                  
                  # Justificación
                  column(6,
                         box(
                           title       = tagList(icon("scale-balanced"), " Justificación"),
                           width       = 12,
                           status      = "info",
                           solidHeader = TRUE,
                           
                           p("El análisis exploratorio de datos aplicado a series de tiempo financieras
  representa un paso metodológico fundamental antes de cualquier proceso de
  modelación o predicción. En el caso particular de Microsoft (MSFT), uno de
  los activos más negociados del mercado global, comprender la estructura
  estadística de su precio histórico no solo tiene valor académico sino
  también implicaciones prácticas en la gestión del riesgo y la toma de
  decisiones de inversión.")
                         )
                  )
                )
        ),
        
        # ── PESTAÑA 3: Marco Teórico ─────────────────────────────────
        tabItem(tabName = "marco",
                
                fluidRow(
                  # Series de Tiempo
                  column(6,
                         box(
                           title       = tagList(icon("chart-line"), " Series de Tiempo Financieras"),
                           width       = 12,
                           status      = "primary",
                           solidHeader = TRUE,
                           
                           p("Una serie de tiempo es una secuencia de observaciones
            registradas en intervalos regulares. En finanzas, el precio
            diario de cierre de una acción constituye una serie de tiempo."),
                           
                           br(),
                           
                           h5("Precio de Cierre"),
                           p("El precio de cierre es el último precio al que se negoció
            un activo durante una sesión bursátil. Es la variable más
            utilizada para el análisis técnico y fundamental.")
                         )
                  ),
                  
                  # Retorno Logarítmico
                  column(6,
                         box(
                           title       = tagList(icon("wave-square"), " Retorno Logarítmico"),
                           width       = 12,
                           status      = "primary",
                           solidHeader = TRUE,
                           
                           p("El retorno logarítmico diario se define como:"),
                           
                           # Fórmula matemática con withMathJax
                           withMathJax(
                             helpText("$$r_t = \\ln\\left(\\frac{P_t}{P_{t-1}}\\right)$$")
                           ),
                           
                           p("Donde:"),
                           tags$ul(
                             tags$li("\\(r_t\\) es el retorno logarítmico en el período \\(t\\)"),
                             tags$li("\\(P_t\\) es el precio de cierre en \\(t\\)"),
                             tags$li("\\(P_{t-1}\\) es el precio de cierre en \\(t-1\\)")
                           ),
                           
                           br(),
                           
                           p("Es equivalente a:"),
                           withMathJax(
                             helpText("$$r_t = \\ln(P_t) - \\ln(P_{t-1})$$")
                           )
                         )
                  )
                ),
                
                fluidRow(
                  # Volatilidad
                  column(6,
                         box(
                           title       = tagList(icon("bolt"), " Volatilidad"),
                           width       = 12,
                           status      = "warning",
                           solidHeader = TRUE,
                           
                           p("La volatilidad es una medida de la dispersión de los retornos
            de un activo. Se estima mediante la desviación estándar de los
            retornos logarítmicos en una ventana rodante de tamaño \\(n\\):"),
                           
                           withMathJax(
                             helpText("$$\\sigma_t = \\sqrt{\\frac{1}{n-1}
                      \\sum_{i=0}^{n-1}(r_{t-i} - \\bar{r})^2}$$")
                           ),
                           
                           p("En este análisis se utilizan ventanas de:"),
                           tags$ul(
                             tags$li("20 días — aproximación mensual"),
                             tags$li("60 días — aproximación trimestral"),
                             tags$li("252 días — aproximación anual (días bursátiles)")
                           )
                         )
                  ),
                  
                  # Detección de Atípicos
                  column(6,
                         box(
                           title       = tagList(icon("triangle-exclamation"), " Detección de Anomalías"),
                           width       = 12,
                           status      = "warning",
                           solidHeader = TRUE,
                           
                           p("Se utiliza el método del rango intercuartílico (IQR) con
            un factor de 3.0 para identificar observaciones atípicas
            en los retornos:"),
                           
                           withMathJax(
                             helpText("$$\\text{Atípico si: } r_t < Q_1 - 3 \\cdot IQR
                      \\quad \\text{o} \\quad r_t > Q_3 + 3 \\cdot IQR$$")
                           ),
                           
                           p("Donde \\(IQR = Q_3 - Q_1\\) es el rango intercuartílico
            de los retornos logarítmicos.")
                         )
                  )
                ),
                
                fluidRow(
                  # Descomposición Estacional
                  column(12,
                         box(
                           title       = tagList(icon("layer-group"), " Descomposición de Series de Tiempo"),
                           width       = 12,
                           status      = "primary",
                           solidHeader = TRUE,
                           
                           p("La descomposición clásica separa una serie de tiempo en
            tres componentes:"),
                           
                           fluidRow(
                             column(4,
                                    tags$div(style = "text-align:center;",
                                             icon("arrow-trend-up", style = "font-size:2em; color:#26a69a;"),
                                             h5("Tendencia (T)"),
                                             p("Comportamiento de largo plazo de la serie.")
                                    )
                             ),
                             column(4,
                                    tags$div(style = "text-align:center;",
                                             icon("rotate", style = "font-size:2em; color:#f9a825;"),
                                             h5("Estacionalidad (S)"),
                                             p("Patrones periódicos que se repiten regularmente.")
                                    )
                             ),
                             column(4,
                                    tags$div(style = "text-align:center;",
                                             icon("shuffle", style = "font-size:2em; color:#ef5350;"),
                                             h5("Residuo (R)"),
                                             p("Variación no explicada por tendencia ni estacionalidad.")
                                    )
                             )
                           ),
                           
                           br(),
                           
                           p("Modelo aditivo:"),
                           withMathJax(helpText("$$Y_t = T_t + S_t + R_t$$")),
                           p("Modelo multiplicativo:"),
                           withMathJax(helpText("$$Y_t = T_t \\times S_t \\times R_t$$"))
                         )
                  )
                )
        ),
        #Contenido de la Pestaña 1: Análisis Exploratorio
        
        tabItem(tabName = "resultado",
                h1("Resultados Interactivos"),
                
                  # BLOQUE 1: RESUMEN DE CARACTERÍSTICAS DEL DATASET
                  
                  #Primera Línea de bloques
                  
                  fluidRow(
                    valueBox(
                      value    = nrow(msft),
                      subtitle = "Observaciones",
                      icon     = icon("database"),
                      color    = "navy",
                      width    = 3
                    ),
                    valueBox(
                      value    = ncol(msft),
                      subtitle = "Variables",
                      icon     = icon("table-columns"),
                      color    = "navy",
                      width    = 3
                    ),
                    valueBox(
                      value    = sum(is.na(msft)),
                      subtitle = "Valores Faltantes (NaN)",
                      icon     = icon("circle-exclamation"),
                      color    = "navy",
                      width    = 3
                    ),
                    valueBox(
                      value    = paste0(round(n_anios      <- as.numeric(difftime(max(msft$Date), min(msft$Date), units = "days")) / 365.25, 1), " años"),
                      subtitle = "Período analizado",
                      icon     = icon("calendar-days"),
                      color    = "navy",
                      width    = 3
                    )
                  ),
                  
                  #Segunda linea de bloques
                  
                  fluidRow(
                    valueBox(
                      value    = fecha_inicio <- format(min(msft$Date), "%d %b %Y"),
                      subtitle = "Fecha de Inicio",
                      icon     = icon("calendar-plus"),
                      color    = "navy",
                      width    = 3
                    ),
                    valueBox(
                      value    = fecha_fin    <- format(max(msft$Date), "%d %b %Y"),
                      subtitle = "Fecha de Fin",
                      icon     = icon("calendar-check"),
                      color    = "navy",
                      width    = 3
                    ),
                    valueBox(
                      value    = paste0("$", round(precio_max   <- max(msft$Close, na.rm = TRUE), 2)),
                      subtitle = "Precio Máximo (Close)",
                      icon     = icon("arrow-trend-up"),
                      color    = "navy",
                      width    = 3
                    ),
                    valueBox(
                      value    = paste0("$", round(precio_min   <- min(msft$Close, na.rm = TRUE), 2)),
                      subtitle = "Precio Mínimo (Close)",
                      icon     = icon("arrow-trend-down"),
                      color    = "navy",
                      width    = 3
                    )
                  ),
                  
                  #PESTAÑA
                  tabsetPanel(
                    type = "tabs",
                  
                  #BLOQUE 2: PRECIO DE CIERRE (CLOSE) A TRAVÉS DE LOS AÑOS
                tabPanel(
                    title = "Precio de Cierre / Velas",
                    icon = icon("chart-line"),
                  
                  fluidRow(
                    #Input que selecciona el tipo de grafico
                    column(4,
                           selectInput(
                             inputId = "tipo_grafico",
                             label   = tags$b(icon("chart-bar"), " Selección de Variable:"),
                             choices = c(
                               "Velas (OHLC)"        = "velas",
                               "Precio de Cierre"    = "cierre",
                               "Línea + Media Móvil" = "media_movil"
                             ),
                             selected = "velas"
                           )
                    ),
                    
                    #Input que selecciona la ventana temporal
                    column(8,
                           tags$b(icon("calendar"), " Ventana Temporal:"),
                           sliderInput(
                             inputId = "rango_anios",
                             label   = NULL,
                             min     = year_min,
                             max     = year_max,
                             value   = c(year_min, year_max),  # últimos 5 años por defecto
                             step    = 1,
                             sep     = "",          # sin separador de miles → "2021" no "2,021"
                             ticks   = TRUE
                           )
                    )
                  ),
                  
                  #Gráfico
                  fluidRow(
                    column(12,
                           plotlyOutput("grafico_velas", height = "550px")
                    )
                  )
                ),
                
                #BLOQUE 3: RETORNO LOGARITMICO
                
                tabPanel(
                  title = tagList(icon("wave-square"), " Retorno Logarítmico"),
                  
                  br(),
                  
                  #Métricas del retorno
                  
                  fluidRow(
                    valueBoxOutput("box_retorno_medio", width = 3),
                    valueBoxOutput("box_retorno_max",   width = 3),
                    valueBoxOutput("box_retorno_min",   width = 3),
                    valueBoxOutput("box_n_atipicos",    width = 3)
                  ),
                  
                  br(),
                  
                  #Gráfico
                  
                  fluidRow(
                    column(4,
                           sliderInput(
                             inputId = "rango_retorno",
                             label   = tags$b(icon("calendar"), " Ventana Temporal:"),
                             min     = year_min,
                             max     = year_max,
                             value   = c(year_min, year_max),
                             step    = 1,
                             sep     = ""
                           )
                    ),
                    
                    #Input para mostrar atipicos
                    
                    column(4,
                           checkboxInput(
                             inputId = "mostrar_atipicos",
                             label   = tags$b("Mostrar anomalías"),
                             value   = FALSE
                           )
                    ),
                    
                    #Input para mostrar el metodo de seleccion de los atipicos
                    
                    column(4,
                           selectInput(
                             inputId  = "metodo_atipico",
                             label    = tags$b("Método de detección:"),
                             choices  = c("IQR (×1.5)" = "iqr",
                                          "IQR (×3.0)" = "iqr3",
                                          "Z-Score (|z|>3)" = "zscore"),
                             selected = "iqr3"
                           )
                    )
                  ),
                  
                  fluidRow(
                    column(12,
                           plotlyOutput("grafico_retorno", height = "500px")
                    )
                  )
                ),
                
                #BLOQUE 4 DESCOMPOSICIÓN ESTACIONAL DEL PRECIO DE CIERRE
                
                tabPanel(
                  title = tagList(icon("layer-group"), " Descomposición Estacional"),
                  
                  br(),
                  
                  #INPUT para seleccionar el tipo de descomposición
                  
                  fluidRow(
                    column(4,
                           selectInput(
                             inputId  = "tipo_descomp",
                             label    = tags$b("Modelo de descomposición:"),
                             choices  = c("Aditivo"        = "additive",
                                          "Multiplicativo" = "multiplicative"),
                             selected = "multiplicative"
                           )
                    ),
                    
                    #Ventana temporal del gráfico
                    
                    column(4,
                           sliderInput(
                             inputId = "rango_descomp",
                             label   = tags$b(icon("calendar"), " Ventana Temporal:"),
                             min     = year_min,
                             max     = year_max,
                             value   = c(year_min, year_max),
                             step    = 1,
                             sep     = ""
                           )
                    )
                  ),
                  
                  #Gráfico
                  
                  fluidRow(
                    column(12,
                           plotlyOutput("grafico_descomp", height = "650px")
                    )
                  )
                ),
                
                
                #BLOQUE 5: VOLATIBILIDAD EN VENTANA TEMPORAL
                
                tabPanel(
                  title = tagList(icon("bolt"), " Volatilidad"),
                  
                  br(),
                  
                  #Algunas métricas de la volatibilidad
                  
                  fluidRow(
                    valueBoxOutput("box_vol_media",       width = 3),
                    valueBoxOutput("box_vol_max",         width = 3),
                    valueBoxOutput("box_fecha_vol_max",   width = 3),
                    valueBoxOutput("box_vol_actual",      width = 3)
                  ),
                  
                  br(),
                  
                  
                  #Input para elegir la ventana temporal
                  
                  fluidRow(
                    column(3,
                           selectInput(
                             inputId  = "ventana_vol",
                             label    = tags$b(icon("sliders"), " Ventana Rodante:"),
                             choices  = c(
                               "20 días"  = 20,
                               "60 días"  = 60,
                               "252 días"  = 252
                             ),
                             selected = 20   #por defecto 20 días
                           )
                    ),
                    #Slider de tiempo
                    column(5,
                           sliderInput(
                             inputId = "rango_vol",
                             label   = tags$b(icon("calendar"), " Período:"),
                             min     = year_min,
                             max     = year_max,
                             value   = c(year_min, year_max),
                             step    = 1,
                             sep     = ""
                           )
                    ),
                    #Input para superponer el precio de cierre
                    column(4,
                           br(),
                           checkboxInput(
                             inputId = "superponer_precio",
                             label   = tags$b("Superponer precio de cierre"),
                             value   = FALSE
                           )
                    )
                  ),
                  
                  fluidRow(
                    column(12,
                           plotlyOutput("grafico_volatilidad", height = "500px")
                    )
                  )
                )
              )
          
        ),
        
        # ── PESTAÑA 5: Conclusiones ──────────────────────────────────
        tabItem(tabName = "conclusiones",
                
                fluidRow(
                  column(12,
                         h4("Conclusiones del Análisis Estructural (2000–2026)"),
                         
                         p("Tras evaluar 26 años de historia bursátil de Microsoft (MSFT), se
  presentan los hallazgos fundamentales para el diseño de modelos
  predictivos."),
                         
                         br(),
                         
                         # ── Hallazgo 1 ────────────────────────────────────────────────
                         tags$div(
                           style = "background-color: white; border-left: 4px solid #ef5350;
           padding: 15px; border-radius: 4px; margin-bottom: 15px;",
                           tags$b(style = "color: #ef5350;", "1. Ineficiencia de la Serie Original"),
                           br(), br(),
                           p(style = "margin:0;",
                             "La serie de precios no es estacionaria. La persistencia en la ACF y
     la tendencia alcista exponencial confirman que el precio de cierre no
     puede ser modelado directamente sin riesgo de regresiones espurias.
     La transformación a Log-Returns es obligatoria."
                           )
                         ),
                         
                         # ── Hallazgo 2 ────────────────────────────────────────────────
                         tags$div(
                           style = "background-color: white; border-left: 4px solid #f9a825;
           padding: 15px; border-radius: 4px; margin-bottom: 15px;",
                           tags$b(style = "color: #f9a825;", "2. Evidencia de Colas Pesadas (Riesgo No-Normal)"),
                           br(), br(),
                           p(style = "margin:0;",
                             "El histograma y los boxplots anuales demuestran que MSFT presenta
     leptocurtosis. Los eventos extremos (", tags$em("Cisnes Negros"), ")
     ocurren con mayor frecuencia de lo que una distribución normal
     predeciría. Un modelo de producción debe ser robusto ante estos
     outliers."
                           )
                         ),
                         
                         # ── Hallazgo 3 ────────────────────────────────────────────────
                         tags$div(
                           style = "background-color: white; border-left: 4px solid #7b61ff;
           padding: 15px; border-radius: 4px; margin-bottom: 15px;",
                           tags$b(style = "color: #7b61ff;", "3. Volatilidad Agrupada (Clustering)"),
                           br(), br(),
                           p(style = "margin:0;",
                             "La volatilidad no es constante; tiende a agruparse en períodos de
     crisis (2000, 2008, 2020). Las Bandas de Bollinger y el análisis de
     retornos cuadrados confirman que el error de predicción aumentará
     significativamente en momentos de alta incertidumbre macroeconómica."
                           )
                         ),
                         
                         # ── Hallazgo 4 ────────────────────────────────────────────────
                         tags$div(
                           style = "background-color: white; border-left: 4px solid #26a69a;
           padding: 15px; border-radius: 4px; margin-bottom: 15px;",
                           tags$b(style = "color: #26a69a;",
                                  "4. Dominancia de la Tendencia sobre la Estacionalidad"),
                           br(), br(),
                           p(style = "margin:0;",
                             "Aunque existe un componente estacional leve, la tendencia capturada
     en la descomposición explica la mayor parte del movimiento del activo,
     impulsada por cambios estructurales en el modelo de negocio de
     Microsoft (Nube e IA)."
                           )
                         ),
                         
                         br(),
                         
                         # ── Síntesis ──────────────────────────────────────────────────
                         box(
                           title       = tagList(icon("magnifying-glass-chart"), " Síntesis"),
                           width       = 12,
                           status      = "primary",
                           solidHeader = TRUE,
                           
                           p("El análisis estructural de la serie histórica de MSFT (2000–2026)
    evidencia que el precio de cierre no puede modelarse directamente
    debido a su clara no estacionariedad, confirmada por la prueba ADF
    (p-valor = 0.9901), lo que implicaría el riesgo de incurrir en
    regresiones espurias."),
                           
                           br(),
                           
                           p("En contraste, la conversión a retornos logarítmicos diarios permitió
    obtener estacionariedad (p-valor ≈ 0.0000), validando su idoneidad
    para el modelado econométrico ",
                             tags$em("(Morales, 2013)"), ". La distribución de los retornos mostró
    leptocurtosis y asimetría positiva, evidenciando colas pesadas
    asociadas a episodios críticos como la burbuja puntocom, la crisis
    financiera de 2008 y la pandemia de 2020."),
                           
                           br(),
                           
                           p("La presencia de heterocedasticidad y clustering de volatilidad,
    confirmada por la persistencia en la ACF de los retornos cuadrados,
    respalda el uso de modelos ARCH/GARCH para la modelación del riesgo ",
                             tags$em("(Engle, 1982; Bollerslev, 1986)"),
                             ". Finalmente, la descomposición STL demuestra que la dinámica del
    activo está dominada por una tendencia estructural creciente —
    especialmente desde 2015 — impulsada por la expansión en servicios
    de nube e inteligencia artificial."),
                           
                           br(),
                           
                           tags$div(
                             style = "background-color: #0d1117; border-left: 4px solid #7b61ff;
             padding: 15px; border-radius: 4px;",
                             tags$em(style = "color: #aaaaaa;",
                                     "Estos hallazgos proporcionan una base sólida para el desarrollo
       de modelos predictivos robustos y estrategias de inversión
       fundamentadas en evidencia empírica."
                             )
                           )
                         )
                  )
                )
        )
      ) 
    )
)