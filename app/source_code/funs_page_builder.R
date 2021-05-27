
get_note_until_satisfied_loop <- function(prompt_text, var_name, page_type) {

  midi_or_audio <- function(type) {
    if (type == "record_audio_page") {
      record_audio_page(page_text = prompt_text,
                        label = var_name,
                        get_answer = get_answer_average_frequency_ff("round"),
                        show_record_button = TRUE,
                        show_aws_controls = FALSE,
                        method = "crepe")
    }
    else {

      reactive_page(function(state, ...) {

        midi_device <- get_global("midi_device", state)

        if(is.null(midi_device)) { shiny::showNotification("No midi device has been selected.") }

        record_midi_page(page_text = prompt_text,
                         label = var_name,
                         get_answer = get_answer_midi_note_mode,
                         show_record_button = TRUE,
                         midi_device = midi_device)
      })

    }
  }

  join(
    # set the user satisfied state to false

    code_block(function(state, ...) {
      set_global("user_satisfied", "No", state)
    }),

    # keep in loop until the participant confirms the note is correct
    while_loop(test = function(state, ...) {
      user_satisfied <- get_global("user_satisfied", state)
      user_satisfied == "No" },
      logic = list(
        # logic page 1, get new note
        midi_or_audio(page_type),
        # logic page 2, was everything ok with this note?
        reactive_page(function(answer, state, ...) {
          note <- answer[[1]]
          set_global(var_name, note, state)
          present_stimuli(stimuli = note,
                          stimuli_type = "midi_notes",
                          display_modality = "both",
                          page_text = "Was this the correct note?",
                          page_type = "NAFC_page",
                          choices = c("Yes", "No"),
                          label = var_name)
        }),
        code_block(function(state, answer, ...) {
          set_global("user_satisfied", answer, state)
        })
      )
    )
  )
}


get_instrument_range_pages <- function(type) {
  # a short multi-page protocol to get the user's frequency range


  if (type == "record_audio_page") {
    join(
      get_note_until_satisfied_loop(prompt_text = "Please play or sing the lowest comfortable note on your instrument", var_name = "bottom_range", page_type = "record_audio_page"),
      get_note_until_satisfied_loop(prompt_text = "Please play or sing the highest comfortable note on your instrument", var_name = "top_range", page_type = "record_audio_page"),
      reactive_page(function(state, ...) {
        lowest_user_note <- get_global("bottom_range", state)
        highest_user_note <- get_global("top_range", state)
        range <- c(lowest_user_note, highest_user_note)
        present_stimuli(stimuli = range, stimuli_type = "midi_notes", display_modality = "visual", page_text = "This is your range: ")
      })
    )
  }
  else {
    join(
      get_note_until_satisfied_loop(prompt_text = "Please play the lowest note on your MIDI keyboard.", var_name = "bottom_range", page_type = "record_midi_page"),
      get_note_until_satisfied_loop(prompt_text = "Please play the highest note on your MIDI keyboard.", var_name = "top_range", page_type = "record_midi_page"),
      reactive_page(function(state, ...) {
        lowest_user_note <- get_global("bottom_range", state)
        highest_user_note <- get_global("top_range", state)
        range <- c(lowest_user_note, highest_user_note)
        present_stimuli(stimuli = range, stimuli_type = "midi_notes", display_modality = "visual", page_text = "This is your range: ")
      })
    )
  }

}


