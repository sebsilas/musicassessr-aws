library(psychTestR)
library(htmltools)


timeline <- join(

  # set the selected voice
  page(
    label = "test",
    ui = div(
      tags$p(tags$em("...diagnostic messages"), class = "output"),
      tags$button("Record", onclick="recognition.start();"),
      trigger_button("next", "Next"),
      includeScript('R/js/captureSpeech.js')
    ),
    get_answer = function(input, ...) {
      print(input$confidence)
      print(input$user_response)
      list(confidence = input$confidence,
           user_response = input$user_response)

    },
    save_answer = TRUE
  ),

  final_page("The end")
)


test <- make_test(elts = timeline)
shiny::runApp(test)
