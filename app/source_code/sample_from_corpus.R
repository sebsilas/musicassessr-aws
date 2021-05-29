library(dplyr)
library(sjmisc)

options(scipen = 999)


remove.duplicates.and.resample <- function(df, item_bank) {

  # resample until there are no more duplicates in df
  # but make sure the same N as the removed duplicate

  while(any(duplicated(df)) == TRUE) {

    duplicates <- df[duplicated(df), ]

    # remove duplicates
    df <- df[!duplicated(df), ]

    # resample
    for (n in duplicates$N) {
      N.subset <- df[df[, "N"] == n, ]
      rand.samp.i <- sample(1:nrow(N.subset), 1)
      df <- rbind(df, item_bank[rand.samp.i, ])
    }

  }

  # order
  df <- df[order(df$N), ]

  df

}


item.sampler.by.N.list <- function(item_bank, no_items) {

  # take a sample to grab the shape
  sample <- item_bank[1, ]

  for (i in names(no_items)) {
    N.subset <- item_bank[item_bank[, "N"] == i, ]
    rand.samp.i <- sample(1:nrow(N.subset), as.numeric(no_items[[i]]), replace = FALSE)
    rand.samp <- N.subset[rand.samp.i, ]
    sample <- rbind(sample, rand.samp)
  }

  # pop off the first sample that was taken for a shape
  sample <- sample[2:nrow(sample), ]

  # remove duplicates
  #sample <- remove.duplicates.and.resample(sample, item_bank)

}



list.of.Ns.to.vector <- function(list_of_Ns) {
  # take in named list and convert it to a single vector

  res <- lapply(seq_along(list_of_Ns), function(x) rep(names(list_of_Ns)[[x]], list_of_Ns[[x]]))

  res <- as.numeric(unlist(res))
  res
}



item.sampler.simple <- function(item_bank, no_items) {
  # a simple item sampler for a list of files
  # optionally, specify a list of note numbers (N) to cap each file playback at

  # get length of item bank
  if (is.data.frame(item_bank)) {
    item_bank_length <- nrow(item_bank)
  }
  else {
    item_bank_length <- length(item_bank)
  }


  if(class(no_items) == "list" & is.data.frame(item_bank)) {
    stop('Item bank must be in list format e.g MIDI file list')
  }


  if(class(no_items) == "list") {

    vectorNs <- list.of.Ns.to.vector(no_items)

    if(length(vectorNs) > item_bank_length) {
      stop('The number of items requested is longer than the item bank length!')
    }
    sample.temp <- sample(item_bank, length(vectorNs))
    sample <- as.list(as.numeric(paste(unlist(vectorNs))))
    names(sample) <- sample.temp
  }

  else {
    if(no_items > item_bank_length) {
      stop('The number of items requested is longer than the item bank length!')
    }

    sample <- sample(item_bank, no_items)
  }

  sample
}


item.sampler.rds <- function(item_bank, no_items) {
  print('item.sampler.rds')
  print(item_bank)

  if(is.list(no_items) == TRUE) {

    vectorNs <- list.of.Ns.to.vector(no_items)
    #print(vectorNs)
    if(length(vectorNs) > length(item_bank)) {
      print('we here')
      stop('The number of items requested is longer than the item bank length!')
    }
    else {
      print('else')
      sample <- sample(item_bank, length(vectorNs))
      #print(sample)
      sample <- lapply(seq_along(vectorNs), function(x) sample[[x]][1:vectorNs[x]])
    }
  }

  else {

  }
  print(sample)
  sample
}


# NB: this is a better version of item.sampler. use this
item_sampler <- function(item_bank, no_items) {

  # what values are there?
  N_values <- unique(item_bank$N)
  no_of_Ns <- length(N_values)
  # given the no. of items, how many of each N will we need? let's count

  idxes <- rep(1:no_of_Ns, ceiling(no_items/no_of_Ns))

  count <- 1
  N_list <- c()

  while(count < no_items+1) {
    N_list <- c(N_list, N_values[idxes[count]])
    count <- count + 1
  }

  tabl <- as.data.frame(table(N_list))

  sample_dat <- apply(tabl, MARGIN = 1, function(x) {
    dat_subset <- item_bank[item_bank$N == as.integer(x["N_list"]), ]
    sample_i <- sample(1:nrow(dat_subset), x["Freq"])
    sampl <- dat_subset[sample_i, ]
  })

  res <- bind_rows(sample_dat)
  res$trial_no <- 1:nrow(res)
  res
}



