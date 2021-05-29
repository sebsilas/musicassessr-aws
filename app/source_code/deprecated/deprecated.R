# potentially deprecated functions:



create.rhythmic.and.or.arrhythmic.test <- function(item_bank, no_items, display_modality, response_type, feedback = FALSE,
                                                   get_answer, record_method = "aws-pyin", autoInstantiateMIDI = FALSE) {


  if(display_modality == "visual") {
    rhythmic_stimuli_type <- "musicxml_file"
  }
  else {
    rhythmic_stimuli_type <- "midi_file"
  }


  if (is.null(item_bank$type)) { # if this were false, it should imply there is a single item bank, hence this deals with two item banks

    if(!is.null(item_bank[["rhythmic"]]) & !is.null(item_bank[["arrhythmic"]])) {
      # both rhythmic and arrhythmic trials

      # check item bank type supported
      SRT.item.bank.support.check(c(item_bank[["rhythmic"]], item_bank[["arrhythmic"]]))

      # take a sample of the item bank
      sampled_item_bank_rhythmic <- item.sampler.simple(item_bank[["rhythmic"]], no_items[["rhythmic"]])
      sampled_item_bank_arrhythmic <- item.sampler.rds(item_bank[["arrhythmic"]], no_items[['arrhythmic']])


      # convert to psychTestR pages
      tl_rhythmic <- create.test.pages.from.item.bank(items = sampled_item_bank_rhythmic, stimuli_type = rhythmic_stimuli_type,
                                                      display_modality = display_modality, page_text = "Press Play to hear the melody. Play it back when it finishes. Click Next when you are done.",
                                                      page_type = response_type, feedback = feedback)


      tl_arrhythmic <- create.test.pages.from.item.bank(items = sampled_item_bank_arrhythmic, stimuli_type = "midi_notes",
                                                        display_modality = display_modality, page_text = "Press Play to hear the melody. Play it back when it finishes. Click Next when you are done.",
                                                        page_type = response_type, feedback = feedback)

      tl <- join(tl_rhythmic, tl_arrhythmic)
    }

    else if(!is.null(item_bank[["rhythmic"]])) {
      # only rhythmic trials
      # take a sample of the item bank
      sampled_item_bank_rhythmic <- item.sampler.simple(item_bank[["rhythmic"]], no_items[["rhythmic"]])
      # convert to psychTestR pages
      tl_rhythmic <- create.test.pages.from.item.bank(items = sampled_item_bank_rhythmic, stimuli_type = rhythmic_stimuli_type,
                                                      display_modality = display_modality,
                                                      page_text = "Please play back the melody.",
                                                      page_type = response_type, feedback = feedback)
      tl <- tl_rhythmic

    }

    else if(!is.null(item_bank[["arrhythmic"]])) {
      # only arrhythmic trials

      # take a sample of the item bank
      sampled_item_bank_arrhythmic <- item.sampler.simple(item_bank[["arrhythmic"]], no_items[['arrhythmic']])
      # convert to psychTestR pages

      tl_arrhythmic <- create.test.pages.from.item.bank(items = sampled_item_bank_arrhythmic,
                                                        stimuli_type = "midi_notes",
                                                        display_modality = display_modality,
                                                        page_text = "Please play back the melody.",
                                                        page_type = response_type, feedback = feedback)

      tl <- tl_arrhythmic
    }
    else {
      stop('If specifying a named list, please specific either names that are "rhythmic" or "arrhythmic"')
    }
  }

  else {

    # either only rhythmic trials or arrhythmic trials, depending on user spec
    stimuli_type <- "midi_notes"
    sampled_item_bank <- item_sampler(item_bank, no_items)

    #sampled_item_bank_abs <- sampled_item_bank

    #abs_mels <- lapply(sampled_item_bank_abs$melody, function(x) paste0(produce_stimuli_in_range(x), collapse = ",") )
    #sampled_item_bank_abs$melody <- unlist(abs_mels)

    tl <- create.test.pages.from.item.bank(items = sampled_item_bank,
                                           stimuli_type = stimuli_type,
                                           display_modality = display_modality,
                                           page_text = "Please play back the melody.",
                                           page_type = response_type,
                                           feedback = feedback,
                                           get_answer = get_answer,
                                           record_method = record_method,
                                           autoInstantiateMIDI = FALSE
    )
  }
  tl
}



