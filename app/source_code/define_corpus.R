library(dplyr)

# constants
item_bank_columns <- c("Freq", "N", "rel.freq", "log.freq")

# the directory containing the item banks
item_banks_directory <- "item_banks/"
item_banks_directory_www <- "www/item_banks/"

# functions

check.item_bank.format <- function(loaded_item_bank, name, type) {

  if(!any(names(loaded_item_bank) %in% item_bank_columns) | is.data.frame(loaded_item_bank) == FALSE) {
    warning(paste0('Ideally, an item bank should have the following columns: ', paste0(item_bank_columns, collapse = " ")))
  }
  else {
    loaded_item_bank[, c("Freq", "N", "rel.freq", "log.freq")] <- mutate_all(loaded_item_bank[, c("Freq", "N", "rel.freq", "log.freq")], function(x) as.numeric(as.character(x)))
  }

  if (is.data.frame(loaded_item_bank)) {
    item_no <- nrow(loaded_item_bank)
    # convert to numeric
  }
  else {
    item_no <- length(loaded_item_bank)
  }
  print(paste0("Loaded item bank " , name, ". ", item_no, " items found."))

  loaded_item_bank

}

define.item.bank <- function(name, type = c("RDS_file_midi_notes",
                                         "midi_file",
                                         "musicxml_file", "RDS_file_full_format"),
                                path, absolute) {

  if (type == "RDS_file_midi_notes" | type == "RDS_file_full_format") {
    print(paste0(item_banks_directory, path))
    item_bank <- readRDS(paste0(item_banks_directory_www, path))
  }
  else if (type == "midi_file") {
    item_bank <- as.list(list.files(path = paste0(item_banks_directory_www, path), pattern = "\\.mid$"))
    # make sure appended with item bank directory
    item_bank <- lapply(item_bank, function(x) paste0(item_banks_directory, path, "/", x))
  }

  else if (type == "musicxml_file") {
    item_bank <- as.list(list.files(path = paste0(item_banks_directory_www, path), pattern = "\\.musicxml$"))
    # make sure appended with item bank directory
    item_bank <- lapply(item_bank, function(x) paste0(item_banks_directory, path, "/", x))
  }

  else {
    stop('Not a valid item_bank type')
  }

  item_bank <- check.item_bank.format(item_bank, name, type)

  # add header describing item_bank type
  item_bank[["type"]] <- type

  item_bank

}


top_quantile <- function(corpus, quantile_cut = .95) {
  cut <- quantile(corpus$log.freq, 1-quantile_cut)
  print(cut)
  # filt <- corpus %>% filter(log.freq > cut)
  # ggplot(filt) +
  #   geom_histogram(aes(log.freq))
  cut
}


subset_corpus <- function(corpus, N_range = NULL, quantile_cut = NULL, span_min = NULL, tonality = NULL) {

  if (is.null(N_range)) {
    N_range <- c(1, max(corpus$N))
  }
  else if (is.na(N_range[2])) { # the NULL gets coerced to NA
    N_range[2] <- max(corpus$N)
  }
  else if(length(N_range) > 2) {
    N_range <- c(N_range[1], N_range[length(N_range)])
  }
  else {
    stop('unknown N_range format')
  }


  if (is.null(quantile_cut)) { quantile_cut <- min(corpus$log.freq) }
  if (is.null(span_min)) { span_min <- min(corpus$span) }

  # corpus should be a df of the corpus read in e.g by read_rds

  if(!is.null(tonality)) {
    corpus <- corpus %>% filter(mode == tonality)
  }

  corpus %>% filter(log.freq > quantile_cut & N >= N_range[1] & N <= N_range[2] &
                          span >= span_min)
}

#d_1 <- subset_corpus(corpus = WJD, N_range = 5:15, span_min = 12, tonality = "major")

#d_2 <- subset_corpus(corpus = WJD, N_range = 5:15, span_min = 12, tonality = "minor")

#subset_corpus(corpus = WJD)

#sss <- subset_corpus(corpus = WJD, N_range = c(3, NULL))

