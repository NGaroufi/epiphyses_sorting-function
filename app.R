# Load packages ----
list.of.packages <- c("readr", "caret", "e1071", "Metrics", "dplyr", 
                      "shiny", "bslib")
#install.packages(list.of.packages, quiet = TRUE)

suppressMessages(suppressWarnings(invisible(sapply(list.of.packages, require, 
                                                   character.only = TRUE))))

# Source helpers ----
source("epiphyses_sorting.R")

# User interface ----
ui <- page_sidebar(
  title = "Sorting Epiphyseal Fragments",
  theme = bs_theme(
    bg = "#faf4ff",
    fg = "black",
    base_font = font_google("Inter"),
    code_font = font_google("JetBrains Mono")
  ),
  sidebar = sidebar(
    # fileInput(
    #   "file1", "Choose CSV file", accept = ".csv"
    # ),
    helpText(
      "Select a Bone to work with."
    ),
    selectInput(
      inputId = "bone",
      label = "Bone Type",
      choices = c("Femur", "Tibia", "Humerus")
    ),
    helpText(
      "Select a Distance to work with."
    ),
    selectInput(
      inputId = "distance",
      label = "Distance",
      choices = c("euclidean", 
                  "maximum", 
                  "manhattan",
                  "canberra",
                  "minkowski")
    ),
    br(),
    sliderInput("thr_id", "Threshold value:",
                min = 1, max = 2,
                value = 1.5, step=0.25),
    br(),
    helpText(
      "If you know the ground truth and wish to evaluate
      the sorting method:"
    ),
    checkboxInput(
      "gT",
      "Validation check",
      value = FALSE
    ),
    card(
      actionButton("go", "Choose your data file(s).")
    )
  ),
  card(
    card_header("Hello! Please confirm the parameters you wish to work with:"),
    textOutput("text"), max_height = 100
  ),
  mainPanel(
    card_header("The most probable pairs are:"),
    tableOutput("res")
  )
)
# Server logic
server <- function(input, output) {
  
  bone <- reactive({
    input$bone
  })

  distance <- reactive({
    input$distance
  })
  
  
  threshold_value <- reactive({
                      if (input$thr_id == 1) 
                        {threshold_value = 1} else if (input$thr_id == 1.25)
                        {threshold_value = 125} else if (input$thr_id == 1.5)
                        {threshold_value = 15} else if (input$thr_id == 1.75)
                        {threshold_value = 175} else if (input$thr_id == 2)
                        {threshold_value = 2}
                    
                  })
  
  my_text <- renderText({
     paste0("You are working with ", bone(), " bones,
            while using the ", distance(), " distance.")
        })


   output$text <- reactive({
     my_text()
   })
   
   
  gt <- reactive({
    input$gT
  })

  
   observeEvent(input$go, {
     
     res <- ep_sorting(bone(), distance(), threshold_value(), ground_truth = gt())
     results <- renderTable({
       capture.output(res, type="output")[-c(1,2)]
       })# <-- Modified the call to the script

     
     output$res <- results
     })

}

# Run the app
shinyApp(ui, server)
