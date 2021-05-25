# define some present corpuses

source('define_corpus.R')

# define some dummy corpuses

berkowitz.rds.abs <- define.item.bank("Berkowitz_RDS_Absolute",
                                      type = "RDS_file_midi_notes",
                                      path = "Berkowitz_Absolute.RDS",
                                      absolute = TRUE
)


berkowitz.rds.rel <- define.item.bank("Berkowitz_RDS_Relative",
                                      type = "RDS_file_midi_notes",
                                      path = "Berkowitz_Relative.RDS",
                                      absolute = FALSE
)


berkowitz.midi <- define.item.bank("Berkowitz_midi",
                                   type = "midi_file",
                                   path = "berkowitz_midi_rhythmic",
                                   absolute = TRUE
)


berkowitz.musicxml <- define.item.bank("Berkowitz_musicxml",
                                       type = "musicxml_file",
                                       path = "berkowitz_musicxml",
                                       absolute = TRUE
)


berkowitz.item.bank.proper.format <- define.item.bank("Berkowitz_item_bank",
                                                      type = "RDS_file_full_format",
                                                      path = "Berkowitz_Item_Bank.RDS",
                                                      absolute = FALSE
)


slonimsky <- define.item.bank("Slonimsky",
                              type = "RDS_file_midi_notes",
                              path = "Slonimsky.RDS",
                              absolute = TRUE)


DTL_1000 <- define.item.bank("DTL_1000",
                              type = "RDS_file_full_format",
                              path = "DTL_1000.RDS",
                              absolute = FALSE)


WJD <- define.item.bank("WJD",
                         type = "RDS_file_full_format",
                         path = "WJD_corpus.RDS",
                         absolute = FALSE)


