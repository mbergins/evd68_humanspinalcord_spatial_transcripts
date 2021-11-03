library(shiny)
library(tidyverse)
library(here)
library(ggplot2)
library(reactable)
library(dqshiny)
library(readxl)
library(ggpubr)
library(png)
library(patchwork)

location_lookup = read_rds(here('data/location_lookup.rds')) %>%
    mutate(type = fct_relevel(type, c("Inflamed","Control")))

exp_data = read_csv(here('data/vogt_deseq2_norm_counts.csv')) %>%
    mutate(gs099 = NA, gs098 = NA) %>% 
    rename(gene = ...1) %>%
    pivot_longer(-gene,names_to = "temp",values_to = "exp") %>%
    separate(temp, into=c(NA,"number"),sep = 2) %>%
    mutate(location = paste0("pos_",number)) %>%
    select(-number) %>%
    left_join(location_lookup)

img <- readPNG(here('data/slide.png'))

ui <- fluidPage(
    
    # Application title
    titlePanel("EVD68 Spinal Cord Spatial Transcripts"),
    
    tags$p("This spatial transcriptomic data set was created using the GeoMx platform from NanoString, comparing the 
    transcripts of ~1800 immunology- and oncology-related gene transcripts in the different highlighted regions of interest. 
    This specimen is human spinal cord from a five-year-old boy who died due to acute flaccid myelitis caused by enterovirus D68 infection. 
    The colored markers on this tissue help to identify the tissue structure and highlight inflamed areas of tissue:"),
    
    tags$ul(
        tags$li("Green = GFAP"),
        tags$li("Yellow = CD68"),
        tags$li("Red = CD3E"),
        tags$li("Blue = DNA")
    ),
    
    tags$p("This specimen is detailed in two publications:"),
    tags$ul(
        tags$li("Kreuter JD, et al. ", a(href='https://doi.org/10.5858/2010-0174-CR.1',"A fatal central nervous system enterovirus 68 infection"),". Arch Pathol Lab Med. 2011 Jun;135(6):793-6."),
        tags$li("Vogt MR, et al. Submitted")
    ),
    
    sidebarLayout(
        sidebarPanel(
            autocomplete_input("gene", 
                               h3("Select a Gene of Interest"), 
                               unique(exp_data$gene),
                               value = "CTSL",
                               placeholder = "Start Typing to Find a Gene",
                               max_options = 100),
            hr(),
            
            tags$p("Regions of interest:"),
            tags$ul(
                tags$li("Inflamed: 001, 005-015"),
                tags$li("Control: 016-021, 024")
            ),
            
            tags$p("The following perivascular regions of interest were not included in the analysis for the manuscript xxxxxxxx:"),
            tags$ul(
                tags$li("Inflamed: 002-004"),
                tags$li("Control: 022-023")
            ),
            hr(),
            downloadButton("norm_data_download", label = "Download Normalized Data Set"),
            downloadButton("full_data_download", label = "Download Full Data Set")
            
            
        ),
        
        mainPanel(
            plotOutput("spatial_plot", height="auto")
        )
    ),
    hr(),
    fluidRow(
        column(12,
               reactableOutput("data_summary")
        )
    ),
    hr(),
    downloadButton("filt_data_download", label = "Download Filtered Data Set")
    
)

server <- function(input, output, session) {
    
    selected_gene_data <- reactive({
        selected_gene = input$gene
        
        exp_data %>%
            filter(gene == input$gene) %>%
            mutate(exp_alpha = ifelse(is.na(exp), 0, 1))
    })
    
    output$spatial_plot <- renderPlot({
        slide_overlay = ggplot(selected_gene_data(), aes(x = x, y = y, color = exp, size = exp, alpha = exp_alpha)) +
            background_image(img) +
            geom_point() +
            scale_color_viridis_c() +
            coord_fixed(ratio = dim(img)[1]/dim(img)[2]) +
            theme_void() +
            theme(text = element_text(size=20)) +
            labs(color = "Gene\nExpression\nLevel", size = "Gene\nExpression\nLevel") + 
            scale_alpha(guide = 'none')
        
        
        data_box = ggplot(selected_gene_data() %>% filter(!is.na(type)), aes(x=type, y=exp)) +
            geom_boxplot() +
            labs(x="",y="Normalized Gene Expression") +
            theme(text = element_text(size=20)) +
            BerginskiRMisc::theme_berginski()
        
        layout <- "
        AA#B
        AA#B
        "
        
        slide_overlay + plot_spacer() + data_box +
            plot_layout(widths = c(4,0.25,1))
        # plot_layout(design = layout)
    }, 
    width = function() {
        session$clientData$output_spatial_plot_width
    },
    height = function() {
        session$clientData$output_spatial_plot_width * 0.6
    })
    
    output$norm_data_download <- downloadHandler(
        filename = "vogt_deseq2_norm_counts.csv", 
        content = function(file) {
            write_csv(read_csv(here('data/vogt_deseq2_norm_counts.csv')), file)
        } 
    )

    output$full_data_download <- downloadHandler(
        filename = "CTA Initial Dataset.xlsx",
        content = function(file) {
            file.copy(here('data/all_data/CTA Initial Dataset.xlsx'), file)
        }
    )
    
    output$filt_data_download <- downloadHandler(
        filename = paste0("vogt_deseq2_norm_counts_",input$gene,".csv"), 
        content = function(file) {
            write_csv(selected_gene_data, file)
        } 
    )
    
    output$data_summary <- renderReactable({
        reactable(selected_gene_data() %>%
                      arrange(desc(exp)) %>%
                      select(location,gene,exp,type) %>%
                      filter(location != "pos_099", location != "pos_098"), 
                  filterable = TRUE, pagination = F)
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
