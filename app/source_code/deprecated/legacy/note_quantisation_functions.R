# I was trying to build my own note quantisation functions to work work with crepe, but I never quite finished


# dummy data
test.freqs <- rjson::fromJSON('[null,null,null,"48.994",null,"157.246","164.710","160.893",null,"183.104","182.818","181.167",null,"197.421","194.457","194.390","191.403",null,"214.299","212.176","213.272",null,"165.948","179.314","174.452","179.328","179.515","179.066","165.803","173.314","161.201","131.728","143.177","139.873","138.825","167.436","162.594","161.918","159.721","163.350","155.710","162.359","163.859","155.899","163.856","161.111",null,null,null,"48.271"]')

test.freqs.wo.null <- as.numeric(unlist(lapply(test.freqs, function(x) ifelse(is.null(x), 0, x) )))

test.confidences <- as.numeric(rjson::fromJSON('["0.141","0.161","0.281","0.681","0.338","0.880","0.898","0.893","0.227","0.910","0.891","0.873","0.213","0.865","0.901","0.910","0.552","0.335","0.873","0.877","0.813","0.435","0.898","0.834","0.858","0.872","0.857","0.774","0.767","0.648","0.578","0.820","0.754","0.843","0.816","0.753","0.879","0.908","0.896","0.911","0.895","0.840","0.860","0.811","0.751","0.536","0.170","0.323","0.164","0.600"]'))

test.notes <- lapply(test.freqs.wo.null, function(x) ifelse(is.na(x) | x== 0, NA, round(freq_to_midi(as.numeric(x)))) )

test.onsets <- 1:length(test.notes)

tidy.freqs <- function(freqs) {
  freqs.wo.null <- as.numeric(unlist(lapply(freqs, function(x) ifelse(is.null(x), 0, x) )))
  notes <- lapply(freqs.wo.null, function(x) ifelse(is.na(x) | x== 0, NA, round(freq_to_midi(as.numeric(x)))) )

  # for (i in 3:length(onsets)) {
  #   if (notes[i] == 1) {
  #     notes[i-2] <- 0   # in Tony, they unvoice 2 frames behind an onset
  #   }
  #
  # }

  unlist(notes)
}


quantize.notes <- function(notes, onsets) {
  # use this quantize note function for graph plotting
  note_len <- length(notes)

  res <- c(NA)

  for (i in 2:(note_len-1) ) {

    if(is.na(notes[[i]]) | is.na(notes[[i+1]]))  {
      note <- NA
    }

    else {
      if(notes[[i]] == notes[[i+1]]) {
        note <- notes[[i]]
      }

      else {
        note <- NA
      }
    }

    res <- c(res, note)
  }

  res <- c(res, NA)
  res

}

#te <- tidy.freqs(c("119.471", "394.678", "394.784", "371.044", "393.409", "391.681", "388.690", "390.162", "265.363", "140.097", "145.947", "173.454", "137.096"))

#onsets <- c(0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)



mmed <- function(x,n=3){ #Median filter
  runmed(x,n)
}

abs.dif <- function(v) {
  abs(diff(v))
}

remove.semitones.bigger.than <- function(v, semitone_distance = 13) {

  # how many above the st distance will there be?
  v_dif <- abs.dif(v)

  # predetermine how many will violate the condition, so that the index counter will not go too far after deleting from the vector
  no_above <- sum(as.numeric(v_dif > semitone_distance))

  median_v <- median(v)

  no_seq <- 2:((length(v))-no_above)

  for (i in no_seq) {

    abs_dif <- abs.dif(c(v[i-1], v[i]))

    if(abs_dif > 13) {
      # which is further from the median? delete that one
      if(abs.dif(c(median_v, v[i-1])) > abs.dif(c(median_v, v[i])) ) {
        v <- v[-(i-1)]
      }
      else {
        v <- v[-(i)]
      }
    }

  }
  # separately check the last 2

  if(abs.dif(c(v[length(v)], v[length(v)-1])) > 13) {
    if(abs.dif(c(median_v, v[length(v)-1])) > abs.dif(c(median_v, v[length(v)])) ) {
      v <- v[-(length(v)-1)]
    }
    else {
      v <- v[-length(v)]
    }
  }

  v
}


# tests
# remove.semitones.bigger.than(c(51, 55, 58, 51, 63))
# remove.semitones.bigger.than(c(51, 55, 78, 58, 51, 63))
# remove.semitones.bigger.than(c(78, 55, 58, 51, 63))
# remove.semitones.bigger.than(c(51, 55, 58, 51, 78))
# remove.semitones.bigger.than(c(79,51, 55, 58, 51, 78))
# remove.semitones.bigger.than(c(79,51, 55, 98, 58, 51, 78))