play_melody_until_satisfied_loop <- function(melody = NULL, melody_no = "x", var_name = "melody", max_goes = 3,
                                             page_type, page_title = " ", answer_meta_data = " ") {


  c(
    # set the user satisfied state to false

    code_block(function(state, ...) {

      # repeat melody logic stuff
      set_global("user_satisfied", "Try Again", state)
      set_global("number_attempts", 1, state)

    }),

    # keep in loop until the participant confirms the note is correct
    while_loop(test = function(state, ...) {
      user_wants_to_play_again <- get_global("user_satisfied", state)
      number_attempts <- get_global("number_attempts", state)
      move_on <- ifelse(number_attempts == max_goes, FALSE, TRUE)
      user_wants_to_play_again == "Try Again" & move_on == TRUE },
      logic = list(
        reactive_page(function(state, ...) {

          if(is.null(melody)) {
            melodies <- get_global("melodies", state)
            melody <- melodies[melody_no, "abs_mel"]
            answer_meta_data <- toJSON(melodies[melody_no, c("log.freq", "N", "tonalness", "tonal.clarity", "tonal.spike",
                                         "mode", "step.cont.glob.var", "step.cont.glob.dir", "step.cont.loc.var",
                                         "mean_int_size", "int_range", "dir_change", "mean_dir_change", "int_variety", "span")])
          }

          if(length(melody) == 1 & is.character(melody)) {
            melody <- str.mel.to.vector(melody, ",")
          }


          if(page_type == "record_midi_page") {
            midi_device <- get_global("midi_device", state)

            if(is.null(midi_device)) { shiny::showNotification("No midi device has been selected.") }

            present_stimuli(stimuli = melody,
                            stimuli_type = "midi_notes",
                            display_modality = "auditory",
                            page_title = " ",
                            page_text = "Press play to hear the melody then play it back as best you can when it finishes.",
                            page_type = page_type,
                            answer_meta_data = answer_meta_data,
                            get_answer = get_answer_store_async_builder(page_id = paste0("melody_", melody_no)),
                            midi_device = midi_device)
          } else {


          # page 1, play melody
          present_stimuli(stimuli = melody,
                          stimuli_type = "midi_notes",
                          display_modality = "auditory",
                          page_title = " ",
                          page_text = "Press play to hear the melody then play it back as best you can when it finishes.",
                          page_type = page_type,
                          record_audio_method = "aws_pyin",
                          answer_meta_data = answer_meta_data,
                          get_answer = get_answer_store_async_builder(page_id = paste0("melody_", melody_no)) )
          }

        }),

        # logic page 2, was the user ok with this response?
        reactive_page(function(answer, state, ...) {
          number_attempts <- get_global("number_attempts", state)
          attempts_left <- max_goes - number_attempts

          NAFC_page(label = paste0(var_name,"_", number_attempts), prompt = paste0("If you were happy with your response, please click to continue, otherwise please click to try again. You have ", attempts_left, " attempts remaining if you would like."),
                    choices = c("Continue", "Try Again"))
        }),
        code_block(function(state, answer, ...) {
          set_global("user_satisfied", answer, state)
          number_attempts <- get_global("number_attempts", state)
          number_attempts <- number_attempts + 1
          set_global("number_attempts", number_attempts, state)
        })
      )
    ) # end while_loop
  ) # end join
}


build_multi_page_play_melody_until_satisfied_loop <- function(n_items, var_name = "melody", page_type, max_goes = 3) {
  # items should be a dataframe
  # this will return a sequence of test items
  unlist(lapply(1:n_items, function(melody_no) {
    play_melody_until_satisfied_loop(melody_no = melody_no,
                                     var_name = var_name,
                                     max_goes = max_goes,
                                     page_type = page_type)
  }))
}



midi_vs_audio_select_page <- function(prompt = "How will you input to the test?") {
  dropdown_page(label = "select_input",
                prompt = prompt,
                choices = c("Microphone", "MIDI"),
                on_complete = function(answer, state, ...) {
                  set_global("response_type", answer, state)
                })
}

musical_test <- function(test_name = NULL,
                         item_bank = list("rhythmic" = berkowitz.musicxml, "arrhythmic" = berkowitz.rds.abs),
                         no_items = 10,
                         display_modality = "visual",
                         response_type = "record_midi_page",
                         feedback = TRUE) {

  midi.response.pages <- create_midi_pages(no_items)
  audio.response.pages <- create_audio_pages(no_items)

  if (response_type == "user_selected") {

    tl <- psychTestR::join(

      midi_vs_audio_select_page(),

      # if they selected MIDI, show the pages as MIDI otherwise audio
      conditional(check.response.type.midi, midi.response.pages),

      conditional(check.response.type.audio, audio.response.pages)
    )

  }

  else if (response_type == "record_midi_page") {
    # i.e midi test
    tl <- midi.response.pages
  }

  else {
    # i.e audio test
    tl <- audio.response.pages
  }


  if (feedback) {
    tl <- insert.every.other.pos.in.list(tl, display_previous_answer_music_notation_pitch_class()) # or 2?
  }



  tl


}


