
validate.page.types <- function(page_type_string, args) {

  # check if certain page types have their required arguments
  # and give a descriptive error message back to user if they haven't specified something correctly

  if(page_type_string == "NAFC_page" |
     page_type_string == "dropdown_page") {

    if(is.null(args$label) | is.null(args$choices)) {
      stop('You must specify a label and choices for NAFC_page or dropdown_page')
    }
  }

  if(page_type_string == "slider_page") {

    if(is.null(args$label) | is.null(args$min)
       | is.null(args$max) | is.null(args$value)
    ) {
      stop('You must specify a label, min, max and value arguments for slider pages')
    }
  }

  if(page_type_string == "text_input_page") {

    if(is.null(args$label)) {
      stop('You must specify a label for text_input_page')
    }
  }
}

check.correct.argument.for.body <- function(page_type_string, args, stimuli_wrapped) {
  # feed the body to the page, but using the correct argument
  # i.e some pages accept "body" whilst others accept "prompt"
  if (page_type_string == "one_button_page" |
      page_type_string == "record_audio_page" |
      page_type_string == "record_key_presses_page") {
    args[["body"]] <- stimuli_wrapped
  }

  else if (page_type_string == "NAFC_page" |
           page_type_string == "dropdown_page" |
           page_type_string == "slider_page" |
           page_type_string == "text_input_page"
  ) {
    args[["prompt"]] <- stimuli_wrapped
  }
  else {
    ## leaving here for now in case there's another use I haven't thought of yet
  }
  args
}

item_bank_type_to_stimuli_type <- function (string_of_item_bank_type) {
  if(str_detect(string_of_item_bank_type, "RDS_file")) {
    item_bank_type <- str_remove(string_of_item_bank_type, "RDS_file_")
  }
  else {
    item_bank_type <- string_of_item_bank_type
  }
  item_bank_type
}
