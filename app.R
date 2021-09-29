library(shiny)
library(tidyverse)
library(here)
library(ggplot2)
library(reactable)
library(dqshiny)
library(readxl)
library(ggpubr)
library(png)

location_lookup = read_rds(here('data/location_lookup.rds'))

exp_data = read_excel(here('data/All Data CTA.xlsx'), sheet = 5) %>%
    select(-ScanLabel,-SegmentLabel) %>%
    add_row(ROILabel = 099) %>%
    add_row(ROILabel = 098) %>%
    pivot_longer(-ROILabel,names_to = "gene", values_to = "exp") %>%
    mutate(location = sprintf("pos_%03d",ROILabel)) %>%
    left_join(location_lookup)

img <- readPNG(here('data/slide.png'))

ui <- fluidPage(

    # Application title
    titlePanel("Spatial Transcriptomics Plotting"),

    sidebarLayout(
        sidebarPanel(
            autocomplete_input("gene", 
                               h2("Select a Gene of Interest"), 
                               unique(exp_data$gene),
                               value = "A2M",
                               placeholder = "Start Typing to Find a Gene",
                               max_options = 100),
            

        ),

        mainPanel(
           plotOutput("spatial_plot")
        )
    ),
    br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
    br(),br(),br(),br(),br(),br(),br(),br(),br(),br(),
    hr(),
    fluidRow(
        column(12,
               reactableOutput("data_summary")
        )
    )
    
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    
    selected_gene_data <- reactive({
        selected_gene = input$gene
        
        exp_data %>%
            filter(gene == input$gene) %>%
            mutate(exp_alpha = ifelse(is.na(exp), 0, 1))
    })

    output$spatial_plot <- renderPlot({
        ggplot(selected_gene_data(), aes(x = x, y = y, color = exp, size = exp, alpha = exp_alpha)) +
            background_image(img) +
            geom_point() +
            scale_color_viridis_c() +
            theme(axis.title.x=element_blank(),
                  axis.text.x=element_blank(),
                  axis.ticks.x=element_blank(),
                  axis.title.y=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks.y=element_blank(),
                  text = element_text(size=20)) +
            labs(color = "Gene\nExpression\nLevel", size = "Gene\nExpression\nLevel") + 
            scale_alpha(guide = 'none')
    }, width=1000, height=850)
    
    output$data_summary <- renderReactable({
        reactable(selected_gene_data() %>%
                      arrange(desc(exp)) %>%
                      select(location,gene,exp) %>%
                      filter(location != "pos_099", location != "pos_098"), 
                  filterable = TRUE, pagination = F)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
