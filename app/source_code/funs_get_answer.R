
get_answer_simple_send_to_s3 <- function(input, ...) {
  print("get_answer simple sent to s3!")
  print(input$timestamp)
  print(input$answer_meta_data)
  list(timestamp = input$timestamp,
       meta_data = input$answer_meta_data)
}




get_answer_midi_note_mode <- function(input, ...) {
  list(note = getmode(fromJSON(input$user_response_midi_note_on)))
}



get_answer_midi <- function(input, ...) {
  list(notes = fromJSON(input$user_response_midi_note_on))
}

# get answer functions

get_answer_grab_s3_file <- function(input, ...) {

  start_time <- Sys.time()

  print('get_answer_grab_s3_file')

  timestamp <- input$timestamp
  csv.file <- paste0(timestamp, ".csv")

  attempts <- 1

  # keep polling to see what the file gets there
  while(attempts < 100 | head_object(csv.file, 'hmtm-2nd-out') == "FALSE") {
    attempts <- attempts + 1
  }

  if(head_object(csv.file, 'hmtm-2nd-out') == "TRUE") {

    trial.csv <- read_melody_text(text = rawToChar(get_object(object = csv.file, bucket = "hmtm-2nd-out")))

    end_time <- Sys.time()
    time_taken <- end_time - start_time
    cat('time taken to get file was', time_taken)
    print(trial.csv)

  }



  list(onset = trial.csv$onset,
       dur = trial.csv$dur,
       user_pitch = trial.csv$pitch
  )

}


get_answer_average_frequency_ff <- function(floor_or_ceiling, ...) {

  print("get_answer_average_frequency_ff")
  # function factory
  # either round up or down to not go too low or too high for the user when rounding

  if (floor_or_ceiling == "floor") {

    function(input, ...) {
      # process some new info
      freqs <- fromJSON(input$user_response_frequencies)
      notes <- tidy_freqs(freqs)
      list(user_response = floor(mean(notes)))
    }

  }

  else if (floor_or_ceiling == "ceiling") {

    function(input, ...) {
      # process some new info
      freqs <- fromJSON(input$user_response_frequencies)
      notes <- tidy_freqs(freqs)
      list(user_response = ceiling(mean(notes)))
    }

  }


  else {

    function(input, ...) {
      # process some new info
      freqs <- fromJSON(input$user_response_frequencies)
      notes <- tidy_freqs(freqs)
      list(user_response = round(mean(notes)))
    }
  }

}



get_answer_store_async <- function(input, state, page_id, ...) {

  print('get_answer_store_async!')
  print(page_id)

  json <- rjson::toJSON(list(sourceBucket = input$sourceBucket,
                             key = input$key,
                             destBucket = input$destBucket))


  do <- function() {
    headers <- c("content-type" = "application/json")
    http_post("https://pv3r2l54zi.execute-api.us-east-1.amazonaws.com/prod/api", data = json, headers = headers)$
      then(http_stop_for_status)$
      then(function(x) {

        key <- rjson::fromJSON(rawToChar(x$content))$key
        bucket <- rjson::fromJSON(rawToChar(x$content))$Bucket
        link_href <- paste0("https://", bucket, ".s3.amazonaws.com/", key)
        csv <- read_csv(link_href, col_names = c("onset", "dur", "freq"))
        csv <- csv %>% mutate(midi = round(freq_to_midi(freq)))
        csv$midi

      })
  }

  page_promise <- future({ synchronise(do()) })

  set_global(page_id, page_promise , state)

}

get_answer_store_async_builder <- function(page_id) {
  print('get_answer_store_async_builder')
  print(page_id)
  get_answer_store_async <- function(input, state, ...) {

    print('get_answer_store_async!')
    print(page_id)

    json <- rjson::toJSON(list(sourceBucket = input$sourceBucket,
                               key = input$key,
                               destBucket = input$destBucket))


    do <- function() {
      headers <- c("content-type" = "application/json")
      http_post("https://pv3r2l54zi.execute-api.us-east-1.amazonaws.com/prod/api", data = json, headers = headers)$
        then(http_stop_for_status)$
        then(function(x) {

          key <- rjson::fromJSON(rawToChar(x$content))$key
          bucket <- rjson::fromJSON(rawToChar(x$content))$Bucket
          link_href <- paste0("https://", bucket, ".s3.amazonaws.com/", key)
          csv <- read_csv(link_href, col_names = c("onset", "dur", "freq"))
          csv <- csv %>% mutate(midi = round(freq_to_midi(freq)))
          csv$midi

        })
    }

    page_promise <- future({ synchronise(do()) })

    set_global(page_id, page_promise , state)

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
