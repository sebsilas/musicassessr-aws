

deploy_crepe_stats <- function(deploy) {
  if (deploy == TRUE) {
    res <- div(
      shiny::tags$div(id = "audio-value"),
      tags$div(id="output",
               br(),
               tags$p('Status: ', tags$span(id="status")), tags$br(),
               tags$p('Estimated Pitch: ', tags$span(id="estimated-pitch")),
               tags$br(),
               tags$p('Voicing Confidence: ', tags$span(id="voicing-confidence")),
               tags$p('Your sample rate is', tags$span(id="srate"), ' Hz.')
      ))
  } else {
    res <- div()
  }
  res
}
