# constants

#setwd("/Users/sebsilas/PhD 2021/magma-Gold/magmaGold/R")
# get all includes

source('inc.R')


# PBET specific stuff

# constants
examples <- list("1" = "62,64,65,67,64,60,62",
                 "2" = "60,59,58,60,57,55")




PBET_example_protocol <- function(page_type) {

  c(

    one_button_page(body = tags$p("Now you will do two practice rounds.")),

    play_melody_until_satisfied_loop(melody = examples[['1']],
                                      var_name = "melody",
                                      max_goes = 3,
                                      page_type = page_type),

    play_melody_until_satisfied_loop(melody = examples[['2']],
                                      var_name = "melody",
                                      max_goes = 3,
                                      page_type = page_type),

    one_button_page(body = tags$p("Great, well done! Now you should be ready for the real test. Please ask the experimenter before proceeding, if you have any questions."))

  )

}


PBET_intro <- function(page_type) {

  list(
    one_button_page(body = div(tags$h2("Play By Ear Test"),
                               tags$img(src = 'img/music.png', height = 100, width = 100),
                               tags$img(src = 'img/saxophone.png', height = 100, width = 100),
                               tags$p("Welcome to the Play By Ear Test!")
    )),

    NAFC_page(label = "headphones_and_microphone_check",
              choices = c("Yes", "No"),
              prompt = div(tags$p("To complete this test, you will need:"),
                           tags$ul(
                             tags$li("headphones"),
                             tags$li("a quiet environment"),
                             tags$li("to record your instrument, either a good microphone", tags$em("or"),  "MIDI input device e.g keyboard already plugged in")
                           ),
                           tags$p("Before proceeding, do you have all the above?")),
              on_complete = have.requirements
    )
  )

}


PBET_instructions <- function() {
  list(
    one_button_page(body = div(tags$p("In this test, you will hear a melody."),
                               tags$p("You must perform this melody back on your instrument as accurately as you can."))
    ),

    one_button_page(body = div(tags$p("You can have up to 3 goes to get the melody as best you can."),
                               tags$p("It's okay if you don't think you got it. Just try your best each time!"))

    )
  )
}



PBET <- function(n_items) {

  if (is.list(n_items)) {
    n_items_key_difficulty <- n_items
    n_items <- sum(unlist(list("key_easy" = 10, "key_hard" = 10)))
  }

  audio_test <- build_multi_page_play_melody_until_satisfied_loop(n_items = n_items,
                                                    var_name = "melody",
                                                    page_type = "record_audio_page",
                                                    max_goes = 3)

  midi_test <- build_multi_page_play_melody_until_satisfied_loop(n_items = n_items,
                                                                  var_name = "melody",
                                                                  page_type = "record_midi_page",
                                                                  max_goes = 3)


  join(

    # introduction, same for all users
    PBET_intro(),

    # choose MIDI vs audio
    midi_vs_audio_select_page(),

    # setup audio/midi and then get user range via midi or audio format
    conditional(check.response.type.midi, c(select_midi_device_page(),
                                            code_block(fun = function(state, ...) {
                                              set_global("inst", "Piano", state)
                                            }),
                                            get_instrument_range_pages("record_midi_page"))),

    conditional(check.response.type.audio, c(microphone_calibration_page(),
                                             select_musical_instrument_page(),
                                             get_instrument_range_pages("record_audio_page"))),


    # build range based on pages
    build_test_items_from_user_range(), # it has default parameters

    # instructions
    PBET_instructions(),

    # example protocol in midi or audio format
    conditional(check.response.type.midi, PBET_example_protocol(page_type = "record_midi_page")),
    conditional(check.response.type.audio, PBET_example_protocol(page_type = "record_audio_page")),

    # if they selected MIDI, show the pages as MIDI otherwise audio
    conditional(check.response.type.midi, midi_test),
    conditional(check.response.type.audio, audio_test),

    final_page("You have completed the Play By Ear Test!")
  )
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


# run the test
test <- make_test(
  elts = PBET(n_items = list("key_easy" = 10, "key_hard" = 10)),
  opt = test_options(title = "PBE Test",
                     admin_password = "demo",
                     display = display_options(
                       left_margin = 1L,
                       right_margin = 1L,
                       css = 'www/css/style.css')
                     ),
  custom_admin_panel = aws_admin_panel)
