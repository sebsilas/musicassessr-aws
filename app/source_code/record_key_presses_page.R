library(psychTestR)
library(htmltools)



record_key_presses_page <- function(body, ...) {
    psychTestR::page(
    label = "test",
    ui = tags$div(tags$div(class="fx",
                           div(
                             div(id = "body", body),
                             trigger_button("next", "Next"),
                             br(),
                             tags$textarea(rows="5", name="test-target", id="test-target"),
                             tags$button('clear console', type="button", name="btn-clear-console", id="btn-clear-console")
                           ),
                           tags$div(class="flex",
                                    tags$pre(id="console-log")
                           )
    ),
    includeScript(path="www/js/getButtonPresses.js")
    ),
    get_answer = function(input, ...) {
      print(input$confidence)
      print(input$user_response)
      list(confidence = input$confidence,
           user_response = input$user_response)

    },
    save_answer = TRUE
  )
}
