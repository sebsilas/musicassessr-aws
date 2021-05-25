
tidy_freqs <- function(freqs) {
  freqs.wo.null <- as.numeric(unlist(lapply(freqs, function(x) ifelse(is.null(x), 0, x) )))
  notes <- lapply(freqs.wo.null, function(x) ifelse(is.na(x) | x== 0, NA, round(freq_to_midi(as.numeric(x)))) )

  unlist(notes)
}


record_audio_head_scripts <- function(method) {
  if (method == "crepe" | method == "both") {
    res <- div(
      includeScript(path="crepe_html/crepe.js"),
      includeCSS(path = 'crepe_html/crepe.css'),
    )
  }
  else {
    res <- NULL
  }
  res
}


deploy_crepe <- function(method, crepe_stats = FALSE) {
  print('deploy_crepe')
  print(crepe_stats)
  print(crepe_stats == TRUE & method == "crepe" | crepe_stats == TRUE & method == "both")
  if (crepe_stats == TRUE & method == "crepe" | crepe_stats == TRUE & method == "both") {

    div(shiny::tags$canvas(id = "activation"),
        tags$div(id="output",
                 br(),
                 tags$p('Status: ', tags$span(id="status")), tags$br(),
                 tags$p('Estimated Pitch: ', tags$span(id="estimated-pitch")),
                 tags$br(),
                 tags$p('Voicing Confidence: ', tags$span(id="voicing-confidence")),
                 tags$p('Your sample rate is', tags$span(id="srate"), ' Hz.')))
  }
  else {
    div()
  }
}


plot.note.data <- function(notes, onsets, quantized_notes) {

  # create df
  data <- data.frame(onsets = onsets,
                     note = unlist(notes),
                     quantized = quantized_notes
  )

  # Plot
  ggplot(data, aes(onsets) ) +
    #geom_line(aes(y = note, colour = "red"), alpha = 0.5) +
    geom_line(aes(y = quantized, colour = "blue"), alpha = 0.5, size = 3) +
    geom_point(aes(y = note, colour = "red"), shape=21, color="black", fill="#69b3a2", size=1) +
    theme_ipsum() +
    ggtitle("pitches")



}



record_audio_page <- function(body = NULL, label = "record_audio", stimuli = " ", stimuli_reactive = FALSE, page_text = " ", page_title = " ", interactive = FALSE,
                              note_no = "max", show_record_button = FALSE, get_answer = get_answer_store_async_builder(page_id = "record_audio_page"), transpose = 0, answer_meta_data = 0,
                              method = c("both", "crepe", "aws-pyin"), crepe_stats = FALSE, ...) {

  #note_no_js_script <- set.note.no(stimuli, note_no)

    psychTestR::page(ui = tags$div(

      tags$head(

        tags$script('console.log(\"this is an audio page\");'),
        audio_parameters_js_script, # record_audio only
        # import javascript
        shiny::tags$script(src="https://www.midijs.net/lib/midi.js"),
        #shiny::tags$script(src="https://unpkg.com/@tonejs/midi"),
        includeScript("www/js/Tone.js"),
        includeScript("www/js/Tonejs-Instruments.js"),
        includeScript("www/js/play_music_stimuli.js"),
        #tags$script(note_no_js_script),
        tags$script(set_answer_meta_data(answer_meta_data)),
        shiny::tags$script(htmltools::HTML(enable.cors)),
        includeScript(path = "www/js/play_music_stimuli.js"),
        record_audio_head_scripts(method), # record_audio only
        HTML('<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">'),
        includeCSS("static-website-s3/style.css")

      ),
      tags$body(

        tags$h2(page_title),
        tags$p(page_text),
        tags$div(body),
        reactive_stimuli(stimuli_function = stimuli_function,
                         stimuli_reactive = stimuli_reactive,
                         prepared_stimuli = abs_mel),

        present_record_button(show_record_button, type = method),
        trigger_button("next", "Next"),
      # NB: remove style attribute from pauseButton and/or recordingsList to show pause button or recordings respectively

        htmltools::HTML('<div id="controls">
  	 <button id="recordButton">Record</button>
  	 <button id="pauseButton" disabled style="display: none;">Pause</button>
  	 <button id="stopButton" disabled>Stop</button>
    </div>
    <div id="formats">Format: start recording to see sample rate</div>
  	<p><strong>Recordings:</strong></p>'),

        tags$div(id ="container",
                 htmltools::HTML('<ol id="recordingsList" style="display: none;"></ol>
        <div id="loading"></div>
        <div id="csv_file"></div>'),
                 deploy_crepe(method),
        ),

        produce.aws.footer.from.credentials2(wRegion = wRegion,
                                            poolid = poolid,
                                            s3bucketName = s3bucketName,
                                            audioPath = audioPath)
      )
    ),
    label = label,
    get_answer = get_answer,
    save_answer = TRUE
    )
}
