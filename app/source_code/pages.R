# there are two main page types to conduct production tasks
# 1) present_stimuli_page, which is used to present used to present e.g notes, but also items like digits from a list;
# 2) record_audio_page which is used for production stuff

# each page type uses function factories/operators to create special cases of these pages
# i.e versions of the two main page types deployed with certain parameters
# the page types simply add HTML content to normal psychTestR pages via the body/text argument
# this HTML content is essentially wrapping Javascript functionality allowing e.g in-browser playback.

record_audio_page(
  text = , # i.e page instructions
  button_text, # e.g "Record My Voice"
  stop_record_after = 5, # no of seconds to automatically stop recording after
  display_stop_button = FALSE, # can user elect to stop the recording?
  display_plot = FALSE,
  save_to_amazon_bucket = FALSE,
  amazon_bucket_info = list(wRegion = "us-east-1",
                            poolid = "us-east-1:c74a7565-ecd3-4abb-9dba-3d02b483e795",
                            s3bucketName = "melody-singing-task",
                            audioPath = "/audio-files")
  )

record_midi_input_page()

# this can create the following useful/typical pages:
## record_5_second_hum_page i.e record_audio_page(text = "Record yourself humming", "button_text = "Record Hum", stop_record_after = 5, display_stop_button = FALSE)
## record_background_page
## SNR_calculate() (wraps both a record_5_second_hum_page and a record_background page to calculate SNR across 2 pages)


# inherits from record_audio page
# when I say inherit, I do not mean in the proper inheritance chain fashion, but it has the effect of inheritance
# response_type designates a base psychTestR (plus my new record_audio_page type) to begin with
# all the other parameters essentially generate the HTML code which gets fixed to the body/text function of the base page type




test <- retrieve_page_type("one_button_page", 1:10, admin_ui = 1, text = "hello")


present_stimuli(

  response_type = c("none", "record_audio", "NAFC", "text_input", "key_presses", "record_midi", "etc", ),
  # e.g if record_audio, inherit record_audio_page

  display_modality = c("visual", "auditory", "visual_and_auditory"),
  presentation_type = c("sequential", "simultaneous/harmonic", "ascending", "descending"),
  with_metronome_click = c(TRUE, FALSE),

  slide_length = 100,

  BPM = 30-300,

  file_path = "", # .txt, .musicxml, .mid etc

  stimuli_type = c("digits", "letters", "words", "video", "images",
                   "midi_notes", "frequencies",
                   "scientific_music_notation", "pitch_classes",
                   "mixed", "midi_file", "musicxml_file", "rhythms"
                   ),

  stimuli = c("A","B","C"), # letters
  c("ant","bat","cat"), # words
  c(1,2,3,5), # digits
  c(60,61,62,63,64), # midi notes
  c(440), # frequencies
  c("C4"), # scientific pitch  notation
  c(1/4, 1/4), # rhythms
  c(100, 200), # rhythms, ms

  # or a named list if different stimuli types are to be combined:
  stimuli = list("letters" = c("A","B","C"), # letters
             "words" = c("ant","bat","cat"), # words
             "digits" = c(1,2,3,5), # digits
             "midi_notes" = c(60,61,62,63,64), # midi notes
             "frequencies" = c(440), # frequencies
             "scientific_notation" = c("C4"), # scientific pitch  notation)
             "rhythms" = c(1/4, 1/4),
             "images" = list("img/chicken.jpg", "img/chicken2.jpg")
  ),

  correct_answer_backwards = c(TRUE, FALSE), # default: FALSE. if TRUE, the participant must put the answer backwards
  durations = c(1,2,5,3,2, arrhythmic = 500), # optional rhythm vector for stimuli or arrhythmic = e.g 500 for single presentaiton speed
  playback_sound = c("male", "female", "etc"), # voice for playback
  user_playback_no = 3, # no of times the user may request to hear the playback (before the play button disappears)

  # music-specific parameters (optional)
  playback_sound = c("tone", "piano", "etc"), # sound for playback
  melody_type = c("absolute", "relative"),
  user_range = 40:50, # for sampling a random start note
)


# this can be used to create:

# musical_stimuli_page
# play_long_tone_record_audio_page
# play_interval_record_audio_page
# play_midi_file_record_audio_page
# play_melody_from_list_record_audio_page
# play_melody_record_audio_page
# play_spoken_words


### additional / separate pages

microphone_calibration_page # separate page

get_user_info_page # separate page

video_page # separate page

## tests this can build:

# production tasks

# sight-reading task
# sight-singing task
# play by ear task (mel production for instruments)
# melody singing task (mel production for instruments)
# verbal comprehension task
# digit comprehension task
# typing production task
# fingering/singing ghost note task
# visual singing task

# interval perception test i.e present interval(s) vis or aur: pp must (as quickly as possible) type what intervals they see /hear(in order): 123456789 keys for each interval e.g 2 = 2nd. could be a button version too
# note perception test (i.e identify absolute notes as quickly as possible)

# the sight comprehension test; pps hear a score with audio presented alongside. they must rate whether or not what they heard matches the score presented

# span task (all modalities)
# backwards span task (all modalities)
# rhythm tapping task

# MaGMA-Gold (Music and General Memory Assessment)

