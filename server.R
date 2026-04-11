# --- Archivo: server.R ---

# Define el servidor (lógica del back-end)
server <- function(input, output, session) {
  
  # --- Pestaña 1: Resultados interactivos ---

  # ── Gráfico de Velas ──────────────────────────────────────────────
  output$grafico_velas <- renderPlotly({
    
    # 1. Filtrar por rango de años seleccionado
    datos_filtrados <- msft %>%
      filter(year(Date) >= input$rango_anios[1],
             year(Date) <= input$rango_anios[2])
    
    # 2. Renderizar según tipo seleccionado
    if (input$tipo_grafico == "velas") {
      
      fig <- plot_ly(
        data = datos_filtrados,
        x    = ~Date,
        type = "candlestick",
        open  = ~Open,
        high  = ~High,
        low   = ~Low,
        close = ~Close,
        name  = "MSFT",
        
        # Colores: verde subida, rojo bajada (como en tu imagen)
        increasing = list(line = list(color = "#26a69a"),
                          fillcolor = "#26a69a"),
        decreasing = list(line = list(color = "#ef5350"),
                          fillcolor = "#ef5350")
      ) %>%
        layout(
          title = list(
            text = "<b>Gráfico de Velas — Microsoft (MSFT)</b>",
            font = list(color = "#ffffff", size = 16)
          ),
          xaxis = list(
            title        = "",
            rangeslider  = list(visible = FALSE),  # quita mini-slider inferior
            color        = "#aaaaaa",
            gridcolor    = "#2a2a3e",
            showspikes   = TRUE,
            spikemode    = "across"
          ),
          yaxis = list(
            title     = "Precio (USD)",
            color     = "#aaaaaa",
            gridcolor = "#2a2a3e"
          ),
          paper_bgcolor = "#0f1117",   # fondo exterior → ajusta a tu tema
          plot_bgcolor  = "#0f1117",   # fondo del gráfico
          font          = list(color = "#cccccc"),
          hovermode     = "x unified",  # tooltip vertical unificado
          legend        = list(font = list(color = "#ffffff"))
        )
      
    } else if (input$tipo_grafico == "cierre") {
      
      fig <- plot_ly(
        data = datos_filtrados,
        x    = ~Date,
        y    = ~Close,
        type = "scatter",
        mode = "lines",
        line = list(color = "#7b61ff", width = 1.8),
        name = "Cierre"
      ) %>%
        layout(
          title      = list(text = "<b>Precio de Cierre — MSFT</b>",
                            font = list(color = "#ffffff")),
          xaxis      = list(color = "#aaaaaa", gridcolor = "#2a2a3e"),
          yaxis      = list(title = "Precio (USD)", color = "#aaaaaa",
                            gridcolor = "#2a2a3e"),
          paper_bgcolor = "#0f1117",
          plot_bgcolor  = "#0f1117",
          hovermode     = "x unified"
        )
      
    } else if (input$tipo_grafico == "media_movil") {
      
      # Calcular medias móviles
      datos_filtrados <- datos_filtrados %>%
        mutate(
          MA20  = zoo::rollmean(Close, k = 20,  fill = NA, align = "right"),
          MA50  = zoo::rollmean(Close, k = 60,  fill = NA, align = "right"),
          MA200 = zoo::rollmean(Close, k = 252, fill = NA, align = "right")
        )
      
      fig <- plot_ly(datos_filtrados, x = ~Date) %>%
        add_lines(y = ~Close, name = "Cierre",
                  line = list(color = "#aaaaaa", width = 1)) %>%
        add_lines(y = ~MA20,  name = "MM 20",
                  line = list(color = "#f9a825", width = 1.5, dash = "dot")) %>%
        add_lines(y = ~MA50,  name = "MM 60",
                  line = list(color = "#26a69a", width = 1.8)) %>%
        add_lines(y = ~MA200, name = "MM 252",
                  line = list(color = "#ef5350", width = 2)) %>%
        layout(
          title      = list(text = "<b>Precio de Cierre + Medias Móviles</b>",
                            font = list(color = "#ffffff")),
          xaxis      = list(color = "#aaaaaa", gridcolor = "#2a2a3e"),
          yaxis      = list(title = "Precio (USD)", color = "#aaaaaa",
                            gridcolor = "#2a2a3e"),
          paper_bgcolor = "#0f1117",
          plot_bgcolor  = "#0f1117",
          hovermode     = "x unified",
          legend        = list(font = list(color = "#cccccc"))
        )
    }
    
    fig
  })
  
  output$tabla_datos <- DT::renderDataTable({
    DT::datatable(
      msft,
      options = list(
        pageLength = 10,
        scrollX    = TRUE,      # scroll horizontal si hay muchas columnas
        language   = list(
          search   = "Buscar:",
          paginate = list(previous = "Anterior", `next` = "Siguiente")
        )
      ),
      rownames = TRUE,
      class    = "stripe hover"
    )
  })
  
  # ── ValueBoxes: Retorno ───────────────────────────────────────
  
  msft$Return <- log(msft$Close / lag(msft$Close))
  Q1  <- quantile(msft$Return, 0.25, na.rm = TRUE)
  Q3  <- quantile(msft$Return, 0.75, na.rm = TRUE)
  IQR_val <- Q3 - Q1
  
  msft <- msft %>%
    mutate(
      es_atipico = !is.na(Return) &
        (Return < (Q1 - 1.5 * IQR_val) |
           Return > (Q3 + 1.5 * IQR_val))
    )
  
  n_atipicos <- sum(msft$es_atipico, na.rm = TRUE)
  
  output$box_retorno_medio <- renderValueBox({
    valueBox(paste0(round(mean(msft$Return, na.rm=TRUE)*100, 4), "%"),
             "Retorno Medio Diario", icon = icon("equals"), color = "navy")
  })
  output$box_retorno_max <- renderValueBox({
    valueBox(paste0(round(max(msft$Return, na.rm=TRUE)*100, 2), "%"),
             "Retorno Máximo", icon = icon("arrow-up"), color = "green")
  })
  output$box_retorno_min <- renderValueBox({
    valueBox(paste0(round(min(msft$Return, na.rm=TRUE)*100, 2), "%"),
             "Retorno Mínimo", icon = icon("arrow-down"), color = "red")
  })
  output$box_n_atipicos <- renderValueBox({
    valueBox(n_atipicos <- sum(msft$es_atipico, na.rm = TRUE), "Anomalías Detectadas",
             icon = icon("triangle-exclamation"), color = "yellow")
  })
  
  # ── Gráfico: Retorno Logarítmico + Atípicos ───────────────────
  output$grafico_retorno <- renderPlotly({
    
    # Filtro por año
    df <- msft %>%
      filter(year(Date) >= input$rango_retorno[1],
             year(Date) <= input$rango_retorno[2],
             !is.na(Return))
    
    # Recalcular atípicos según método seleccionado
    df <- df %>%
      mutate(es_atipico = case_when(
        input$metodo_atipico == "iqr3" ~
          Return < (Q1 - 3.0*IQR_val) | Return > (Q3 + 3.0*IQR_val),
        TRUE ~ es_atipico
      ))
    
    # Línea base
    fig <- plot_ly(df, x = ~Date) %>%
      add_lines(
        y    = ~Return,
        name = "Retorno Log",
        line = list(color = "#7b61ff", width = 1),
        hovertemplate = "%{x|%d %b %Y}<br>Retorno: %{y:.4f}<extra></extra>"
      )
    
    # Capa de atípicos (condicional)
    if (input$mostrar_atipicos) {
      atipicos <- df %>% filter(es_atipico)
      fig <- fig %>%
        add_markers(
          data      = atipicos,
          x         = ~Date,
          y         = ~Return,
          name      = "Anomalía",
          marker    = list(color  = "#ff4560",
                           size   = 8,
                           symbol = "circle",
                           line   = list(color = "white", width = 1)),
          hovertemplate = "<b>ANOMALÍA</b><br>%{x|%d %b %Y}<br>Retorno: %{y:.4f}<extra></extra>"
        )
    }
    
    fig %>% layout(
      title         = list(text = "<b>Retorno Logarítmico Diario — MSFT</b>",
                           font = list(color = "#ffffff")),
      xaxis         = list(title = "", color = "#aaaaaa", gridcolor = "#2a2a3e"),
      yaxis         = list(title = "Retorno Log", color = "#aaaaaa",
                           gridcolor = "#2a2a3e", zeroline = TRUE,
                           zerolinecolor = "#555555"),
      paper_bgcolor = "#0f1117",
      plot_bgcolor  = "#0f1117",
      hovermode     = "x unified",
      legend        = list(font = list(color = "#cccccc"))
    )
  })
  
  # ── Gráfico: Descomposición Estacional ────────────────────────
  output$grafico_descomp <- renderPlotly({
    
    df <- msft %>%
      filter(year(Date) >= input$rango_descomp[1],
             year(Date) <= input$rango_descomp[2])
    
    # Crear serie temporal y descomponer
    ts_close <- ts(df$Close, frequency = 252)  # 252 días bursátiles/año
    descomp  <- decompose(ts_close, type = input$tipo_descomp)
    
    fechas <- df$Date[!is.na(descomp$trend)]
    
    # Subplot con 4 paneles
    p1 <- plot_ly(x = df$Date, y = as.numeric(descomp$x),
                  type = "scatter", mode = "lines",
                  name = "Original",
                  line = list(color = "#7b61ff", width = 1)) %>%
      layout(yaxis = list(title = "Original"))
    
    p2 <- plot_ly(x = df$Date, y = as.numeric(descomp$trend),
                  type = "scatter", mode = "lines",
                  name = "Tendencia",
                  line = list(color = "#26a69a", width = 2)) %>%
      layout(yaxis = list(title = "Tendencia"))
    
    p3 <- plot_ly(x = df$Date, y = as.numeric(descomp$seasonal),
                  type = "scatter", mode = "lines",
                  name = "Estacionalidad",
                  line = list(color = "#f9a825", width = 1.5)) %>%
      layout(yaxis = list(title = "Estacional"))
    
    p4 <- plot_ly(x = df$Date, y = as.numeric(descomp$random),
                  type = "scatter", mode = "lines",
                  name = "Residuo",
                  line = list(color = "#ef5350", width = 1)) %>%
      layout(yaxis = list(title = "Residuo"))
    
    subplot(p1, p2, p3, p4,
            nrows       = 4,
            shareX      = TRUE,
            titleY      = TRUE) %>%
      layout(
        title         = list(
          text = "<b>Descomposición Estacional — Precio de Cierre MSFT</b>",
          font = list(color = "#ffffff")),
        paper_bgcolor = "#0f1117",
        plot_bgcolor  = "#0f1117",
        font          = list(color = "#cccccc"),
        showlegend    = TRUE
      )
  })
  
  # ================================================================
  # VALUEBOX: Volatilidad — reactivos a la ventana seleccionada
  # ================================================================
  
  # Reactive que calcula la volatilidad según ventana elegida
  vol_data <- reactive({
    ventana <- as.numeric(input$ventana_vol)
    
    msft %>%
      dplyr::mutate(
        vol = zoo::rollapply(Return, width = ventana,
                             FUN = sd, fill = NA, align = "right")
      )
  })
  
  output$box_vol_media <- renderValueBox({
    v <- round(mean(vol_data()$vol, na.rm = TRUE), 5)
    valueBox(v, paste0("Vol. Media (", input$ventana_vol, "d)"),
             icon = icon("chart-line"), color = "navy")
  })
  
  output$box_vol_max <- renderValueBox({
    v <- round(max(vol_data()$vol, na.rm = TRUE), 5)
    valueBox(v, "Volatilidad Máxima Histórica",
             icon = icon("fire"), color = "red")
  })
  
  output$box_fecha_vol_max <- renderValueBox({
    df  <- vol_data()
    idx <- which.max(df$vol)
    fecha <- format(df$Date[idx], "%d %b %Y")
    valueBox(fecha, "Fecha del Pico de Volatilidad",
             icon = icon("calendar-xmark"), color = "yellow")
  })
  
  output$box_vol_actual <- renderValueBox({
    df <- vol_data()
    v  <- round(tail(df$vol[!is.na(df$vol)], 1), 5)
    valueBox(v, paste0("Vol. Reciente (", input$ventana_vol, "d)"),
             icon = icon("clock"), color = "navy")
  })
  
  # ================================================================
  # GRÁFICO: Volatilidad rodante + precio superpuesto
  # ================================================================
  output$grafico_volatilidad <- renderPlotly({
    
    ventana <- as.numeric(input$ventana_vol)
    
    df <- vol_data() %>%
      dplyr::filter(lubridate::year(Date) >= input$rango_vol[1],
                    lubridate::year(Date) <= input$rango_vol[2],
                    !is.na(vol))
    
    # Capa base: volatilidad como área rellena
    fig <- plot_ly(df, x = ~Date) %>%
      add_lines(
        y    = ~vol,
        name = paste0("Volatilidad ", ventana, "d"),
        line = list(color = "#f9a825", width = 1.5),
        fill = "tozeroy",
        fillcolor = "rgba(249,168,37,0.12)",
        hovertemplate = "%{x|%d %b %Y}<br>Vol: %{y:.5f}<extra></extra>"
      )
    
    # Capa opcional: precio en eje Y secundario
    if (input$superponer_precio) {
      fig <- fig %>%
        add_lines(
          y     = ~Close,
          name  = "Precio Cierre",
          yaxis = "y2",
          line  = list(color = "#7b61ff", width = 1.2, dash = "dot"),
          hovertemplate = "%{x|%d %b %Y}<br>Precio: $%{y:.2f}<extra></extra>"
        )
    }
    
    # Layout con doble eje Y
    fig %>% layout(
      title = list(
        text = paste0("<b>Volatilidad Rodante ", ventana,
                      " días — MSFT</b>"),
        font = list(color = "#ffffff")
      ),
      xaxis  = list(
        title     = "",
        color     = "#aaaaaa",
        gridcolor = "#2a2a3e"
      ),
      yaxis  = list(
        title     = "Volatilidad (SD)",
        color     = "#f9a825",
        gridcolor = "#2a2a3e",
        side      = "left"
      ),
      yaxis2 = list(
        title      = "Precio (USD)",
        overlaying = "y",
        side       = "right",
        color      = "#7b61ff",
        showgrid   = FALSE
      ),
      paper_bgcolor = "#0f1117",
      plot_bgcolor  = "#0f1117",
      hovermode     = "x unified",
      legend        = list(font = list(color = "#cccccc")),
      font          = list(color = "#cccccc")
    )
  })
  

      

  

} 