quantize.notes.5 <- function(notes, onsets, timecodes) {

  # smooth pitches
  notes <- mmed(notes)

  notes <- c(notes[1], notes)
  onsets <- c(0, onsets)

  d <- data.frame(notes = notes,
                  onsets = onsets,
                  ioi = c(0, 0, (diff(timecodes)/1000)))


  #if the note changes or an onset was detected, add it to the result
  lapply(2:(nrow(d)-1) , function(i) {
    if(d[i, "notes"] != d[i-1, "notes"]) {
      d[i, "onsets"] <<- 1
    }
    else if (d[i, "notes"] == d[i-1, "notes"] & d[i, "onsets"] == 1) {
      d[i, "onsets"] <<- 1
    }
    else {
      # don't add it
    }
  })

  # minimum duration pruning:
  # The second
  # post-processing step, minimum duration pruning, simply
  # discards notes shorter than a threshold, usually chosen
  # around 100 ms.

  res <- d$notes[d$onsets == 1]
  names(d) <- c("notes", "onsets", "ioi")
  d
}

#tt <- tidy.freqs(fromJSON("[218.857,215.363,216.501,282.826,308.012,304.51,348.813,339.012,326.558,325.344,326.255]"))
#ttareOnsets <- rms.to.onsets(fromJSON("[0.39652647717925876,0.3955664386168783,0.29906582227974293,0.4079263545678725,0.2834057506880866,0.27853615157938993,0.30967820138719376,0.34042789640718013,0.28210271248932056,0.26430996798476764,0.20511536045225326]"))
#tttimecodes <- c(4179, 4279, 4396, 4618, 4730, 4842, 5068, 5186, 5297, 5399, 5510)

#asd <- quantize.notes.5(tt, ttareOnsets, tttimecodes)

sum.onsets <- function(df) {

  onset.idxes <- c(which(df$onsets == 1), (nrow(df)+1))

  for (i in 1:(length(onset.idxes)-1)) {
    seq <- seq(from = onset.idxes[i], to = (onset.idxes[i+1]-1))
    sub <- df[seq, ]
    tot.time <- sum(sub$ioi)
    df[onset.idxes[i], "note_dur"] <- tot.time
  }

  # for the last onset, custom


  df
}

#asd2 <- sum.onsets(asd)

# remove semitones greater than 13
#res <- remove.semitones.bigger.than(asd$notes)

#t.first <- asd2[unique(match(res, asd2$notes)),] # hmm problem at beginning

min.dur.prune <- function(df, min_dur = 0.1) {
  # remove durations less than a given amount
  res <- df %>% dplyr::filter(note_dur > min_dur)
  res
}

#sss <- min.dur.prune(t.first, 0.25)

# could I rewrite the semitone function based on the same principle as above? i.e, much simpler?


isOnset <- function(r, sensitivity = 0.8) {
  # determine if onset based on Tony scheme
  if (r > 1) {
    res <- as.numeric(1/r < sensitivity)
  }
  else {
    res <- 0
  }
  res
}

rms.to.onsets <- function(rms) {
  rms <- c(0, rms) # add a starting 0 for the algorithm loop
  areOnsets <- c(unlist(lapply(2:(length(rms)-1), function(x) isOnset(rms[x+1]/rms[x-1]) )),
                 0)
  rms <- rms[2:length(rms)] # remove the starting 0 again now processing done

  # removing repeating 1's (which catch the decrease in RMS?)
  for (i in 1:(length(areOnsets)-1)) {
    if (areOnsets[i] == 1 & areOnsets[i+1] == 1) {
      areOnsets[i] <- 0
    }
  }
  areOnsets
}



plot.rms.and.onset.data <- function(timecodes, rms, isOnset) {
  # plot rms changes and onset for testing
  rms.data <- data.frame(timecodes = timecodes, rms = rms, isOnset = isOnset)

  ggplot(rms.data, aes(timecodes) ) +
    geom_line(aes(y = rms, colour = "blue"), alpha = 0.5, size = 1) +
    geom_point(aes(y = rms, colour = "red"), shape=21, color="black", fill="#69b3a2", size=1) +
    geom_vline(aes(xintercept = timecodes),
               data = rms.data %>% filter(isOnset == 1)) +
    theme_ipsum() +
    ggtitle("rms")
  # end plots
}

get_answer_freq_to_notes <- function(input, ...) {

  # grab trial info
  timecodes <- as.numeric(fromJSON(input$timecodes))
  rms <- as.numeric(fromJSON(input$rmses))

  # process some new info
  freqs <- fromJSON(input$user_response_frequencies)
  notes <- tidy.freqs(freqs)
  areOnsets <- rms.to.onsets(rms)

  # plots for testing
  note.plot <- plot.note.data(notes, timecodes,  quantize.notes(notes))
  rms.plot <- plot.rms.and.onset.data(timecodes = timecodes, rms = rms, isOnset = areOnsets)

  list(stimuli = as.numeric(fromJSON(input$stimuli)),
       user_response_notes = quantize.notes.5(notes, areOnsets, timecodes),
       input$user_response_midi_note_off,
       timecodes = timecodes,
       note_no = input$note_no,
       user_response_frequencies = freqs,
       confidences = as.numeric(fromJSON(input$confidences)),
       plot = note.plot,
       rms = rms,
       rms_plot = rms.plot,
       stimuli_durations = as.numeric(fromJSON(input$stimuli_durations)),
       eventInterval = eventIntervals
  )


}
