library(tidyverse)
library(shiny)
library(DT)
library(ggplot2)
library(stringr)
library(rjson)
library(xlsx)
library(hrep)
library(readr)
library(igraph)
library(visNetwork)

setwd("/Users/sebsilas/PhD 2021/magma-Gold/magmaGold/R/corpus_explorer")

source("utils.R")
source("utils_music.R")
source("present_stimuli_music.R")

dat <- read_rds("../www/item_banks/DTL_1000.RDS")

rel_to_abs_mel <- function(rel_mel, start_note = 60) {
    c(0, cumsum(rel_mel)) + start_note
}

#dir = "/Users/sebsilas/Desktop/data-programming/coursework/project/FINAL/one_script_version/R"
#setwd(dir)



sim_matrix_to_graph <- function(melody) {

    ngrams <- bind_rows(lapply(3:length(melody), function(x) get_all_ngrams(melody, N = x)))

    sim.matrix <- combn(ngrams$value, 2, FUN = function(x) ngrukkon(str.mel.to.vector(x[1], sep = ","),
                                                                    str.mel.to.vector(x[2], sep = ",")))

    sim.matrix <- matrix(sim.matrix, ncol = length(ngrams$value), nrow = length(ngrams$value))

    html <- paste0("<p style = 'color: red;'>",ngrams$value,'</p>')

    #nodes <- data.frame(id = ngrams$value, label = ngrams$value)
    #nodes <- data.frame(id = ngrams$value, label = "\uf286 <b>This</b> is an\n<i>html</i> <b><i>multi-</i>font</b> <code>label</code>'")
    print('print face')
    print(present_stimuli_midi_notes_visual(stimuli = 60:65))
    # nodes <- data.frame(id = ngrams$value, label = paste0('\uf286 ', present_stimuli_midi_notes_visual(stimuli = 60:65)))
    # nodes <- data.frame(id = ngrams$value, label = lapply(ngrams$value, function(x) paste0('\uf286 <b> This </b> is')))
    # nodes <- data.frame(id = ngrams$value, label = paste0('\uf286 <div><b><i>This</i></b></div> is'))
    nodes <- data.frame(id = ngrams$value, label = rep(HTML(paste0('\uf286 <div><b><i>This</i></b></div> is')), length(ngrams$value)))



    # # put row names to col names
    row.names(sim.matrix) <- ngrams$value
    colnames(sim.matrix) <- ngrams$value
    sim.matrix
    # hm, where are the diagonal ones?

    # create adjacency matrix
    threshold <- 0.2
    g <- graph.adjacency(sim.matrix > threshold)

    # create edges
    edges <- as.data.frame(get.edgelist(g))
    colnames(edges) <- c("from","to")

    network <- visNetwork(nodes, edges) %>%
                visPhysics(stabilization = FALSE) %>%
                visEdges(smooth = FALSE) %>%
                visLayout(randomSeed = 12, improvedLayout = FALSE) %>%
                visNodes(font = list(multi = TRUE, face = 'FontAwesome', ital = list(mod = ''),
                                     bold = list(mod = ''))) %>%
                addFontAwesome()
    network

}



ui <- basicPage(

    h2("Corpus Explorer"),

    visNetworkOutput("network"),

    htmlOutput('melodyNotation'),

    DT::dataTableOutput("melodies")

)


server <- function(input, output) {


    output$melodies <- DT::renderDataTable(dat, selection = 'single', escape = FALSE,
    options = list(searching = TRUE, pageLength = 20))


    output$melodyNotation <- renderUI({

        if (is.null(input$melodies_rows_selected)) {
          print("nothing selected")
        }
        else {
          #print(dat[[input$melodies_rows_selected, "melody"]])
          #print(str.mel.to.vector(dat[[input$melodies_rows_selected, "melody"]], sep = ","))
          melody <- str.mel.to.vector(dat[[input$melodies_rows_selected, "melody"]], sep = ",")
          # print(melody)
          # ngrams <- bind_rows(lapply(3:length(melody), function(x) get_all_ngrams(melody, N = x)))
          # print(ngrams)
          #
          # sim.matrix <- combn(ngrams$value, 2, FUN = function(x) ngrukkon(str.mel.to.vector(x[1], sep = ","),
          #                                             str.mel.to.vector(x[2], sep = ",")))
          # print(sim.matrix)
          abs_melody <- cumsum(melody) + 60
          present_stimuli_midi_notes_both(stimuli = abs_melody, note_length = 0.25)
        }
    })

    output$network <- renderVisNetwork({
        melody <- str.mel.to.vector(dat[[input$melodies_rows_selected, "melody"]], sep = ",")
        sim_matrix_to_graph(melody)
    })


}

shinyApp(ui, server)
