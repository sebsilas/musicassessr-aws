
key_rankings_for_inst <- function(inst, remove_atonal = TRUE) {

  if(nchar(inst) > 4) {
    inst <- instrument_list[[inst]]
  }

  res <- filter(key_rankings, instrument == inst) %>% arrange(desc(n))

  if (remove_atonal) {
    res <- filter(res, key != "")
  }

  res
}

easy_keys_for_inst <- function(instrument_name) {
  ranking <- key_rankings_for_inst(instrument_name)
  easy_keys <- ranking[1:floor(nrow(ranking)/2), ]
  easy_keys
}


hard_keys_for_inst <- function(instrument_name) {
  # get the easy keys and just make sure that the sampled key is not in that list
  easy_keys <- easy_keys_for_inst(instrument_name)$key
  filter(keys_table, !key %in% easy_keys)
}
#

sample_from_df <- function(df, no_to_sample, replacement = FALSE) {
  print(replacement)
  n <- sample(x = nrow(df), size = no_to_sample, replace = replacement)
  df[n, ]
}

sample_easy_key <- function(inst_name, no_to_sample = 1, replacement = TRUE) {
  res <- sample_from_df(easy_keys_for_inst(inst_name), no_to_sample, replacement = replacement)
  res$difficulty <- rep("easy", no_to_sample)
  res
}


sample_hard_key <- function(inst_name, no_to_sample = 1, replacement = TRUE) {
  print('sample hard!')
  res <- sample_from_df(hard_keys_for_inst(inst_name), no_to_sample, replace = replacement)
  res$difficulty <- rep("hard", no_to_sample)
  res
}



produce_stimuli_in_range_and_key <- function(rel_melody, bottom_range = 21, top_range = 108, key) {
  # given some melodies in relative format, and a user range, produce random transpositions which fit in that range

  rel_melody <- str.mel.to.vector(rel_melody, sep = ",")
  dummy_abs_mel <- rel_to_abs_mel(rel_melody, start_note = 1)
  mel_range <- range(dummy_abs_mel)
  span <- sum(abs(mel_range))

  gamut <- bottom_range:top_range
  gamut_clipped <- (bottom_range+span):(top_range-span)
  random_abs_mel <- 200:210  # just instantiate something out of range
  current_key <- "fail" # and same for the current key

  # some melodies aren't transposable into a given key, given the user's range, so we need a way out
  count <- 0

  while(any(!random_abs_mel %in% gamut) | current_key != key) {
    # resample until a melody is found that sits in the range
    # and is the correct tonality
    random_abs_mel_start_note <- sample(gamut, 1)
    random_abs_mel <- rel_to_abs_mel(rel_melody, start_note = random_abs_mel_start_note)
    current_key <- get_implicit_harmonies(random_abs_mel)$key
    count <- count + 1

    if(span > top_range - bottom_range) {
      print('The span of the stimuli is greater than the range of the instrument. It is not possible to play on this instrument.')
      break
    }

    if (count == 144) {
      random_abs_mel <- "error"
      print("error!")
      break
    }
  }

  random_abs_mel
}



sample_melody_in_key <- function(corpus = WJD, inst, bottom_range, top_range, difficulty) {

  if (difficulty == "easy") {
    key <- sample_easy_key(inst)
  }
  else {
    key <- sample_hard_key(inst)
  }

  key_tonality <- key$key_tonality
  user_span <- top_range - bottom_range

  corpus_subset <- subset_corpus(corpus, tonality = key_tonality, span_min = user_span)

  i <- sample(1:nrow(corpus_subset), 1)
  rel_mel <- corpus_subset[i, "melody"]
  abs_mel <- "error"

  while(abs_mel == "error") {
    # try again if it didn't fit
    i <- sample(1:nrow(corpus_subset), 1)
    rel_mel <- corpus_subset[i, "melody"]
    abs_mel <- produce_stimuli_in_range_and_key(rel_mel,
                                                bottom_range = bottom_range,
                                                top_range = top_range,
                                                key = key$key)
  }

  abs_mel
}


sample_melody_in_easy_key <- function(corpus = WJD, inst, bottom_range, top_range) {
  sample_melody_in_key(corpus = corpus, inst = inst, bottom_range = bottom_range, top_range = top_range, difficulty = "easy")
}

sample_melody_in_hard_key <- function(corpus = WJD, inst, bottom_range, top_range) {
  sample_melody_in_key(corpus = corpus, inst = inst, bottom_range = bottom_range, top_range = top_range, difficulty = "hard")
}


