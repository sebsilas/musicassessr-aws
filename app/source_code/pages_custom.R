
select_musical_instrument_page <- function() {
  dropdown_page(label = "select_musical_instrument",
                prompt = "What musical instrument (including voice) are you using for the test?",
                choices = read_excel('dat/musical_instruments.xlsx')$Instruments,
                alternative_choice = TRUE,
                on_complete = function(state, answer, ...) {
                  set_global("inst", answer, state)
                })
}
