library(reticulate)
library(hrep)
library(ggplot2)
library(hrbrthemes)
library(dplyr)
library(ggrepel)
library(tidyr)

#print(quantize.notes.5(te, onsets))

# print(quantize.notes.4(notes = c(47, 47, 52, 52, 52, 54, 54, 54, 66),
#                        onsets = c(1, 0,  1,  0,  0,  0,  1,  0,  1)
#                        ))



#print(mmed(c(47, 47, 52, 52, 52, 54, 54, 54, 66)))

# print(quantize.notes.4(c(55, 30, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 69, 69, 69, 69, 69, 71, 71, 71, 71, 71, 71, 93, 32)))
#
#
# print(quantize.notes.4(c(55, 30, 67, 67, 67, 67, 67, 67, 67, 67, 67, 67, 69, 69, 69, 69, 69, 71, 71, 71, 71, 71, 71, 93, 32)))




#quantized.notes <- quantize.notes(test.notes, test.onsets)

#plot.note.data(test.notes, test.onsets, quantized.notes)























# you need to install the python packages in r
# py_install("pandas")


#reticulate::source_python("R/pyin_note.py")



###

# pYIN note processing
# pYIN_notes <- PyinMain()
#
#
#
# get.pYIN.notes <- function(freqs) {
#   freqs.wo.null <- as.numeric(unlist(lapply(freqs, function(x) ifelse(is.null(x), 0, x) )))
#   res <- pYIN_notes$getRemainingFeatures(freqs.wo.null)
#   print(res)
#   print(res$m_oMonoNoteOut)
#   res2 <- unlist(lapply(res$m_oMonoNoteOut, function(x) x$pitch))
#   res2
# }
#
#
#
# Mono.Note <- MonoNote()
#
# # get into correct format for processing
# new.list <- lapply(1:length(test.freqs.wo.null), function(x) list(reticulate::tuple(test.freqs.wo.null[[x]], test.confidences[[x]])))
#
# pitch.Prob <- r_to_py(new.list)
#
# mn.Out <- Mono.Note$process(pitch.Prob)
#
# res <- getPitchTracks(mn.Out, length(mn.Out))
#
# mn.Out[[1]]



## melodia

#py_install(c("pandas", "numpy", "soundfile", "resampy", "vamp", "argparse", "midiutil", "scipy", "jams"))
# reticulate::source_python("R/audio_to_midi_melodia/midi_to_notes.py")
#
# test.midi.pitches <- lapply(test.freqs.wo.null, function(x) {
#                       print(x)
#                       ifelse(x == 0, 0, round(freq_to_midi(x)))
#                             })
#
# res <- midi_to_notes(midi =  unlist(test.midi.pitches),
#                      fs = 44100,
#                      hop = 128,
#                      smooth = 0.25,
#                      minduration = 0.1)