key_difficulty <- function(key, inst) {
  # given key and instrument, is the key considered easy or difficult
  if(key %in% hard_keys_for_inst(inst)$key) {
    return("hard")
  }
  else {
    return("easy")
  }
}

check_all_notes_in_range <- function(abs_mel, bottom_range, top_range) {
  range <- bottom_range:top_range
  all(abs_mel %in% range)
}

given_range_what_keys_can_melody_go_in <- function(melody, bottom_range = 48, top_range = 79, inst) {
  # check, starting from every note in the range, if the whole melody fits in the range,
  # if it fits, then list the key it is possible in, and give the starting note

  range <- bottom_range:top_range

  res <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("melody", "start_note", "key"))

  for (start_note in range) {

    abs_mel <- rel_to_abs_mel(str.mel.to.vector(melody, ","), start_note = start_note)
    if(all(abs_mel %in% range)) {
      key <- get_implicit_harmonies(abs_mel)$key
      res <- rbind(res, data.frame(melody = melody, start_note = start_note, key = key))
    }
    names(res) <- c("melody", "start_note", "key")
  }
  res$difficulty <- unlist(lapply(res$key, key_difficulty, inst))
  res
}




given_range_what_keys_can_melody_go_in2 <- function(melody, bottom_range = 48, top_range = 79, inst) {
  # check, starting from every note in the range, if the whole melody fits in the range,
  # if it fits, then list the key it is possible in, and give the starting note
  #system.time({
  range <- bottom_range:top_range

  res <- data.frame(start_note = bottom_range:top_range,
                    melody = melody
                    )

  res <- res %>%
          rowwise %>%
          mutate(abs_melody = paste0(rel_to_abs_mel(rel_mel = str.mel.to.vector(melody, ","), start_note = start_note), collapse = ","),
                 in_range = all(str.mel.to.vector(abs_melody, ",") %in% range)
                 ) %>%
                filter(in_range == TRUE)

  idxes <- sample(1:nrow(res), 10)

  for (i in idxes) {
    abs_melody <- res[i, "melody"]
    key <- get_implicit_harmonies(str.mel.to.vector(abs_melody, ","))$key
  }

  # mutate(key = get_implicit_harmonies(str.mel.to.vector(abs_melody, ","))$key) %>%
  #   rowwise %>%
  #     mutate(difficulty = key_difficulty(key, inst))

  res
  #})

}


produce_stimuli_in_range_and_key <- function(rel_melody, bottom_range = 21, top_range = 108, key) {
  # given some melodies in relative format, and a user range, produce random transpositions which fit in that range

  rel_melody <- str.mel.to.vector(rel_melody, sep = ",")
  dummy_abs_mel <- rel_to_abs_mel(rel_melody, start_note = 1)
  mel_range <- range(dummy_abs_mel)
  span <- sum(abs(mel_range))

  gamut <- bottom_range:top_range
  gamut_clipped <- (bottom_range+span):(top_range-span)
  random_abs_mel <- 200:210  # just instantiate something out of range
  current_key <- "fail" # and same for the current key

  # some melodies aren't transposable into a given key, given the user's range, so we need a way out
  count <- 0

  while(any(!random_abs_mel %in% gamut) | current_key != key) {
    # resample until a melody is found that sits in the range
    # and is the correct tonality
    random_abs_mel_start_note <- sample(gamut, 1)
    random_abs_mel <- rel_to_abs_mel(rel_melody, start_note = random_abs_mel_start_note)
    current_key <- get_implicit_harmonies(random_abs_mel)$key
    count <- count + 1

    if(span > top_range - bottom_range) {
      print('The span of the stimuli is greater than the range of the instrument. It is not possible to play on this instrument.')
      break
    }

    if (count == 144) {
      random_abs_mel <- "error"
      print("error!")
      break
    }
  }

  random_abs_mel
}


###

