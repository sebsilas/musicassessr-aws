
# Sight Reading Test (SRT)

setwd("/Users/sebsilas/PhD 2021/magma-Gold/magmaGold/R")
# get all includes

source('inc.R')




SRT.item.bank.support.check <- function(item_bank) {

  if (class(item_bank[[1]]) == "character") {
    if (item_bank$type == "midi_files") {
      stop('The SRT currently does not support midi files for presentation. Please use musicxml files or R vectors')
    }
  }
  else {
    lapply(item_bank, function(x) {
      if (x$type == "midi_files") {
        stop('The SRT currently does not support midi files for presentation. Please use musicxml files or R vectors')
      }
    })
  }

}

# tests

#rhythmic and arrhythmic
# SRT(item_bank = list("rhythmic" = berkowitz.musicxml,
#                      "arrhythmic" = berkowitz.rds.abs),
#     no_items = list("rhythmic" = 5,
#                     "arrhythmic" = 5
#                     ),
#     display_modality = "visual"
# )



# rhythmic only
# SRT(item_bank = list("rhythmic" = berkowitz.musicxml),
#      no_items = list("rhythmic" = 5)
#     )

#rhythmic only (alt spec)
# SRT(item_bank = berkowitz.musicxml,
#     no_items = 5)


# arrhythmic only
# SRT(item_bank = list("arrhythmic" = berkowitz.rds.abs),
#     no_items = list("arrhythmic" = 5)
# )

# arrhythmic only (alt spec)
# SRT(item_bank = berkowitz.rds.abs, no_items = 5)


#shiny::runApp(".")
