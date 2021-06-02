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


subset_corpus <- function(corpus, length = NULL, quantile_cut = NULL, span_min = NULL, span_max = NULL, tonality = NULL) {

  if (is.null(length)) {
    length <- c(1, max(corpus$N))
  }

  else if (length(length) == 1) {
    length <- c(length, length)
  }
  else if (is.na(length[2])) { # the NULL gets coerced to NA
    length[2] <- max(corpus$N)
  }
  else if(length(length) > 2) {
    length <- c(length[1], length[length(length)])
  }
  else {
    stop('unknown length format')
  }


  if (is.null(quantile_cut)) { quantile_cut <- min(corpus$log.freq) }
  if (is.null(span_min)) { span_min <- min(corpus$span) }
  if (is.null(span_max)) { span_max <- max(corpus$span) }


  # corpus should be a df of the corpus read in e.g by read_rds

  if(!is.null(tonality)) {
    corpus <- corpus %>% filter(mode == tonality)
  }

  corpus %>% filter(log.freq > quantile_cut & N >= length[1] & N <= length[2] &
                          span >= span_min & span <= span_max)
}

# d_1 <- subset_corpus(corpus = WJD, length = 5:15, span_min = 12, span_max = 30, tonality = "major")
#
# d_2 <- subset_corpus(corpus = WJD, length = 5:15, span_min = 12, tonality = "minor")
#
# d_3 <- subset_corpus(corpus = WJD, length = 5:15, span_min = 12, tonality = "minor")
#
# d_4 <- subset_corpus(corpus = WJD, length = c(3, NA))
#
# d_5 <- subset_corpus(corpus = WJD, length = 3)



#subset_corpus(corpus = WJD)