# ra.2 <- given_range_what_keys_can_melody_go_in2(melody = test_sub[1000, "melody"],
#                                              bottom_range = 48, top_range = 79, "Piano")
#
# rra3.2 <- given_range_what_keys_can_melody_go_in2(melody = test_sub[1001, "melody"],
#                                               bottom_range = 48, top_range = 79, "Tenor Saxophone")
#
#
# ra4.2 <- given_range_what_keys_can_melody_go_in2(melody = test_sub[1002, "melody"],
#                                               bottom_range = 48, top_range = 79, "Alto Saxophone")
#
#
# ra5.2 <- given_range_what_keys_can_melody_go_in2(melody = test_sub[1102, "melody"],
#                                               bottom_range = 48, top_range = 79, "Piano")
#
#
# ra6.2 <- given_range_what_keys_can_melody_go_in2(melody = test_sub[100, "melody"],
#                                               bottom_range = 48, top_range = 79, "Tenor Saxophone")
#
#
# ra7.2 <- given_range_what_keys_can_melody_go_in2(melody = "4,5,-5,-5,3,7,-7,7,-6,6,-2,-1,1",
#                                               bottom_range = 48, top_range = 79, "Piano")
#
#
#
#
#
#
# ###
#
# ra <- given_range_what_keys_can_melody_go_in(melody = test_sub[1000, "melody"],
#                                              bottom_range = 48, top_range = 79, "Piano")
#
# ra3 <- given_range_what_keys_can_melody_go_in(melody = test_sub[1001, "melody"],
#                                               bottom_range = 48, top_range = 79, "Tenor Saxophone")
#
#
# ra4 <- given_range_what_keys_can_melody_go_in(melody = test_sub[1002, "melody"],
#                                               bottom_range = 48, top_range = 79, "Alto Saxophone")
#
#
# ra5 <- given_range_what_keys_can_melody_go_in(melody = test_sub[1102, "melody"],
#                                               bottom_range = 48, top_range = 79, "Piano")
#
#
# ra6 <- given_range_what_keys_can_melody_go_in(melody = test_sub[100, "melody"],
#                                               bottom_range = 48, top_range = 79, "Tenor Saxophone")
#
#
# ra7 <- given_range_what_keys_can_melody_go_in(melody = "4,5,-5,-5,3,7,-7,7,-6,6,-2,-1,1",
#                                               bottom_range = 48, top_range = 79, "Piano")



#sum(unlist(lapply(list(ra, ra3, ra4, ra5, ra6, ra7), function(x) x[3])))
#sum(unlist(lapply(list(ra.2, ra3.2, ra4.2, ra5.2, ra6.2, ra7.2), function(x) x[3])))



# grab WJD corpus
WJD_corpus_df <- read_rds("www/item_banks/WJD_corpus.RDS")

# grab WJD meta info
wjd_meta <- read.csv2('www/item_banks/wjd_meta.csv')
# standardise namings
wjd_meta$key[wjd_meta$key=="D#-maj"] <- "Eb-maj"
wjd_meta$key[wjd_meta$key=="C#-maj"] <- "Db-maj"

# produce tables of all possible keys
keys_maj <- paste0(pc_labels, '-maj')
keys_min <- paste0(pc_labels, '-min')
keys_list <- c(keys_maj, keys_min)
keys_table <- tibble(key = keys_list,
                     key_centre = c(pc_labels, pc_labels),
                     key_tonality = c(rep("major", 12), rep("minor", 12))
)

# list of instruments in the WJD
instrument_list <- as.list(levels(as.factor(wjd_meta$instrument)))
# attach long name format, to allow the grabbing of the abbreviated form
names(instrument_list) <- c("Alto Saxophone", "Bass Clarinet", "Bass", "Clarinet", "Cornet", "Guitar", "Piano",
                            "Soprano Saxophone", "Trombone", "Trumpet", "Tenor Saxophone", "C Tenor Saxophone", "Vibraphone")


# create key rankings table
key_rankings <- group_by(wjd_meta, instrument) %>% dplyr::count(key)
key_rankings$key_centre <- sapply(key_rankings$key, function(x) strsplit(x, "-")[[1]][1])
key_rankings$key_tonality <- sapply(key_rankings$key, function(x) strsplit(x, "-")[[1]][2])
key_rankings$key_tonality[key_rankings$key_tonality == "maj"] <- "major"
key_rankings$key_tonality[key_rankings$key_tonality == "min"] <- "minor"

###

sample_keys_by_difficulty <- function(inst, n_easy, n_hard) {
  easy <- sample_easy_key(inst, no_to_sample = n_easy)
  hard <- sample_hard_key(inst, no_to_sample = n_hard)
  rbind(easy, hard)
}


