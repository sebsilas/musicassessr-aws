// stuff to record
var user_response_midi_note_on = [];
var user_response_midi_note_off = [];
var onsets = [];

startTime = new Date().getTime();

//

function generateDeviceDropdown(){
	WebMidi.enable(function(err) {
	//error collector
    if (err) console.log("WebMidi could not be enabled");
	//generate dropdown with MIDI inputs
	var dropdown = document.getElementById("midiDeviceSelector");
	for (var i=0; i<(WebMidi.inputs.length); i++) {
		var option = document.createElement("option");
		option.text=WebMidi.inputs[i].name;
		option.value=i;
		dropdown.add(option);
	}

  var chosenMIDIDevice = dropdown[dropdown.selectedIndex].text;
  console.log(chosenMIDIDevice);

  Shiny.setInputValue("midi_device", chosenMIDIDevice);


  }
);
}



function instantiateMIDI(midi_device, interactive_midi) {

  // reinstantiate (first disable)
  WebMidi.disable();

  console.log("instantiateMIDI called");

  console.log(interactive_midi);

  console.log(midi_device);

  // empty previous buffer
  if (user_response_midi_note_on) {
    user_response_midi_note_on = [];
  }

  console.log(user_response_midi_note_on);

  WebMidi.enable(function (err) {

      if (err) console.log("WebMidi could not be enabled");

      console.log(typeof(window.input));

      if (typeof(window.input) === "undefined") {

      // Retrieve an input by name, id or index
      window.input = WebMidi.getInputByName(midi_device);

      console.log(window.input);
      console.log(typeof(window.input));

      // remove any activate noteon listeners
      //input.removeListener('noteon');

      console.log(input);
      // OR...

      // Listen for a 'note on' message on all channels
      window.input.addListener('noteon', 'all',
          function (e) {

              console.log("Received 'noteon' message (" + e.note.name + e.note.octave + ").");
              console.log(e.note);
              var midi_note_on = e.note.number;

              console.log(midi_note_on);

              user_response_midi_note_on.push(midi_note_on);


              // play note

              // there is a bug with the piano sound where it plays an octave higher
              // need to make sure this doesn't apply to tones though FIX
              piano_midi_note_on = midi_note_on-12;
              freq_tone = Tone.Frequency(piano_midi_note_on, "midi").toNote();
              triggerNote("piano", freq_tone, 0.25);


              var responseTime = new Date().getTime();
              var timeElapsed = Math.abs(startTime - responseTime);

              onsets.push(timeElapsed);

              // send to shiny
              Shiny.setInputValue("user_response_midi_note_on", JSON.stringify(user_response_midi_note_on));
              //Shiny.setInputValue("user_response_midi_note_off", JSON.stringify(user_response_midi_note_off));
              Shiny.setInputValue("onsets", JSON.stringify(onsets));

              // console
              console.log(user_response_midi_note_on);
              //console.log(user_response_midi_note_off);
              //console.log(onsets);

              // if interactive midi enabled, contiously update the display
              if (interactive_midi) {
                sci_notation = [];
                user_response_midi_note_on.forEach(x => sci_notation.push(fromMidi(x)));
                formatted_notes = format_notes_scientific_music_notation(sci_notation);
                open_music_display_wrapper(wrap_xml_template(formatted_notes));
              }
              //
          }
      );

      // Remove all listeners for 'noteoff' on all channels
      //input.removeListener('noteoff');

      } // end if

  });

}



/// interactive visual notation loading

function open_music_display_wrapper(xml) {

  var osmd = new opensheetmusicdisplay.OpenSheetMusicDisplay("sheet-music", { drawingParameters: "compact",
  drawPartNames: false, drawMeasureNumbers: false, drawMetronomeMarks: false });

  var loadPromise = osmd.load(xml);
  loadPromise.then(function(){
  osmd.render();
  });

}


function wrap_xml_template(notes) {

  res = `<?xml version="1.0" encoding="UTF-8" standalone="no"?>
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
        </attributes>` + notes + `</measure>
    </part>
  </score-partwise>`;

  return res;

}




get_last_char_of_string = function(string) {
  res = string.slice(-1);
  return res;
}

remove_last_char_of_string = function(string) {
  res = string.slice(0, -1);
  return res;
}



function format_accidentals_for_music_xml (pitch_class_string) {
  // take pitch class string, determine if sharp or flat
  // if so, return appropriate <alter> music xml element (-1 for flat, 1 for sharp)
  // if not, return empty string
  // also return the pitch class with the flat removed

  var last_char = get_last_char_of_string(pitch_class_string);

  if (last_char == "b") {
    alter_text = '<alter>-1</alter>';
    pitch_class = remove_last_char_of_string(pitch_class_string);
  }

  else if (last_char == "#") {
    alter_text = '<alter>1</alter>';
    pitch_class = remove_last_char_of_string(pitch_class_string);
  }
  else {
    alter_text = '';
    pitch_class = pitch_class_string;
  }

  return [alter_text, pitch_class];
}


function format_notes_scientific_music_notation(notes, asChord = false) {

  var res = "";

  for(i = 0; i < notes.length; i++) {

    note = remove_last_char_of_string(notes[i]);
    octave = get_last_char_of_string(notes[i]);
    alter = format_accidentals_for_music_xml(note)[0]; // alters specifies if not sharp or flat
    note_without_sharp_or_flat = format_accidentals_for_music_xml(note)[1];

    // https://www.musicxml.com/tutorial/the-midi-compatible-part/pitch/

    if (i === 0) {
      res = res + `<note>
        <pitch>
        <step>` + note_without_sharp_or_flat + `</step>` +
                    alter +
                    `<octave>` + octave + `</octave>
        </pitch>
        <duration>4</duration>
        <type>whole</type>
        </note>`;

    }


    else {

      if(asChord) { chord_text = '<chord/>'; } else { chord_text = ' '; }

      res = res + `<note>` +
                    chord_text + // format as chord
                    `<pitch>
                <step>` + note_without_sharp_or_flat + `</step>` +
                    alter +
                    `<octave>` + octave + `</octave>
                </pitch>
                <duration>4</duration>
                <type>whole</type>
                </note>`;
    }

  }
  console.log(res);
  return res;

}


var CHROMATIC = [ 'C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B' ];

function fromMidi (midi) {
  var name = CHROMATIC[midi % 12];
  var oct = Math.floor(midi / 12) - 1;
  return name + oct;
}

