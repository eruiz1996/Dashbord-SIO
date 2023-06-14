# ui.R
# Define la interfaz de usuario
ui <- fluidPage(
    tags$head(
        tags$style(
            HTML("body {background-color: #EAEAEA;}"),
            HTML(".jslider {background-color: #56242A;}"),
            HTML(".jslider .jslider-pointer {background-color: #FFA500;}"),
            HTML(".jslider .jslider-pointer:hover {background-color: #FFDAB9;}"),
            HTML(".jslider .jslider-pointer:active {background-color: #FFDAB9;}")
        )
    ),
    # Título de la aplicación
    titlePanel("Sistema de Información Oportuna"),
    
    # TabsetPanel con dos pestañas: "Descripción" y "Históricos"
    tabsetPanel(
        # Primera pestaña - "Descripción"
        tabPanel("Principales Instituciones",
                 # Sidebar con los elementos de entrada
                 sidebarLayout(
                     sidebarPanel(
                         # selección de operación (admite más de 1)
                         selectInput("operacion1", 
                                     "Selecciona la operación(es):",
                                     choices = opciones_operacion,
                                     selected = "Agrícola y de animales",
                                     multiple = T),
                         
                         # selección de descripción (admite más de 1)
                         selectInput("descripcion1", 
                                     "Selecciona la descripción(es):",
                                     choices = opciones_descripcion,
                                     selected = "Tomado",
                                     multiple = T),
                         
                         # selección de la fecha corte
                         selectInput("fecha1", 
                                     "Selecciona la fecha:",
                                     choices = opciones_fecha,
                                     selected = "2022-12-31")
                     ),
                     
                     # Contenido principal
                     mainPanel(
                         h1("Instituciones Aseguradoras"),
                         # Salida de la tabla generada por la función crear_tabla()
                         DT::dataTableOutput("tabla_resultados"),
                         
                         h1("Principales Instituciones"),
                         # Salida de la gráfica de barras
                         plotOutput("grafica_barras")
                     )
                 )
        ),
        
        # Segunda pestaña - "Históricos"
        tabPanel("Históricos",
                 fluidRow(
                     # Institución
                     column(4, 
                            selectInput("institucion2", 
                                        "Selecciona la Institución:",
                                        choices = unique(df$INSTITUCION),
                                        selected = "Agroasemex")
                            ),
                     # operación
                     column(4,
                            selectInput("operacion2", 
                                        "Selecciona la operación(es):",
                                        choices = opciones_operacion,
                                        selected = "Riesgos Catastróficos",
                                        multiple = T)
                            ),
                     # descripción de la operación
                     column(4,
                            selectInput("descripcion2",
                                        "Selecciona la descripción(es):",
                                        choices = opciones_descripcion,
                                        selected = "Directo",
                                        multiple = T)
                            ),
                     # barra para recorrer trimestres
                     column(3, offset = 1,
                            sliderTextInput("trimestres", 
                                            "Elige los trimestres",
                                            choices = as.character(opciones_fecha),
                                            selected = c(min(df$TRIMESTRE), 
                                                         max(df$TRIMESTRE)))
                            ),
                     # media móvil
                     column(3,
                            radioButtons("mediamovil", "Mostrar media móvil", 
                                         c("Sí", "No"), selected = "No"))
                 ),
                 # Contenido principal
                 mainPanel(
                     column(8, offset = 8, 
                            h1("Gráfica histórica")),
                     # Salida de la gráfica histórica
                     column(12, offset = 4,
                            plotOutput("grafica_historica")))
        ),
        
        # Tercer pestaña - "Comparativa"
        tabPanel("Comparativa",
                 # Sidebar con los elementos de entrada
                 sidebarLayout(
                     sidebarPanel(
                         # selección de Institución
                         selectInput("institucion3", 
                                     "Selecciona la Institución:",
                                     choices = opciones_institucion,
                                     selected = "Agroasemex"),
                         
                         # selección de operación (admite más de 1)
                         selectInput("operacion3", 
                                     "Selecciona la operación(es):",
                                     choices = opciones_operacion,
                                     selected = "Agrícola y de animales",
                                     multiple = T),
                         
                         # selección de descripción (admite más de 1)
                         selectInput("descripcion3", 
                                     "Selecciona la descripción(es):",
                                     choices = opciones_descripcion,
                                     selected = "Tomado",
                                     multiple = T),
                         
                         # selección de la fecha corte
                         selectInput("fecha3", 
                                     "Selecciona el trimestre de comparación",
                                     choices = seq(from=3,to=12,by=3),
                                     selected = 1)
                     ),
                     
                     # Contenido principal
                     mainPanel(
                         # Salida de la gráfica de barras
                         h1("Institución"),
                         plotOutput("grafica_comparativa1"),
                         
                         h1("Sector"),
                         plotOutput("grafica_comparativa2")
                     )
                 )
        )
        
    )
)

