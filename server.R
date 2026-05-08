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
  
  # ================================================================
  # PESTAÑA MODELO ARIMA
  # ================================================================
  
  # ── ValueBoxes métricas ───────────────────────────────────────
  output$metric_mae <- renderValueBox({
    valueBox(
      value    = paste0(round(bundle$metricas$MAE, 4), " USD"),
      subtitle = "MAE — Error Absoluto Medio",
      icon     = icon("ruler"),
      color    = "navy"
    )
  })
  
  output$metric_rmse <- renderValueBox({
    valueBox(
      value    = paste0(round(bundle$metricas$RMSE, 4), " USD"),
      subtitle = "RMSE — Error Cuadrático Medio",
      icon     = icon("chart-simple"),
      color    = "navy"
    )
  })
  
  output$metric_mape <- renderValueBox({
    valueBox(
      value    = paste0(round(bundle$metricas$MAPE, 2), " %"),
      subtitle = "MAPE — Error Porcentual Medio",
      icon     = icon("percent"),
      color    = "navy"
    )
  })
  
  output$metric_da <- renderValueBox({
    valueBox(
      value    = paste0(round(bundle$metricas$DA, 2), " %"),
      subtitle = "DA — Dirección Acertada",
      icon     = icon("compass"),
      color    = "navy"
    )
  })
  
  # ── Orden del modelo ──────────────────────────────────────────
  output$orden_modelo <- renderUI({
    tagList(
      tags$span(style = "color:#7b61ff; font-size:1.3em;",
                paste0("ARIMA(", bundle$bp, ", 1, ", bundle$bq, ")")
      ),
      br(), br(),
      tags$small(
                 paste0("Fecha último dato: ",
                        format(bundle$last_date, "%d %b %Y"))
      )
    )
  })
  
  # ── Pronóstico reactivo ───────────────────────────────────────
  fc_reactivo <- reactive({
    nivel <- as.numeric(input$nivel_confi)
    forecast(modelo, h = input$horizonte, level = c(95, nivel))
  })
  
  # ── Gráfico principal ─────────────────────────────────────────
  output$plot_forecast <- renderPlotly({
    
    req(bundle$roll_df)
    
    df <- bundle$roll_df
    
    # ── Filtro por fechas exactas ────────────────────────────────
    df <- df %>%
      dplyr::filter(Date >= input$zoom_fecha[1],
                    Date <= input$zoom_fecha[2])
    
    # ── Intervalo de confianza seleccionado ─────────────────────
    nivel <- as.numeric(input$nivel_conf)
    
    lo <- switch(as.character(nivel),
                 "95" = df$Lo95,
                 "70" = df$Lo68

    )
    hi <- switch(as.character(nivel),
                 "95" = df$Hi95,
                 "70" = df$Hi68

    )
    ic_name <- paste0("IC ", nivel, "%")
    
    # ── Puntos fuera del intervalo ───────────────────────────────
    df$fuera_ic <- !is.na(df$Real) &
      !is.na(lo) & !is.na(hi) &
      (df$Real < lo | df$Real > hi)
    
    # ── Inicio del forecast ─────────────────────────────────────
    forecast_start_idx <- min(which(!is.na(df$Pred)))
    forecast_start_date <- df$Date[forecast_start_idx]
    
    # ── Plot base ────────────────────────────────────────────────
    p <- plot_ly(data = df, x = ~Date)
    
    # ── Banda de confianza (condicional) ────────────────────────
    if (input$mostrar_ic) {
      p <- p %>%
        add_ribbons(
          ymin      = lo,
          ymax      = hi,
          name      = ic_name,
          fillcolor = "rgba(173,140,255,0.18)",
          line      = list(color = "transparent"),
          hoverinfo = "skip"
        )
    }
    
    # ── Serie real ───────────────────────────────────────────────
    p <- p %>%
      add_lines(
        y    = ~Real,
        name = "Serie Real",
        line = list(color = "#EAEAEA", width = 2),
        hovertemplate = "<b>Serie Real</b><br>%{x}<br>Precio: %{y:.2f}<extra></extra>"
      )
    
    # ── Forecast (condicional) ───────────────────────────────────
    if (input$mostrar_forecast) {
      p <- p %>%
        add_lines(
          y    = ~Pred,
          name = "Forecast",
          line = list(color = "#FF3B3B", width = 2),
          hovertemplate = "<b>Forecast</b><br>%{x}<br>Predicción: %{y:.2f}<extra></extra>"
        )
    }
    
    # ── Puntos fuera del IC (condicional) ────────────────────────
    if (input$mostrar_fuera_ic) {
      df_fuera <- df %>% dplyr::filter(fuera_ic)
      
      if (nrow(df_fuera) > 0) {
        p <- p %>%
          add_markers(
            data          = df_fuera,
            x             = ~Date,
            y             = ~Real,
            name          = "Fuera del IC",
            marker        = list(
              color  = "#f9a825",
              size   = 7,
              symbol = "circle",
              line   = list(color = "white", width = 1)
            ),
            hovertemplate = "<b>⚠ Fuera del IC</b><br>%{x}<br>Real: %{y:.2f}<extra></extra>"
          )
      }
    }
    
    # ── Línea vertical inicio forecast ──────────────────────────
    p <- p %>%
      layout(
        shapes = list(
          list(
            type = "line",
            x0   = forecast_start_date,
            x1   = forecast_start_date,
            y0   = min(df$Real, na.rm = TRUE),
            y1   = max(df$Real, na.rm = TRUE),
            line = list(
              color = "rgba(255,255,255,0.25)",
              dash  = "dot",
              width = 2
            )
          )
        )
      )
    
    # ── Layout ──────────────────────────────────────────────────
    p %>%
      layout(
        title = list(
          text    = "<b>Rolling Forecast ARIMA</b>",
          x       = 0.5,
          xanchor = "center",
          font    = list(size = 30, color = "#FFFFFF")
        ),
        hovermode     = "x unified",
        paper_bgcolor = "#050816",
        plot_bgcolor  = "#050816",
        font          = list(color = "#EAEAEA", family = "Arial"),
        legend = list(
          orientation = "h",
          x           = 0.35,
          y           = 1.08,
          bgcolor     = "rgba(0,0,0,0)"
        ),
        margin = list(l = 80, r = 40, t = 90, b = 70),
        xaxis  = list(
          title       = list(text = "Fecha", font = list(size = 24)),
          showgrid    = TRUE,
          gridcolor   = "rgba(120,120,180,0.15)",
          zeroline    = FALSE,
          rangeslider = list(visible = FALSE),
          showline    = TRUE,
          linecolor   = "rgba(255,255,255,0.3)"
        ),
        yaxis  = list(
          title     = list(text = "Precio USD", font = list(size = 24)),
          showgrid  = TRUE,
          gridcolor = "rgba(120,120,180,0.15)",
          zeroline  = FALSE,
          showline  = TRUE,
          linecolor = "rgba(255,255,255,0.3)"
        )
      ) %>%
      config(
        responsive             = TRUE,
        scrollZoom             = TRUE,
        displaylogo            = FALSE,
        modeBarButtonsToRemove = list(
          "select2d", "lasso2d",
          "zoomIn2d", "zoomOut2d", "autoScale2d"
        )
      )
  })
  
  # ── Gráfico de errores ─────────────────────────────────────
  
  output$plot_error_forecast <- renderPlotly({
    
    error_df_c <- data.frame(
      Date  = bundle$roll_df$Date,
      Error = bundle$roll_df$Real - bundle$roll_df$Pred
    )
    
    error_df_c <- error_df_c %>%
      dplyr::filter(Date >= input$zoom_fecha[1],
                    Date <= input$zoom_fecha[2])
    
    # Colores según signo del error
    colors_bar <- ifelse(
      error_df_c$Error > 0,
      "#2ca02c",  # Verde → subestimación
      "#d62728"  # Rojo → sobreestimación
    )
    
    # Texto hover personalizado
    hover_txt <- paste0(
      "<b>", format(error_df_c$Date, "%d %b %Y"), "</b><br>",
      "Error: $", round(error_df_c$Error, 2), "<br>",
      ifelse(error_df_c$Error > 0,
             "Subestimación",
             "Sobreestimación")
    )
    
    plot_ly(
      data = error_df_c,
      x    = ~Date,
      y    = ~Error,
      type = "bar",
      name = "Error",
      marker = list(color = colors_bar),
      hovertext = hover_txt,
      hoverinfo = "text"
    ) %>%
      
      # Línea cero
      add_lines(
        x    = ~Date,
        y    = rep(0, nrow(error_df_c)),
        name = "Cero",
        line = list(
          color = "#ef5350",
          width = 1,
          dash  = "dash"
        ),
        hoverinfo = "skip"
      ) %>%
      
      # Tendencia LOESS
      add_lines(
        x = error_df_c$Date,
        y = predict(
          loess(Error ~ as.numeric(Date),
                data = error_df_c,
                span = 0.15)
        ),
        name = "Tendencia LOESS",
        line = list(
          color = "#f9a825",
          width = 2
        ),
        hoverinfo = "skip"
      ) %>%
      
      layout(
        title = list(
          text = paste0(
            "<b>Error Diario de Predicción — Rolling Forecast</b>",
            "<br><sup>",
            "Verde: subestimación | ",
            "Rojo: sobreestimación | ",
            "Naranja: tendencia LOESS",
            "</sup>"
          ),
          font = list(color = "#ffffff"),
          y=0.95
        ),
        
        xaxis = list(
          title     = "Fecha",
          color     = "#aaaaaa",
          gridcolor = "#2a2a3e"
        ),
        
        yaxis = list(
          title     = "Error (USD)",
          color     = "#aaaaaa",
          gridcolor = "#2a2a3e",
          zeroline  = FALSE
        ),
        
        paper_bgcolor = "#0f1117",
        plot_bgcolor  = "#0f1117",
        
        hovermode = "x unified",
        
        legend = list(
          font = list(color = "#cccccc")
        ),
        
        font = list(color = "#cccccc")
      )
  })
  
  #Gráfico predictivo
  
  # ── Gráfico principal ─────────────────────────────────────────
  output$plot_pred <- renderPlotly({
    
    fc     <- fc_reactivo()
    usar   <- input$usar_log
    n_hist <- as.numeric(input$n_hist)
    nivel  <- as.numeric(input$nivel_confi)
    h      <- input$horizonte
    
    
    # Serie histórica
    serie <- bundle$close_vec
    
    # Fechas históricas (días hábiles)
    todas_hist <- seq.Date(as.Date("2000-01-03"),
                           bundle$last_date, by = "day")
    fechas_hist <- todas_hist[!weekdays(todas_hist) %in%
                                c("Saturday", "Sunday")]
    fechas_hist <- tail(fechas_hist, length(serie))
    hist_dates  <- tail(fechas_hist, n_hist)
    hist_vals   <- tail(serie, n_hist)
    
    # Fechas futuras (días hábiles)
    todas_fut  <- seq.Date(bundle$last_date + 1,
                           bundle$last_date + h * 2, by = "day")
    fc_dates   <- todas_fut[!weekdays(todas_fut) %in%
                              c("Saturday", "Sunday")][1:h]
    
    # Valores del pronóstico
    pred <- as.numeric(fc$mean)
    lo2  <- as.numeric(fc$lower[,2])
    hi2  <- as.numeric(fc$upper[,2])
    lo1  <- as.numeric(fc$lower[,1])
    hi1  <- as.numeric(fc$upper[,1])
    
    plot_ly() %>%
      
      # Banda de confianza exterior
      add_ribbons(
        x      = fc_dates,
        ymin   = lo2,
        ymax   = hi2,
        name   = paste0("IC ", nivel, "%"),
        fillcolor = "rgba(123,97,255,0.15)",
        line   = list(color = "transparent")
      ) %>%
      
      # Banda de confianza interior (68%)
      add_ribbons(
        x      = fc_dates,
        ymin   = lo1,
        ymax   = hi1,
        name   = "IC 68%",
        fillcolor = "rgba(123,97,255,0.30)",
        line   = list(color = "transparent")
      ) %>%
      
      # Serie histórica
      add_lines(
        x    = hist_dates,
        y    = hist_vals,
        name = "Histórico",
        line = list(color = "#7b61ff", width = 1.5)
      ) %>%
      
      # Pronóstico
      add_lines(
        x    = fc_dates,
        y    = pred,
        name = "Pronóstico",
        line = list(color = "#ef5350", width = 2, dash = "dot")
      ) %>%
      
      layout(
        title         = list(
          text = paste0("<b>Pronóstico ARIMA(", bundle$bp, ",1,",
                        bundle$bq, ") — ", h, " días</b>"),
          font = list(color = "#ffffff"),
          y = 0.95),
        xaxis         = list(title = "", color = "#aaaaaa",
                             gridcolor = "#2a2a3e"),
        yaxis         = list(
          title = "Precio (USD)",
          color = "#aaaaaa", gridcolor = "#2a2a3e"
        ),
        paper_bgcolor = "#0f1117",
        plot_bgcolor  = "#0f1117",
        hovermode     = "x unified",
        legend        = list(font = list(color = "#cccccc")),
        font          = list(color = "#cccccc")
      )
  })
  
  
  output$plot_red <- renderPlotly({
    
    resid_vals <- as.numeric(residuals(modelo))
    fechas_r   <- seq_along(resid_vals)
    
    plot_ly(x = fechas_r, y = resid_vals,
            type = "scatter", mode = "lines",
            name = "Residual",
            line = list(color = "#f9a825", width = 0.8)) %>%
      add_lines(
        x    = fechas_r,
        y    = rep(0, length(fechas_r)),
        name = "Cero",
        line = list(color = "#ef5350", width = 1, dash = "dash")
      ) %>%
      layout(
        title         = list(text = "<b>Residuales del Modelo</b>",
                             font = list(color = "#ffffff"),
                             y = 0.95),
        xaxis         = list(title = "Observación", color = "#aaaaaa",
                             gridcolor = "#2a2a3e"),
        yaxis         = list(title = "Residual", color = "#aaaaaa",
                             gridcolor = "#2a2a3e"),
        paper_bgcolor = "#0f1117",
        plot_bgcolor  = "#0f1117",
        hovermode     = "x unified",
        legend        = list(font = list(color = "#cccccc"))
      )
  })
  
  # ── Tabla de métricas ─────────────────────────────────────────
  output$tabla_metricas <- renderTable({
    data.frame(
      Métrica = c("MAE", "RMSE", "MAPE", "DA"),
      Valor   = c(
        paste0(round(bundle$metricas$MAE,  4), " USD"),
        paste0(round(bundle$metricas$RMSE, 4), " USD"),
        paste0(round(bundle$metricas$MAPE, 2), " %"),
        paste0(round(bundle$metricas$DA,   2), " %")
      )
    )
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
      
  output$fecha_ultimo_dato <- renderUI({
    fecha <- if (!is.null(bundle$last_date))
      format(bundle$last_date, "%d %b %Y")
    else "N/A"
    tags$small(fecha)
  })
  

} 
