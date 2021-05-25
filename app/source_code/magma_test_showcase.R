## dummy pages


# timeline <- join(
#
#   one_button_page(h2("MaGMA Test Showcase")),
#
#   one_button_page(h2("Musical Page Types")),
#
#   present_stimuli(stimuli = c(60, 61, 62, 63),
#                   stimuli_type = "midi_notes",
#                   display_modality = "auditory",
#                   page_title = "Record Audio Page",
#                   page_type = "record_audio_page"
#   ),
#
#
#   select_midi_device_page(),
#
#   present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#                   stimuli_type = "video",
#                   page_type = "record_midi_page",
#                   body = "Play some MIDI"
#   ),
#
#
#   # midi notes (auditory)
#   present_stimuli(stimuli = c(60, 62, 64, 65),
#                   stimuli_type = "midi_notes",
#                   display_modality = "auditory",
#                   page_title = "Present MIDI notes"
#                   #, note_length = 1000
#   ),
#
#   # rhythms (need percussion sound)
#   present_stimuli(stimuli = list('8n', '8n', list('2n', '4n'), '8n', '4t', '4t', '4t', '4t', '4t', '4t', '8n'),
#                   stimuli_type = "rhythms",
#                   page_title = "Present Rhythms"
#                   ),
#
#   # sci notation with rhythms
#   present_stimuli(stimuli = list(scientific_music_notation = list("Eb4", "A4", "Bb4", "Eb4", "A4", "Bb4", "C5", "A4", "Bb4", "C5", "A4", "Bb4", "Bb4", "A4", "G4", "F4", "Eb4", "F4", "Bb4", "Ab4", "G4", "F4", "Eb4", "F4", "Eb4", "G4", "Eb4", "A4", "Bb4", "Eb4", "A4", "Bb4", "C5", "A4", "Bb4", "C5", "D5", "Bb4", "D5", "Eb5", "D5", "C5", "Bb4", "D5", "D5", "Eb5", "D5", "C5", "Bb4", "D5", "Eb5", "F5"),
#                                  rhythms = list('8n', '8n', list('2n', '4n'), '8n', '4t', '4t', '4t', '4t', '4t', '4t', '8n', list('2n', '4n'), '8n', '8n', '8n', '8n', '8n', list('4n', '8n'), '8n', '8n', '8n', '8n', '8n', '4n', '4n', list('2n', '4n', '8n'), '8n', '8n', list('2n', '4n'), '8n', '4t', '4t', '4t', '4t', '4t', '4t', '8n', list('2n', '4n'), '8n', '8n', '8n', '8n', '8n', list('4n', '8n'), '8n', '8n', '8n', '8n', '8n', '4n', '4n', list('2n', '4n', '8n'))
#   ),
#   stimuli_type = "scientific_music_notation",
#   display_modality = "auditory",
#   page_title = "Present Notes (Sci Notation) + Rhythms Aurally"
#   #note_length = 1000
#   ),
#
#
#   # midi notes (visual)
#   present_stimuli(stimuli = c(60, 62, 64, 65),
#                   stimuli_type = "midi_notes",
#                   display_modality = "visual",
#                   asChord = FALSE,
#                   page_title = "Present MIDI notes visually"
#                   #ascending = TRUE
#   ),
#
#   # midi notes (visual, as chord)
#   present_stimuli(stimuli = c(60, 62, 64, 65),
#                   stimuli_type = "midi_notes",
#                   display_modality = "visual",
#                   asChord = TRUE,
#                   page_title = "Present MIDI notes visually, as chord"
#                   #ascending = FALSE
#   ),
#
#
#
#   # midi file (auditory)
#   present_stimuli(stimuli = 'stimuli/hinematov.mid',
#                   stimuli_type = "midi_file",
#                   display_modality = "auditory",
#                   page_title = "Play Midi File"
#   ),
#
#   # sci notation visual
#   present_stimuli(stimuli = c("C4", "E3", "G5", "B4", "A2", "D3", "E3", "F2"),
#                   stimuli_type = "scientific_music_notation",
#                   display_modality = "visual",
#                   asChord = FALSE,
#                   page_title = "Present Scientific Notation Visually"
#                   ),
#
#   # pitch classes visual
#   present_stimuli(stimuli = c("C", "E", "G", "B", "A", "D", "E", "F"),
#                   stimuli_type = "pitch_classes",
#                   display_modality = "visual",
#                   octave = 4,
#                   asChord = FALSE,
#                   page_title = "Present Pitch Classes Visually"
#                   ),
#
#   # sci notation with accidentals
#   present_stimuli(stimuli = c("C#4", "Eb4", "G#4", "Bb4", "A#4", "Db4", "E#4", "Gb2"),
#                   stimuli_type = "scientific_music_notation",
#                   display_modality = "visual",
#                   asChord = FALSE,
#                   page_title = "Present Scientific Notation Visually (with accidentals)"
#                   ),
#
#   # music.xml file file (visual)
#   present_stimuli(stimuli = 'stimuli/Berkowitz35.musicxml',
#                   stimuli_type = "musicxml_file",
#                   display_modality = "visual",
#                   page_title = "Present .musicxml files visually"
#                   ),
#
#   one_button_page(tags$h2("Non-Musical Page Types")),
#
#
#   present_stimuli(stimuli = c("type these words back"),
#                   stimuli_type = "words",
#                   display_modality = "visual",
#                   slide_length = 600,
#                   page_type = "record_key_presses_page",
#                   page_title = "Capture Key Presses",
#   ),
#
#   # images
#   present_stimuli(stimuli = c("img/dummy_stimuli/1.jpg",
#                               "img/dummy_stimuli/2.jpg",
#                               "img/dummy_stimuli/3.jpg",
#                               "img/dummy_stimuli/4.jpg"),
#                   stimuli_type = "images",
#                   slide_length = 1000,
#                   page_title = "Display Image Slides"
#                   ),
#
#
#   # digits
#   present_stimuli(stimuli = c("1", "2", "3"),
#                   stimuli_type = "digits",
#                   display_modality = "visual",
#                   slide_length = 1000,
#                   page_title = "Display Digit Slides"
#                   ),
#
#
#   # letters
#   present_stimuli(stimuli = c("A", "B", "C"),
#                   stimuli_type = "letters",
#                   display_modality = "visual",
#                   slide_length = 300,
#                   page_title = "Display Letter Slides"
#                   ),
#
#   # words
#   present_stimuli(stimuli = c("Hannover", "Schule", "für", "Musik", "Theater", "und", "Medien"),
#                   stimuli_type = "words",
#                   display_modality = "visual",
#                   slide_length = 500,
#                   page_title = "Display Word Slides"
#                   ),
#
#   # need to select voice first
#   select_voice_page(),
#
#   # digits (auditory)
#   present_stimuli(stimuli = c("1", "2", "3"),
#                   stimuli_type = "digits",
#                   display_modality = "auditory",
#                   slide_length = 1000,
#                   page_title = "Auditory Digit Presentation",
#                   page_text = "This page is for presenting words, digits or letters in the aural domain."
#                   ),
#
#
#   # letters (auditory)
#   present_stimuli(stimuli = c("A", "B", "C"),
#                   stimuli_type = "letters",
#                   display_modality = "auditory",
#                   slide_length = 300,
#                   page_title = "Auditory Letter Presentation",
#                   page_text = "This page is for presenting words, digits or letters in the aural domain."
#                   ),
#
#   # words (auditory)
#   present_stimuli(stimuli = c("welcome", "to", "Hannover"),
#                   stimuli_type = "words",
#                   display_modality = "auditory",
#                   slide_length = 100,
#                   page_title = "Auditory Word Presentation",
#                   page_text = "This page is for presenting words, digits or letters in the aural domain."
#                   ),
#
#   present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#                   stimuli_type = "video",
#                   page_type = "one_button_page",
#                   page_title = "Video Page, One Button Page",
#                   page_text = "Here is my video"
#   ),
#
#
#   present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#                   stimuli_type = "video",
#                   page_type = "NAFC_page",
#                   choices = c("A", "B", "C"),
#                   label = "test"
#   ),
#
#   present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#                   stimuli_type = "video",
#                   page_type = "dropdown_page",
#                   label = "test",
#                   choices = c("A", "B", "C")
#   ),
#
#   present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#                   stimuli_type = "video",
#                   page_type = "slider_page",
#                   label = "slider page",
#                   min = 1, max = 10, value = 5
#   ),
#
#
#   present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#                   stimuli_type = "video",
#                   page_type = "text_input_page",
#                   label = "text_input_demo"
#   ),
#
#   # present_stimuli(stimuli = "https://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_5mb.mp4",
#   #                 stimuli_type = "video",
#   #                 page_title = "Video Page, One Button Page",
#   #                 page_type = "record_audio_page"
#   # ),
#
#
#   final_page("The end")
# )
#
#
# test <- make_test(elts = timeline)

