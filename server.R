# server.R
# función para crear tabla
crear_tabla <- function(df, operacion, descripcion, fecha){
    td <- df %>%
        # filtrado
        filter(TRIMESTRE == ymd(fecha)) %>%
        filter(OPERACION %in% operacion) %>%
        filter(DESCRIPCION %in% descripcion) %>%
        # agrupación por institución
        group_by(INSTITUCION) %>%
        summarise(PRIMA = sum(IMPORTE)) %>%
        # primas y su porcentaje
        mutate(PORCENTAJE = percent(PRIMA/sum(PRIMA), accuracy=0.01)) %>%
        # ordenamos
        arrange(-PRIMA)
    # cambiamos cambiamos nombres
    colnames(td) <- c("Institución", "Prima", "Porcentaje")  
    return(td)
}

# Define el servidor
server <- function(input, output) {
    
    # Crea la tabla utilizando la función crear_tabla()
    output$tabla_resultados <- DT::renderDataTable({
        crear_tabla(df, input$operacion1, input$descripcion1, input$fecha1) %>%
            DT::datatable(extensions = 'Buttons',
                          options = list(dom='Bfrtip', 
                                         buttons = c('csv'))
                                      )
    })
    
    barras <- reactive({
        crear_tabla(df, input$operacion1, input$descripcion1,
                    input$fecha1) %>%
            # Tomamos las primeras 5 instituciones
            head(5)  %>%
            arrange(desc(Prima))
    })
    
    # Gráfica de barras con las primeras 5 instituciones
    output$grafica_barras <- renderPlot({
        # Gráfica de barras
        ggplot(barras(), aes(x = reorder(Institución, -Prima), y = Prima, fill = Institución)) +
            geom_bar(stat = "identity") +
            labs(title = "Top 5 instituciones", x = "Institución", y = "Prima") +
            theme(plot.title = element_text(hjust = 0.5)) +
            scale_fill_manual(values = c("#6F7271","#56242A","#13322B", 
                                         "#B38E5D", "#ffb999"))
    })
    
    # base de datos (histórica) filtrada
    info_historica <- reactive({
        df %>%
            filter(INSTITUCION == input$institucion2,
                   TRIMESTRE >= input$trimestres[1],
                   TRIMESTRE <= input$trimestres[2],
                   OPERACION %in% input$operacion2,
                   DESCRIPCION %in% input$descripcion2)
    })
    
    # Variable reactiva para almacenar si el botón de radio está seleccionado o no
    mostrar_mediamovil <- reactive({
        ifelse(input$mediamovil == "Sí", TRUE, FALSE)
    })
    # Render a plot of filtered data
    output$grafica_historica <- renderPlot({
        # gráfica de barras
        ggplot(info_historica(), aes(x = TRIMESTRE, y = IMPORTE, fill = INSTITUCION)) +
            geom_bar(stat = "identity", position = "dodge") +
            scale_fill_manual(values = c("#13322B")) +
            labs(x = "Trimestre", y = "Importe", fill = "Institución") +
            theme_minimal() +
            # media móvil
            if(mostrar_mediamovil()){
            geom_smooth(method = "loess", formula = y~x, se = FALSE, color = "#56242A")}
    })
    # institución
    trimestre_select1 <- reactive({
        # Filtrar datos
        df %>% 
            filter(INSTITUCION == input$institucion3,
                   OPERACION %in% input$operacion3,
                   DESCRIPCION %in% input$descripcion3,
                   TRIMESTRE %in% opciones_fecha[month(opciones_fecha) == input$fecha3])
    })
    
    output$grafica_comparativa1 <- renderPlot({
        ggplot(trimestre_select1(), aes(x = TRIMESTRE, y = IMPORTE, fill = INSTITUCION)) +
        geom_bar(stat = "identity", position = "dodge") +
        scale_fill_manual(values = c("#13322B")) +
            labs(x = "Trimestre", y = "Importe", fill = "Institución") +
        theme_minimal()
    })
    # sector
    trimestre_select2 <- reactive({
        # Filtrar datos
        df %>% 
            filter(OPERACION %in% input$operacion3,
                   DESCRIPCION %in% input$descripcion3,
                   TRIMESTRE %in% opciones_fecha[month(opciones_fecha) == input$fecha3]) %>% 
            group_by(TRIMESTRE) %>% 
            summarise(IMPORTE = sum(IMPORTE)) %>% 
            mutate(SECTOR = "Sector")
    })
    
    output$grafica_comparativa2 <- renderPlot({
        ggplot(trimestre_select2(), aes(x = TRIMESTRE, y = IMPORTE, fill = SECTOR)) +
            geom_bar(stat = "identity", position = "dodge") +
            scale_fill_manual(values = c("#56242A")) +
            labs(x = "Trimestre", y = "Importe", fill = "Sector") +
            theme_minimal()
    })
}