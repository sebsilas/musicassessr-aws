select_midi_device_page <- function() {
  # set the selected device
  page(
    label = "get_device",

    ui = tags$div(
      tags$h2("Select MIDI device"),
      tags$p("Your device should have been plugged in before you reached this page. It may take a moment to appear."),
      tags$select(id = "midiDeviceSelector"),
      tags$br(),
      tags$br(),
      trigger_button("next", "Next"),
      includeScript(path = "https://cdn.jsdelivr.net/npm/webmidi@2.5.1"),
      includeScript(path = "www/js/getMIDIin.js"),
      tags$script('generateDeviceDropdown();'),
    ),

    get_answer = function(input, state, ...) {

      if(is.null(input$midi_device)) { shiny::showNotification("No midi device found.") }

      set_global("midi_device", input$midi_device, state)

    },
    save_answer = TRUE
  )
}

autoInstantiateMidi <- function(instantiate = TRUE, midi_device, interactive) {
  if (instantiate == TRUE) {
    tags$script(paste0('instantiateMIDI(\"',midi_device,'\", ', interactive, ');'))
  }
  else {
    tags$script(paste0('const midi_device = \"', midi_device, '\";'))
  }
}


get_answer_midi <- function(input, ...) {

  if(is.null(input$user_response_midi_note_on)) { shiny::showNotification("You didn't enter anything!") }


  list(fromJSON(input$stimuli),
       fromJSON(input$user_response_midi_note_on),
       input$user_response_midi_note_off,
       fromJSON(input$onsets),
       input$note_no
  )

}


record_midi_page <- function(body = NULL, label = "record_audio", stimuli = " ", stimuli_reactive = FALSE, page_text = " ", page_title = " ", interactive = FALSE,
                              note_no = "max", show_record_button = FALSE, get_answer = get_answer_midi, transpose = 0, answer_meta_data = 0,
                             autoInstantiate = FALSE, midi_device, ...) {

  #note_no_js_script <- set.note.no(stimuli, note_no)
    if (interactive) { interactive <- "true" } else  { interactive <- "false" }
    print('in page')
    print(midi_device)
    print(interactive)
    psychTestR::page(ui = tags$div(

      tags$head(

        tags$script('console.log(\"this is an midi page\");'),
        # import javascript
        shiny::tags$script(src="https://www.midijs.net/lib/midi.js"),
        #shiny::tags$script(src="https://unpkg.com/@tonejs/midi"),
        autoInstantiateMidi(instantiate = autoInstantiate, midi_device, interactive),
        includeScript("www/js/Tone.js"),
        includeScript("www/js/Tonejs-Instruments.js"),
        includeScript("www/js/play_music_stimuli.js"),
        #tags$script(note_no_js_script),
        tags$script(set_answer_meta_data(answer_meta_data)),
        shiny::tags$script(htmltools::HTML(enable.cors)),
        includeScript(path = "www/js/play_music_stimuli.js")

      ),
      tags$body(

        tags$h2(page_title),
        tags$p(page_text),
        tags$div(body),
        reactive_stimuli(stimuli_function = stimuli_function,
                         stimuli_reactive = stimuli_reactive,
                         prepared_stimuli = abs_mel),

        present_record_button(show_record_button, type = "record_midi_page"),

      )
    ),
    label = label,
    get_answer = get_answer,
    save_answer = TRUE
    )
}