record_audio_page <- function(body = NULL, label = "record_audio", stimuli = " ", stimuli_reactive = FALSE, page_text = " ", page_title = " ", interactive = FALSE,
                              note_no = "max", show_record_button = FALSE, get_answer = get_answer_simple_send_to_s3, transpose = 0, answer_meta_data = 0,
                              method = c("both", "crepe", "aws-pyin"), crepe_stats = FALSE, ...) {

  #note_no_js_script <- set.note.no(stimuli, note_no)


  reactive_page(function(state, ...) {

    if (stimuli_reactive != FALSE ) {
      if(stimuli_reactive == "reactive_abs_mel") {
        stimuli_function <- stimuli
        abs_mel <- get_global("abs_mel", state)
      }
    }
    else {
      abs_mel <- 0
    }


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
        record_audio_head_scripts(method) # record_audio only

      ),
      tags$body(

        tags$h2(page_title),
        tags$p(page_text),
        tags$div(body),
        reactive_stimuli(stimuli_function = stimuli_function,
                         stimuli_reactive = stimuli_reactive,
                         prepared_stimuli = abs_mel),

        present_record_button(show_record_button, type = method),

        tags$div(id ="container",
                 deploy_crepe(method),
        ),

        produce.aws.footer.from.credentials(footer_type = "every_other",
                                            wRegion = wRegion,
                                            poolid = poolid,
                                            s3bucketName = s3bucketName,
                                            audioPath = audioPath)
      )
    ),
    label = label,
    get_answer = get_answer,
    save_answer = TRUE
    )
  })
}


get_answer_new <- function(input, ...) {
  print("get_answer!")
  print(input$user_response_notes)
  user_response_notes <- round(freq_to_midi(as.numeric(fromJSON(input$user_response_notes))))
  print(user_response_notes)
  print(fromJSON(input$stimuli))
  print(user_response_timecodes)
  list(
    stimuli = fromJSON(input$stimuli),
    user_response_notes = user_response_notes,
    user_response_timecodes = 1:length(user_response_notes) #round(answer[[4]]/1000, 2)
  )
}

item.sampler <- function(item_bank, no_items) {

  # this function stratifies by N and samples up to the no_items for the maximum N in the database
  # or this is can be made custom and specific by giving a list to no_items

  if (class(no_items) == "list") {
    sample <- item.sampler.by.N.list(item_bank, no_items)
  }

  else {

    # get the max N for the stimuli set
    max.N <- max(item_bank$N)

    # take a sample to grab the shape
    sample <- item_bank[1, ]

    for (n in 1:no_items) {

      if (n > max.N) {
        n <- (n - (floor(n/max.N)*max.N)) + 1
        print(n)
      }

      N.subset <- item_bank[item_bank[, "N"] == n, ]
      rand.samp.i <- sample(1:nrow(N.subset), 1, replace = FALSE)
      rand.samp <- N.subset[rand.samp.i, ]
      sample <- rbind(sample, rand.samp)
    }

    # pop off the first sample that was taken for a shape
    sample <- sample[2:nrow(sample), ]

  }

  # remove duplicates
  sample <- remove.duplicates.and.resample(sample, item_bank)


}



# musical_test(test_name = "Playing By Ear Test",
#              item_bank = WJD,
#              no_items = 20,
#              display_modality = "auditory",
#              response_type = "user_selected",
#              feedback = FALSE
# ),




# present_stimuli(stimuli_type = "midi_notes",
#                 stimuli = rel_to_abs_mel(str.mel.to.vector(DTL_1000[[2, "melody"]], ",")),
#                 display_modality = "auditory",
#                 page_title = paste0(1, "/20"),
#                 page_text = "Press play to hear the melody then play it back as best you can when it finishes.",
#                 page_type = "record_audio_page2",
#                 answer_meta_data = toJSON(DTL_1000[2, c("log.freq", "N", "tonalness", "tonal.clarity", "tonal.spike", "mode", "step.cont.glob.var", "step.cont.glob.dir", "step.cont.loc.var")])
# ),
#
# display_previous_answer_music_notation_pitch_class2(),