sample_n_melodies_which_fit_in_range <- function(corpus, n_difficulty = list("easy" = 5, "hard" = 5), n_range = NULL,
                                                 bottom_range = 48, top_range = 79, inst) {

  req_n_easy <- n_difficulty$easy
  req_n_hard <- n_difficulty$hard

  if(is.null(n_range)) {
    n_range <- min(corpus$N):max(corpus$N)
  }

  # instantiate counters
  n_easy <- 0
  n_hard <- 0

  without <- c()

  ncols <- length(names(corpus)) + 3 # i.e start_note, key,  difficulty

  res <- setNames(data.frame(matrix(ncol = ncols, nrow = 0)), c("start_note", "key", "difficulty", names(corpus)))

  while(req_n_easy != n_easy | req_n_hard != n_hard) {

    for(n in n_range) {
      #corpus_without_replacement <- corpus %>% filter(!melody %in% without)
      corpus_without_replacement <- corpus %>% filter(N == n)
      sampled <- sample_from_df(corpus_without_replacement, 1)
      sampled_melody <- sampled[, "melody"]
      sampled_melody_N <- sampled[, "N"]

      keys <- given_range_what_keys_can_melody_go_in(melody = sampled_melody,
                                                     bottom_range = bottom_range,
                                                     top_range = top_range, inst = inst)
      if(nrow(keys) != 0) {
        if("easy" %in% keys$difficulty & req_n_easy != n_easy) {
          # this slightly biases going for easier keys when they come up, which is useful since they are less common
          keys <- keys %>% filter(difficulty == "easy")
          sampled_key <- select(sample_from_df(keys, 1), -melody)
          res <- rbind(res, cbind(sampled_key, sampled))
        }
        else {
          if (req_n_hard != n_hard) {
            keys <- keys %>% filter(difficulty == "hard")
            sampled_key <- select(sample_from_df(keys, 1), -melody)
            res <- rbind(res, cbind(sampled_key, sampled))
          }
        }
      }

      if (nrow(res) > 2) {
        count <- res %>% count(difficulty)
        n_easy <- count %>% filter(difficulty == "easy") %>% select (n)
        n_hard <- count %>% filter(difficulty == "hard") %>% select (n)
        n_easy <- as.integer(n_easy)
        n_hard <- as.integer(n_hard)
        if(is.na(n_easy)) { n_easy <- 0 }
        if(is.na(n_hard)) { n_hard <- 0 }
      }
    }
  }

  res$abs_mel <- apply(res, MARGIN = 1, function(x) paste0(rel_to_abs_mel(str.mel.to.vector(x['melody'], sep = ","), as.integer(x['start_note'])), collapse = ","))
  res <- res[order(res$N), ]
  rownames(res) <- 1:nrow(res)
  res

}

build_test_items_from_user_range <- function(corpus = WJD, n_range = 3:15, n = 20, n_difficulty = list("easy" = 10, "hard" = 10), top_range = NULL, bottom_range = NULL, inst = NULL) {

  if(n != sum(as.vector(unlist(list("easy" = 10, "hard" = 10))))) {
    stop("n must == the total of n_difficulty")
  }

  code_block(function(state, ...) {

    if(is.null(top_range)) {
      top_range <- get_global("top_range", state)
    }

    if(is.null(bottom_range)) {
      bottom_range <- get_global("bottom_range", state)
    }

    if(is.null(inst)) {
      inst <- get_global("inst", state)
    }

    print("building test!")
    print(top_range)
    print(bottom_range)
    print(inst)


    # print('using hard coded ranges and instrument for testing!!!')
    # inst <- "Piano"
    # bottom_range <- 48
    # top_range <- 79


    promise_melody <- future({
      sample_n_melodies_which_fit_in_range(corpus = corpus,
                                           n_range = n_range,
                                           n_difficulty = n_difficulty,
                                           bottom_range = bottom_range,
                                           top_range = top_range,
                                           inst = inst)

    }) %...>% (function(result) {
      print('building melodies in range done')
      showNotification("Your test is ready.")
      print(result)
      set_global("melodies", result, state)
    })


  })

}




# tests


# dada <- item.sampler.rds(berkowitz.rds.abs, list("3" = 2L,
#                                                   "4" = 1L))



# doda <- item.sampler.simple(item_bank = berkowitz.midi,
#                             no_items = list("3" = 4,
#                                             "4" = 3,
#                                             "5" = 2,
#                                             "6" = 2,
#                                             "7" = 2,
#                                             "8" = 2,
#                                             "9" = 2,
#                                             "10" = 2,
#                                             "11" = 2))
#
#
#
#
# tesss <- item.sampler(item_bank = berkowitz.item.bank.proper.format,
#                                 no_items = list("3" = 4,
#                                                  "4" = 3,
#                                                  "5" = 2,
#                                                  "6" = 2,
#                                                  "7" = 2,
#                                                  "8" = 2,
#                                                  "9" = 2,
#                                                  "10" = 2,
#                                                  "11" = 2))



# tests::
#user.sample <- item.sampler(berkowitz.item.bank.proper.format, 84)

#user.sample <- item.sampler(DTL_1000, 20)


# test duplicate
#fake.duplicate <- rbind(user.sample, user.sample[1, ], user.sample[11, ])
#out <- remove.duplicates.and.resample(fake.duplicate, berkowitz.item.bank)



#ja <- item_sampler(DTL_1000, 23)

# corpus_sub <- subset_corpus(corpus = WJD, N_range = c(3, NULL), span_min = 12, tonality = "major")
#
# corpus_sample <- item_sampler(corpus_sub, 20)
