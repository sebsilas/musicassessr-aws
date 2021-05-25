microphone_calibration_page <- function(admin_ui = NULL, on_complete = NULL, label= NULL, body = NULL, button_text = "Next", save_answer = FALSE, deploy_crepe_stats = FALSE) {

  ui <- div(
    shiny::tags$style('._hidden { display: none;}'), # to hide textInputs
    # start body
    audio_parameters_js_script,
    includeScript(path="crepe_html/tfjs-0.8.0.min.js"),
    includeScript(path="crepe_html/crepe.js"),
    includeCSS(path = 'crepe_html/crepe.css'),

    tags$script("var trigButton = document.getElementById('next');
              trigButton.onclick = crepeStop;"),

    body,

    img(id = "record",
        src = "img/mic128.png",
        onclick = "toggleRecording(this);crepe();initTF();crepeResume();",#getMedia();
        style = "display:block; margin:1px auto;", width = "100px", height = "100px"),

    #
    tags$p("Click on the microphone to test. If you see activity, then the microphone is working."),
    hr(),
    # helpText("Make sure your microphone levels are not too high when you speak or sing. Turn your microphone volume down if so."),
    # helpText("If you see that the levels are moving a lot when you are sitting quietly, your room may be too noisy to complete the test."),
    # hr(),
    # div(id = "viz",
    #     tags$canvas(id = "analyser"),
    #     tags$canvas(id = "wavedisplay")
    # ),
    # br(),

    tags$div(id ="container",
             shiny::tags$canvas(id="activation", width="960", height="360"),
             br(),
             deploy_crepe_stats(deploy_crepe_stats)
    ),

    tags$button("Next", id = "next", onclick = "crepeStop(true);"),
    hr(),

    produce.aws.footer.from.credentials(wRegion = wRegion,
                                        poolid = poolid,
                                        s3bucketName = s3bucketName,
                                        audioPath = audioPath, footer_type = "first")

  ) # end main div

  psychTestR::page(ui = ui, admin_ui = admin_ui, on_complete = on_complete, label = label, save_answer = FALSE)
}