# runApp(".", display.mode = "showcase")



# timeline_test_midi_audio <- join(
#
#     select_midi_device_page(),
#
#     # interactive midi page
#     present_stimuli(stimuli = "interactive",
#                     stimuli_type = "midi_notes",
#                     page_type = "record_midi_page",
#                     display_modality = "visual",
#                     page_title = "Interactive MIDI Page"
#     ),


# # midi notes (auditory)
# present_stimuli(stimuli = c(60, 62, 64, 65),
#                 stimuli_type = "midi_notes",
#                 page_type = "record_midi_page",
#                 display_modality = "auditory",
#                 page_title = "Present MIDI notes"
# ),
#


# midi notes (auditory)
#     present_stimuli(stimuli = c(60, 62, 64, 65),
#                     stimuli_type = "midi_notes",
#                     page_type = "record_audio_page",
#                     display_modality = "auditory",
#                     page_title = "Present MIDI notes"
#     ),
#
#   display_previous_answer_music_notation_pitch_class(),
#
#   final_page("The End")
#
# )
#
# test <- make_test(elts = timeline_test_midi_audio)

# rsconnect::deployApp(appDir = '/Users/sebsilas/PhD 2021/magma-gold/magmaGold/R', appTitle = "PBE Test", account = 'synthesoo')
