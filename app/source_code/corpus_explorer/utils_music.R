# constants


pitch.classes <- c("A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab")

midi.sci.notation.nos <- c(rep(0,3),rep(1,12),rep(2,12),rep(3,12),rep(4,12),rep(5,12),rep(6,12),rep(7,12), 8)

scientific.pitch.classes <- paste0(pitch.classes, midi.sci.notation.nos)

midi.to.pitch.classes.list <- as.list(rep(pitch.classes, 8)[c(1:88)])
names(midi.to.pitch.classes.list) <- c(21:108)

midi.to.pitch.classes.numeric.list <- as.list(rep(as.integer(1:12), 8)[c(1:88)])
names(midi.to.pitch.classes.numeric.list) <- c(21:108)

midi.to.sci.notation.list <- scientific.pitch.classes
names(midi.to.sci.notation.list) <- c(21:108)

# functions

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

  res <- paste0('<?xml version="1.0" encoding="UTF-8" standalone="no"?>
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
  </score-partwise>')
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

  paste0('<div id = "sheet-music"> </div>
    <script>
                var osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay(\"sheet-music\", {drawingParameters: "compact",
                drawPartNames: false, drawMeasureNumbers: false, drawMetronomeMarks: false});
                var loadPromise = osmd.load(`',xml,'`);
                              loadPromise.then(function(){
                              var sheetmusic = document.getElementById("sheet-music");
                              osmd.render();
                              var scoreWidth = String(parseInt(osmd.graphic.musicPages[0].musicSystems[0].PositionAndShape.size.width)*10);
                              scoreWidth = scoreWidth.concat("px");
                              sheetmusic.style.width = scoreWidth;
                              });</script>')
}
