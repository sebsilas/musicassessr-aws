# constants

#setwd("/Users/sebsilas/PhD 2021/magma-Gold/magmaGold/R")
# get all includes

source('inc.R')


# PBET specific stuff

# constants
examples <- list("1" = "62,64,65,67,64,60,62",
                 "2" = "60,59,58,60,57,55")







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
                           tags$ul(class = "roman",
                             tags$li("headphones"),
                             tags$li("a quiet environment"),
                             tags$li("to record your instrument, either: "),
                              tags$ul(class = "square",
                                      tags$li("a microphone", tags$em("or")),
                                      tags$li("a MIDI input device already plugged in")
                           )),
                           tags$p("Before proceeding, do you have all the above?")),
              on_complete = have.requirements
    )
  )

}


check_melodies_built <- function() {
  while_loop(
  test =  function(state, ...) {
    melodies <- get_global("melodies", state)
    print('check melodies built')
    is.null(melodies)
    },
  logic = list(one_button_page("Your test is still being built. Please wait a few moments, until a message pops up saying the test is ready, then try again."))
  )
}



PBET_example_protocol <- function(page_type) {

  c(

    one_button_page(body = tags$p("Now you will do two practice rounds.")),

    play_melody_until_satisfied_loop(melody = examples[['1']],
                                     var_name = "melody",
                                     max_goes = 3,
                                     page_type = page_type,
                                     get_answer = get_answer_null),

    play_melody_until_satisfied_loop(melody = examples[['2']],
                                     var_name = "melody",
                                     max_goes = 3,
                                     page_type = page_type,
                                     get_answer = get_answer_null),

    one_button_page(body = div(tags$p("Great, well done! Now you should be ready for the real test."), tags$p("Please ask the experimenter before proceeding, if you have any questions.")))

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
    conditional(test = check.response.type.midi,
                logic = c(select_midi_device_page(),
                          code_block(fun = function(state, ...) {
                            set_global("inst", "Piano", state)
                          }),
                          get_instrument_range_pages("record_midi_page")
                          )
                ),

    conditional(test = check.response.type.audio,
                logic = c(microphone_calibration_page(),
                          select_musical_instrument_page(),
                          get_instrument_range_pages("record_audio_page")
                          )
                ),


    # build range based on pages

    items_characteristics_sampler_block(),

    # instructions
    PBET_instructions(),

    # example protocol in midi or audio format
    conditional(check.response.type.midi, PBET_example_protocol(page_type = "record_midi_page")),
    conditional(check.response.type.audio, PBET_example_protocol(page_type = "record_audio_page")),

    # if they selected MIDI, show the pages as MIDI otherwise audio
    conditional(check.response.type.midi, midi_test),
    conditional(check.response.type.audio, audio_test),

    elt_save_results_to_disk(complete = TRUE),

    final_page("You have completed the Play By Ear Test!")
  )
}




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


#rsconnect::deployApp('/Users/sebsilas/PhD 2021/magma-Gold/magmaGold/R', appName = "PBET", account = "synthesoshiny")