# sampled_keys <- sample_keys_by_difficulty("Alto Saxophone", 10, 10)
#
#
# # tests
#
# ressss <- sample_n_melodies_which_fit_in_range(corpus = WJD,
#                                                n_range = 3:15,
#                                                n_difficulty = list("easy" = 10, "hard" = 10),
#                                                bottom_range = 48,
#                                                top_range = 79,
#                                                inst = "Piano")
#
#
# ressss2 <- sample_n_melodies_which_fit_in_range(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                bottom_range = 48,
#                                                top_range = 79,
#                                                inst = "Tenor Saxophone")
#
#
# ressss3 <- sample_n_melodies_which_fit_in_range(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                 bottom_range = 48,
#                                                 top_range = 79,
#                                                 inst = "Alto Saxophone")
#
#
#
# ressss4 <- sample_n_melodies_which_fit_in_range2(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                 bottom_range = 48,
#                                                 top_range = 79,
#                                                 inst = "Trumpet")
#
#
# ####
#
# ressss <- sample_n_melodies_which_fit_in_range2(corpus = WJD,
#                                                n_range = 3:15,
#                                                n_difficulty = list("easy" = 10, "hard" = 10),
#                                                bottom_range = 48,
#                                                top_range = 79,
#                                                inst = "Piano")
#
#
# ressss2 <- sample_n_melodies_which_fit_in_range2(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                 bottom_range = 48,
#                                                 top_range = 79,
#                                                 inst = "Tenor Saxophone")
#
#
# ressss3 <- sample_n_melodies_which_fit_in_range2(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                 bottom_range = 48,
#                                                 top_range = 79,
#                                                 inst = "Alto Saxophone")
#
#
#
# ressss4 <- sample_n_melodies_which_fit_in_range2(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                 bottom_range = 48,
#                                                 top_range = 79,
#                                                 inst = "Trumpet")
#
#
# ####
#
#
# sample_melody_in_hard_key(inst = "Alto Saxophone", bottom_range = 58, top_range = 89)
# sample_melody_in_easy_key(inst = "Alto Saxophone", bottom_range = 58, top_range = 89)
#

#
# sample_melody_in_key("Tenor Saxophone",  44, 76, "easy")
# sample_melody_in_key("Tenor Saxophone",  44, 76, "hard")
#
# sample_melody_in_key("Piano", 48, 79, "easy")
# sample_melody_in_key("Piano", 48, 79, "hard")

# sample_easy_key("Piano")
# key_rankings_for_inst("Piano")
# tt <- hard_keys_for_inst("Piano")
# tt <- hard_keys_for_inst("Alto Saxophone")
# tt <- hard_keys_for_inst("Tenor Saxophone")
#
# key_rankings_for_inst("Alto Saxophone")
# easy_keys_for_inst("Alto Saxophone")
# easy_keys_for_inst("Piano")
#
# hard_keys_for_inst("Alto Saxophone")
#
# key_rankings_for_inst("Clarinet")
# easy_keys_for_inst("Clarinet")
# hard_keys_for_inst("Clarinet")
#
# sample_easy_key("Alto Saxophone")
#
# sample_melody_in_easy_key("Tenor Saxophone",  44, 76)

# key_rankings_for_inst("Alto Saxophone")
#
# alto_range <- 58:89
# tenor_range <- 44:76
# sample_melody_in_easy_key("Alto Saxophone", 58, 89)
# sample_melody_in_hard_key("Alto Saxophone", 58, 89)
# sample_melody_in_hard_key("Tenor Saxophone", 44, 76)
# sample_melody_in_easy_key("Tenor Saxophone",  44, 76)
# hi <- sample_melody_in_easy_key("Piano", 48, 79)
#
#
# ts_hard <- hard_keys_for_inst("Tenor Saxophone")
# ts_easy <- easy_keys_for_inst("Tenor Saxophone")
# easy_keys_for_inst("Tenor Saxophone")
#
# sample_melody_in_easy_key("Piano", 48, 79)


#sample_melody_in_easy_key("Piano", 48, 79)



#test_sub <- subset_corpus(WJD, N_range = c(3, NULL))
#test_sub[1000, "melody"]



# key_difficulty("C-maj", "Tenor Saxophone")
# key_difficulty("Ab-min", "Tenor Saxophone")
#
# hard_keys_for_inst("Piano")


