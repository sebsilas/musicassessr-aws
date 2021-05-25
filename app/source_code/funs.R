insert.every.other.pos.in.list <- function(l, item_to_add) {
  for (i in 1:length(l)) {
    l <- append(l, item_to_add, after = (i*2)-1)
  }
  l
}


rel_to_abs_mel <- function(rel_mel, start_note = 60) {
  c(0, cumsum(rel_mel)) + start_note
}

str.mel.to.vector <- function(str_mel, sep) {
  vector_mel <- as.numeric(unlist(strsplit(str_mel, sep)))
}


set_answer_meta_data <- function(meta_data) {
  paste0('Shiny.setInputValue(\"answer_meta_data\", ', meta_data, ');')
}

reverse.answer <- function(ans) {

  # if reverse == TRUE, then check for the reverse of the answer
  if (length(ans) == 1) {
    ans <- stringi::stri_reverse(ans)
  }
  else {
    ans <- rev(ans)
  }
  ans

}

check.answer <- function(user_response, correct_answer,
                         reverse = FALSE,
                         type = c("single_digits", "numbers", "chunks_numbers",
                                  "single_letters", "chunk_letters",
                                  "words",
                                  "midi_pitches",
                                  "rhythms",
                                  "melodies_with_rhythms")
                         ) {

  # check that the lengths are the same
  stopifnot(length(user_response) == length(correct_answer))

  # reverse answer if need be
  if (reverse == TRUE) {
    correct_answer <- reverse.answer(correct_answer)
  }

  # match based on type of input
  if (length(user_response) > 1) {
    correct <- identical(user_response, correct_answer)
  }

  else if (type == "midi_pitches") {
    # ngrukkon()
  }

  else if (type == "rhythms") {
    ## rhythm metric
    # ngrukkon()
  }

  else if (type == "melodies_with_rhythms") {

  }

  else {
    correct <- user_response == correct_answer
  }


  correct
}

getmode <- function(v) {
  uniqv <- unique(v)
  uniqv[which.max(tabulate(match(v, uniqv)))]
}


