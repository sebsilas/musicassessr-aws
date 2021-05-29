
key_rankings_for_inst <- function(instrument_name, remove_atonal = TRUE) {

  if(nchar(instrument_name) > 4) {
    inst <- instrument_list[[instrument_name]]
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


sample_from_df <- function(df, no_to_sample) {
  n <- sample(nrow(df), no_to_sample)
  df[n, ]
}

sample_easy_key <- function(inst_name, no_to_sample = 1) {
  print('sample easy!')
  sample_from_df(easy_keys_for_inst(inst_name), no_to_sample)
}


sample_hard_key <- function(inst_name, no_to_sample = 1) {
  print('sample hard!')
  sample_from_df(hard_keys_for_inst(inst_name), no_to_sample)
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



sample_melody_in_key <- function(corpus = WJD, inst_name, bottom_range, top_range, difficulty) {

  if (difficulty == "easy") {
    key <- sample_easy_key(inst_name)
  }
  else {
    key <- sample_hard_key(inst_name)
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


sample_melody_in_easy_key <- function(corpus = WJD, inst_name, bottom_range, top_range) {
  sample_melody_in_key(corpus, inst_name, bottom_range, top_range, difficulty = "easy")
}

sample_melody_in_hard_key <- function(corpus = WJD, inst_name, bottom_range, top_range) {
  sample_melody_in_key(corpus, inst_name, bottom_range, top_range, difficulty = "hard")
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



# tests

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
# ressss4 <- sample_n_melodies_which_fit_in_range(corpus = WJD, n_range = 3:15,
#                                                 n_difficulty = list("easy" = 10, "hard" = 10),
#                                                 bottom_range = 48,
#                                                 top_range = 79,
#                                                 inst = "Trumpet")
#

#sample_melody_in_hard_key("Alto Saxophone", 58, 89)
#sample_melody_in_easy_key("Alto Saxophone", 58, 89)

# sample_melody_in_key("Alto Saxophone", 58, 89, "easy")
# sample_melody_in_key("Alto Saxophone",58, 89,"hard")
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



# ra <- given_range_what_keys_can_melody_go_in(melody = test_sub[1000, "melody"],
#                                                  bottom_range = 48, top_range = 79, "Piano")
#
# ra3 <- given_range_what_keys_can_melody_go_in(melody = test_sub[1001, "melody"],
#                                                        bottom_range = 48, top_range = 79, "Tenor Saxophone")
#
#
# ra4 <- given_range_what_keys_can_melody_go_in(melody = test_sub[1002, "melody"],
#                                                         bottom_range = 48, top_range = 79, "Alto Saxophone")
#
#
# ra5 <- given_range_what_keys_can_melody_go_in(melody = test_sub[1102, "melody"],
#                                                         bottom_range = 48, top_range = 79, "Piano")
#
#
# ra6 <- given_range_what_keys_can_melody_go_in(melody = test_sub[100, "melody"],
#                                                         bottom_range = 48, top_range = 79, "Tenor Saxophone")
#
#
# ra7 <- given_range_what_keys_can_melody_go_in(melody = "4,5,-5,-5,3,7,-7,7,-6,6,-2,-1,1",
#                                               bottom_range = 48, top_range = 79, "Piano")


# key_difficulty("C-maj", "Tenor Saxophone")
# key_difficulty("Ab-min", "Tenor Saxophone")
#
# hard_keys_for_inst("Piano")

# test_sub <- subset_corpus(WJD, N_range = c(3, NULL))
# test_sub[1000, "melody"]