###
#
# ressss <- sample_n_melodies_which_fit_in_range(corpus = WJD,
#                                                n_range = 3:15,
#                                                n_difficulty = list("easy" = 1, "hard" = 0),
#                                                bottom_range = 48,
#                                                top_range = 79,
#                                                inst = "Piano")
#
# sample_melody_in_easy_key(inst = "Alto Saxophone", bottom_range = 58, top_range = 89)
# sample_melody_in_hard_key(inst = "Alto Saxophone", bottom_range = 58, top_range = 89)
#





############



sample_melody_in_key2 <- function(corpus = WJD, inst, bottom_range, top_range, difficulty, length = NULL) {

  if (difficulty == "easy") {
    key <- sample_easy_key(inst)
  }
  else {
    key <- sample_hard_key(inst)
  }

  key_tonality <- key$key_tonality
  key_centre <- key$key_centre
  user_span <- top_range - bottom_range

  # sample melody

  corpus_subset <- subset_corpus(corpus, tonality = key_tonality, span_max = user_span, length = length)

  i <- sample(1:nrow(corpus_subset), 1)
  rel_mel <- corpus_subset[i, "melody"]

  # now put it in a key
  print(key_tonality)
  print(key_centre)
  print(user_span)
  print(length)

  key_centres <- pitch.class.to.midi.notes(key_centre)

  key_centres_in_range <- key_centres[key_centres > bottom_range & key_centres < top_range]

  # first try it with the first note as being the key centre
  abs_mel <- rel_to_abs_mel(str.mel.to.vector(rel_mel, ","), start_note = key_centres_in_range[1])
  print(abs_mel)
  # check key
  mel_key <- get_implicit_harmonies(abs_mel)
  print(mel_key)
  mel_key_centre <- unlist(strsplit(mel_key$key, "-"))[[1]]
  print(mel_key_centre)
  # how far away is it from being the correct tonal centre?
  dist <- pitch.class.to.numeric.pitch.class(key_centre) - pitch.class.to.numeric.pitch.class(mel_key_centre)
  print(dist)

  if (dist != 0) {
    print('must transpose!')
    print('in: ')
    print(abs_mel)
    abs_mel <- abs_mel + dist
    print('out :')
    print(abs_mel)
  }

  # check all notes in range
  print('notes in range?')
  if(check_all_notes_in_range(abs_mel, bottom_range, top_range)) {
    print('in range!')
    print(abs_mel)
    return(abs_mel)
  }
  else {
    print('not in range!')
    print('range: ')
    print(bottom_range)
    print(top_range)
    print('mel: ')
    print(abs_mel)
    # try octave either side
    abs_mel_down <- abs_mel + 12
    abs_mel_up <- abs_mel - 12
    if(check_all_notes_in_range(abs_mel_up, bottom_range, top_range) & check_all_notes_in_range(abs_mel_down, bottom_range, top_range)) {
      print('both in range, randomly select one')
      snap <- sample(1:2, 1)
      if(snap == 1) {
        return(abs_mel_down)
      }
      else {
        return(abs_mel_up)
      }
    }
    else if (check_all_notes_in_range(abs_mel_up, bottom_range, top_range) & !check_all_notes_in_range(abs_mel_down, bottom_range, top_range)) {
      print('only octave up in range, return that')
      print(abs_mel_up)
      return(abs_mel_up)
    }
    else if (!check_all_notes_in_range(abs_mel_up, bottom_range, top_range) & check_all_notes_in_range(abs_mel_down, bottom_range, top_range)) {
      print('only octave down in range, return that')
      print(abs_mel_down)
      return(abs_mel_down)
    }
    else {
      print('neither is in range, try a new melody!')
      print('abs_mel_up')
      print(abs_mel_up)
      print('abs_mel_down')
      print(abs_mel_down)
    }

  }

}


#
# da1 <- sample_melody_in_key2(inst = "Alto Saxophone", bottom_range = 58, top_range = 89, difficulty = "easy", length = 15)
# da2 <- sample_melody_in_key2(inst = "Alto Saxophone", bottom_range = 58, top_range = 89, difficulty = "hard", length = 15)
#
# trial_char <- get_trial_characteristics(trial_df = pra, trial_no = 20)
#
# da3 <- sample_melody_in_key2(inst = "Alto Saxophone", bottom_range = 58, top_range = 89, difficulty = trial_char$difficulty, length = trial_char$melody_length)
# da4 <- sample_melody_in_key2(inst = "Alto Saxophone", bottom_range = 58, top_range = 89, difficulty = trial_char$difficulty, length = trial_char$melody_length)