present_record_button <- function(present = FALSE, type = "both", midi_device = NULL, interactive = FALSE) {

  if (present == TRUE & type == "both" |
      present == TRUE & type == "crepe" |
      present == TRUE & type == "aws-pyin") { # in this context, both means both audio protocols (crepe and AWS)

    div(id = "button_area",
        tags$button("Record", id = "recordButton"),
        tags$script(paste0('document.getElementById("recordButton").addEventListener("click", function() {
                           recordAndStop(null, true, false, this.id, "both");
                           hideRecordButton();
                            });'))
    )
  }

  else if (present == TRUE & type == "record_midi_page") {
    div(id = "button_area",
        tags$button("Record", id = "recordButton"),
        tags$script(paste0('document.getElementById("recordButton").addEventListener("click", function() {
                           recordAndStop(null, true, false, this.id, \"record_midi_page\");
                            hideRecordButton();
                           instantiateMIDI(\"',midi_device,'\", false); })'))
    )
  }
  else {
    div(id = "button_area")
  }
}


check.similarity <- function(user_response, correct_answer, reverse = FALSE) {
  # if reverse == TRUE, then check for the reverse of the answer

  if (reverse == TRUE) {
    #correct <-
  }
  else {
  #user_response ==
  }
}


validate.page.types <- function(page_type_string, args) {

  # check if certain page types have their required arguments
  # and give a descriptive error message back to user if they haven't specified something correctly

  if(page_type_string == "NAFC_page" |
     page_type_string == "dropdown_page") {

    if(is.null(args$label) | is.null(args$choices)) {
      stop('You must specify a label and choices for NAFC_page or dropdown_page')
    }
  }

  if(page_type_string == "slider_page") {

    if(is.null(args$label) | is.null(args$min)
       | is.null(args$max) | is.null(args$value)
    ) {
      stop('You must specify a label, min, max and value arguments for slider pages')
    }
  }

  if(page_type_string == "text_input_page") {

    if(is.null(args$label)) {
      stop('You must specify a label for text_input_page')
    }
  }
}

check.correct.argument.for.body <- function(page_type_string, args, stimuli_wrapped) {
  # feed the body to the page, but using the correct argument
  # i.e some pages accept "body" whilst others accept "prompt"
  if (page_type_string == "one_button_page" |
      page_type_string == "record_audio_page" |
      page_type_string == "record_key_presses_page") {
    args[["body"]] <- stimuli_wrapped
  }

  else if (page_type_string == "NAFC_page" |
           page_type_string == "dropdown_page" |
           page_type_string == "slider_page" |
           page_type_string == "text_input_page"
  ) {
    args[["prompt"]] <- stimuli_wrapped
  }
  else {
    ## leaving here for now in case there's another use I haven't thought of yet
  }
  args
}

item_bank_type_to_stimuli_type <- function (string_of_item_bank_type) {
  if(str_detect(string_of_item_bank_type, "RDS_file")) {
    item_bank_type <- str_remove(string_of_item_bank_type, "RDS_file_")
  }
  else {
    item_bank_type <- string_of_item_bank_type
  }
  item_bank_type
}


# more musicy functions

midi.to.pitch.class <- function(midi_note) {

  if (length(midi_note) == 1) {
    pitch_class <- midi.to.pitch.classes.list[[as.character(midi_note)]]
  }
  else {
    pitch_class <- unlist(lapply(midi_note, function(x) midi.to.pitch.classes.list[[as.character(x)]]))
  }
  pitch_class
}


midi.to.pitch.class.numeric <- function(midi_note) {

  if (length(midi_note) == 1) {
    pitch_class <- midi.to.pitch.classes.numeric.list[[as.character(midi_note)]]
  }
  else {
    pitch_class <- unlist(lapply(midi_note, function(x) midi.to.pitch.classes.numeric.list[[as.character(x)]]))
  }
  pitch_class
}


midi.to.sci.notation <- function(midi_note) {

  if (length(midi_note) == 1) {
    pitch_class <- midi.to.sci.notation.list[[as.character(midi_note)]]
  }
  else {
    pitch_class <- unlist(lapply(midi_note, function(x) midi.to.sci.notation.list[[as.character(x)]]))
  }
  pitch_class
}


sounds.list <- c('bass-electric','bassoon','cello','clarinet','contrabass','flute','french-horn','guitar-acoustic','guitar-electric','guitar-nylon', 'harmonium','harp','organ','piano','saxophone','trombone','trumpet','tuba','violin','xylophone')

# html javascript imports
music.js.scripts <- div(
  #includeScript("www/js/midi.js"),
  shiny::tags$script(src="https://www.midijs.net/lib/midi.js"),
  shiny::tags$script(src="https://unpkg.com/@tonejs/midi"),
  includeScript("www/js/Tone.js"),
  includeScript("www/js/Tonejs-Instruments.js"),
  includeScript("www/js/opensheetmusicdisplay.min.js"),
  #shiny::tags$script(src = 'https://unpkg.com/tone-rhythm@2.0.0/dist/tone-rhythm.min.js'),
  includeScript('https://unpkg.com/tone-rhythm@2.0.0/dist/tone-rhythm.min.js'),
  includeScript("www/js/play_music_stimuli.js")
  #shiny::tags$script(src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"),
)


wrap.xml.template <- function(notes) {

  res <- shiny::HTML(paste0('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
  <!DOCTYPE score-partwise PUBLIC
      "-//Recordare//DTD MusicXML 3.0 Partwise//EN"
      "http://www.musicxml.org/dtds/partwise.dtd">
  <score-partwise version="3.0">
    <part-list>
      <score-part id="P1">
        <part-name>Music</part-name>
      </score-part>
    </part-list>
    <part id="P1">
      <measure number="1">
        <attributes>
          <divisions>1</divisions>
          <key>
            <fifths>0</fifths>
          </key>
          <time>
            <beats>4</beats>
            <beat-type>4</beat-type>
          </time>
          <clef>
            <sign>G</sign>
            <line>2</line>
          </clef>
        </attributes>', notes, '</measure>
    </part>
  </score-partwise>'))
}




get.last.char.of.string <- function(string) {
  substr(string, nchar(string), nchar(string))
}

remove.last.char.of.string <- function(string) {
  substr(string, 1, nchar(string)-1)
}

test.if.sci.notation <- function(x) {

  last_char <- get.last.char.of.string(x)

  if (is.na(as.numeric(last_char))) {
    stop('Last character is not a number, so entry is not in sci_notation format')
  }

  # below can be used to detect if entry contains digit:
  #stringr::str_detect("C", "[0-9]")
  #stringr::str_detect("C4", "[0-9]")

}

format.accidentals.for.music.xml <- function(pitch_class_string){
  # take pitch class string, determine if sharp or flat
  # if so, return appropriate <alter> music xml element (-1 for flat, 1 for sharp)
  # if not, return empty string
  # also return the pitch class with the flat removed

  last_char <- get.last.char.of.string(pitch_class_string)

  if (last_char == "b") {
    alter.text <- '<alter>-1</alter>'
    pitch.class <- remove.last.char.of.string(pitch_class_string)
  }

  else if (last_char == "#") {
    alter.text <- '<alter>1</alter>'
    pitch.class <- remove.last.char.of.string(pitch_class_string)
  }
  else {
    alter.text <- ''
    pitch.class <- pitch_class_string
  }

  list(alter.text, pitch.class)
}


format.notes.scientific_music_notation <- function(notes, asChord = FALSE) {

  res <- ""

  for(i in seq_along(notes)) {

    note <- remove.last.char.of.string(notes[i])
    octave <- get.last.char.of.string(notes[i])
    alter <- format.accidentals.for.music.xml(note)[[1]] # alters specifies if not sharp or flat
    note.without.sharp.or.flat <- format.accidentals.for.music.xml(note)[[2]]

    # https://www.musicxml.com/tutorial/the-midi-compatible-part/pitch/

    if (i == 1) {
      res <- paste0(res, '<note>
        <pitch>
        <step>', note.without.sharp.or.flat, '</step>',
                    alter,
                    '<octave>', octave, '</octave>
        </pitch>
        <duration>4</duration>
        <type>whole</type>
        </note>')

    }


    else {
      res <- paste0(res, '<note>',
                    ifelse(asChord, '<chord/>', ' '), # format as chord
                    '<pitch>
                <step>', note.without.sharp.or.flat, '</step>',
                    alter,
                    '<octave>', octave, '</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
                </note>')
    }

  }
  res

}


format.notes.pitch.classes <- function(notes, octave = 4, asChord = FALSE) {

  res <- ""

  for(i in seq_along(notes)) {

    alter <- format.accidentals.for.music.xml(notes[i])[[1]] # alters specifies if not sharp or flat

    note.without.sharp.or.flat <- format.accidentals.for.music.xml(notes[i])[[2]]

    if (i == 1) {
      res <- paste0(res, '<note>
        <pitch>
        <step>', note.without.sharp.or.flat, '</step>',
                    alter,
                    '<octave>', octave, '</octave>
        </pitch>
        <duration>4</duration>
        <type>whole</type>
        </note>')

    }


    else {
      res <- paste0(res, '<note>',
                    ifelse(asChord, '<chord/>', ' '), # format as chord
                    '<pitch>
                <step>', note.without.sharp.or.flat, '</step>',
                    alter,
                    '<octave>', octave, '</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
                </note>')
    }

  }

  res

}



format.notes.midi <- function(notes, asChord = FALSE) {

  notes <- midi.to.sci.notation(notes)

  res <- format.notes.scientific_music_notation(notes, asChord)
  res

}


format.notes <- function(type, notes, octave = 4, asChord = FALSE) {


  if (type == "pitch_classes") {
    res <- format.notes.pitch.classes(notes, octave = octave, asChord = asChord)
  }

  else if (type == "scientific_music_notation") {

    # check if in correct format
    lapply(notes, test.if.sci.notation)

    res <- format.notes.scientific_music_notation(notes, asChord = asChord)

  }

  else if (type == "midi_notes") {

    res <- format.notes.midi(notes, asChord = asChord)

  }

  else {
    stop('Unrecognised notation format. Must be one of pitch_classes, scientific_music_notation or midi_notes')

  }
  res

}


play.notes.html.wrapper <- function(stimuli_pitches, stimuli_rhythms) {

  # https://developer.aliyun.com/mirror/npm/package/tone-rhythm

  div(tags$button("Play", id = "playNotes"),
      tags$script(HTML(paste0('

        var synth = new Tone.Synth().toMaster();

        var {
      getBarsBeats,
      addTimes,
      getTransportTimes,
      mergeMusicDataPart
      } = toneRhythm.toneRhythm(Tone.Time); ',
                              'var rhythms = ', rjson::toJSON(stimuli_rhythms), '; ',
                              'var transportTimes = getTransportTimes(rhythms);
                  var pitches = ', rjson::toJSON(stimuli_pitches), '; ',
                              'var mergedData = mergeMusicDataPart({
                rhythms: rhythms,
                notes: pitches,
                startTime: \'0:3:2\'
              });

              var melodyPart = new Tone.Part((time, value) => {
          synth.triggerAttackRelease(value.note, value.duration, time);
          }, mergedData).start(0);

          var playButton = document.getElementById(\'playNotes\');
          playButton.onclick = function() { Tone.Transport.start(); };

                    '))))

}

open.music.display.wrapper <- function(xml) {

  tags$div(
    music.js.scripts,
    tags$div(id="sheet-music"),
    shiny::tags$script(shiny::HTML(paste0('
                var osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay(\"sheet-music\", {drawingParameters: "compact",
                drawPartNames: false, drawMeasureNumbers: false, drawMetronomeMarks: false});
                var loadPromise = osmd.load(`',xml,'`);
                              loadPromise.then(function(){
                              var sheetmusic = document.getElementById("sheet-music");
                              osmd.render();
                              var scoreWidth = String(parseInt(osmd.graphic.musicPages[0].musicSystems[0].PositionAndShape.size.width)*10);
                              scoreWidth = scoreWidth.concat("px");
                              sheetmusic.style.width = scoreWidth;
                              });'))))
}




# response check functions

check.response.type.audio <- function(response_type, state, ...) {
  user_response_selection <- get_global("response_type", state)
  ifelse(user_response_selection == "Microphone", TRUE, FALSE)
}

check.response.type.midi<- function(response_type, state, ...) {
  user_response_selection <- get_global("response_type", state)
  ifelse(user_response_selection == "MIDI", TRUE, FALSE)
}


have.requirements <- function(answer, ...) {
  res <- suppressWarnings(answer)
  if (!is.na(res) && res == "Yes") TRUE
  else display_error("Sorry, you cannot complete the test unless you meet the requirements.")
}


###


set.note.no <- function(stimuli, note_no) {
  # depending on whether a note_no argument was specified, return the correct JS script

  if (note_no == "max") {
    note_no <- '\"max\"'
  }

  if (is.null(note_no)) {
    js_script <- paste0('var stimuli = ', toJSON(stimuli),';')
  }

  else {
    js_script <- paste0('var stimuli = ', toJSON(stimuli),'; Shiny.setInputValue("note_no", ', note_no, ');')
  }
  js_script
}

set.audio.parameters.js.script <- function(highest_allowed_freq, lowest_allowed_freq, min_confidence) {

  shiny::tags$script(paste0('var highestAllowedFreq = ', highest_allowed_freq, '; ',
                            'var lowestAllowedFreq = ', lowest_allowed_freq, '; ',
                            'var minConfidence = ', min_confidence, '; '))
}



audio_parameters_js_script <- set.audio.parameters.js.script(highest_allowed_freq = highest.allowed.freq,
                                                             lowest_allowed_freq = lowest.allowed.freq,
                                                             min_confidence = min.confidence)



###

# range functions

produce_stimuli_in_range <- function(rel_melody, bottom_range = 21, top_range = 108) {
  # given some melodies in relative format, and a user range, produce random transpositions which fit in that range

  rel_melody <- str.mel.to.vector(rel_melody, sep = ",")
  dummy_abs_mel <- rel_to_abs_mel(rel_melody, start_note = 1)
  mel_range <- range(dummy_abs_mel)
  span <- sum(abs(mel_range))


  if(span > top_range - bottom_range) {
    stop('The span of the stimuli is greater than the range of the instrument. It is not possible to play on this instrument.')
  }

  gamut <- bottom_range:top_range
  gamut_clipped <- (bottom_range+span):(top_range-span)
  random_abs_mel <- 200:210  # just instantiate something out of range

  while(any(!random_abs_mel %in% gamut)) {
    # resample until a melody is found that sits in the range
    random_abs_mel_start_note <- sample(gamut_clipped, 1)
    random_abs_mel <- rel_to_abs_mel(rel_melody, start_note = random_abs_mel_start_note)
  }
  random_abs_mel
}

###

# tests
# check.answer("a", "b", type = "single_letters")
# check.answer("a", "a", type = "single_letters")
# check.answer("aaa", "bbb", reverse = FALSE, type = "chunk_letters")
# check.answer("aaa", "aaa", type = "chunk_letters")
# check.answer(11, 22, type = "single_numbers")
# check.answer(11, 11, type = "single_numbers")
# check.answer(11, 11, reverse = TRUE,  type = "chunk_digits")
# check.answer(123, 123, reverse = TRUE, type = "chunk_digits")
# check.answer(123, 321, reverse = TRUE, type = "chunk_digits")
#
# check.answer(1:3, 3:1, reverse = TRUE, type = "chunk_digits")
# check.answer(1:3, 3:1, reverse = FALSE, type = "chunk_digits")
# check.answer(1:3, 1:3, reverse = TRUE, type = "chunk_digits")
# check.answer(1:3, 1:4, reverse = TRUE, type = "chunk_digits")
#
# check.answer(c(10,50,60), c(10,50,60), type = "midi_pitches")
# check.answer(c(10,50,60), c(10,50,60), reverse = TRUE, type = "midi_pitches")
# check.answer(c(10,50,60), c(60,50,10), reverse = TRUE, type = "midi_pitches")
#
#
# filter anything outside of range of interest
# testv <- c(1, 5, 60, 23, 98, 44, 60)
# testv[dplyr::between(testv, gamut.midi[[1]], gamut.midi[[length(gamut.midi)]])]