# present_stimuli(stimuli_reactive = "reactive_abs_mel",
#                 stimuli_type = "midi_notes",
#                 stimuli = DTL_1000[[2, "melody"]],
#                 display_modality = "auditory",
#                 page_title = paste0(1, "/20"),
#                 page_text = "Press play to hear the melody then play it back as best you can when it finishes.",
#                 page_type = "record_midi_page",
#                 answer_meta_data = toJSON(DTL_1000[2, c("log.freq", "N", "tonalness", "tonal.clarity", "tonal.spike", "mode", "step.cont.glob.var", "step.cont.glob.dir", "step.cont.loc.var")])
# ),




# get_instrument_range_pages("audio"),



# play_melody_until_satisfied_loop(melody = DTL_1000[[2, "melody"]],
#       var_name = "melody", max_goes = 3,
#       page_type = "record_midi_page", trial_no = 1,
#       answer_meta_data = toJSON(DTL_1000[2, c("log.freq", "N", "tonalness", "tonal.clarity", "tonal.spike",
#                                                                  "mode", "step.cont.glob.var", "step.cont.glob.dir", "step.cont.loc.var")])),
#

# play_melody_until_satisfied_loop(melody = DTL_1000[[2, "melody"]],
#                                  var_name = "melody", max_goes = 3,
#                                  page_type = "record_midi_page", trial_no = 1,
#                                  answer_meta_data = toJSON(DTL_1000[2, c("log.freq", "N", "tonalness", "tonal.clarity", "tonal.spike",
#                                                                          "mode", "step.cont.glob.var", "step.cont.glob.dir", "step.cont.loc.var")])),
#
#


# load up test pages

select_midi_device_page <- function() {
  # set the selected device
  page(
    label = "get_device",

    ui = tags$div(
      tags$h2("Select MIDI device"),
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
    div()
  }
}



# PBE_answer_test <- list(
#
#   record_audio_page2(body = div(trigger_button("next", "Next")), get_answer = function(input, state, ...) {
#
#
#     json <- rjson::toJSON(list(sourceBucket = input$sourceBucket,
#                                   key = input$key,
#                                   destBucket = input$destBucket))
#
#
#     do <- function() {
#       headers <- c("content-type" = "application/json")
#       http_post("https://pv3r2l54zi.execute-api.us-east-1.amazonaws.com/prod/api", data = json, headers = headers)$
#         then(http_stop_for_status)$
#         then(function(x) {
#           print('pap')
#           print(x)
#           print(rjson::fromJSON(rawToChar(x$content))$key)
#           key <- rjson::fromJSON(rawToChar(x$content))$key
#           bucket <- rjson::fromJSON(rawToChar(x$content))$Bucket
#
#           link_href <- paste0("https://", bucket, ".s3.amazonaws.com/", key)
#           print('link')
#           print(link_href)
#           csv <- read_csv(link_href, col_names = c("onset", "dur", "freq"))
#
#           csv <- csv %>% mutate(midi = round(freq_to_midi(freq)))
#           csv$midi
#         })
#     }
#
#     page_promise <- future({ synchronise(do()) })
#
#     set_global("result", page_promise , state)
#
#   }),
#
#   one_button_page("Morning has broken!"),
#
#   reactive_page(function(state, ...) {
#     print('reactive page')
#     page_answer <- get_global("result", state)
#
#     page_answer <- future::value(page_answer)
#     print(page_answer)
#
#     present_stimuli(stimuli = page_answer,
#                     stimuli_type = "midi_notes",
#                     display_modality = "both")
#
#   }),

# psychTestR::page(label = "test", ui = div(tags$p("hey"), trigger_button("next", "Next")),
#   get_answer = function(input, ...) {
#   promise <- future({
#    Sys.sleep(5)
#     "here is the result2"
#   }) %...>% (function(result) {
#     print('here result')
#     print(result)
#     result
#   })
# },
# save_answer = TRUE
# ),
#
# elt_save_results_to_disk(complete = FALSE),
#
# one_button_page("hi there"),
#
#   elt_save_results_to_disk(complete = TRUE),
#
#   final_page("yo")
# )



