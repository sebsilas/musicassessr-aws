console.log("loaded play_music_stimuli.js");

//console.log(stimuli);
// grab stimuli from R and send it back to psychTestR
//Shiny.setInputValue("stimuli", JSON.stringify(stimuli));


// initialise toneJS
toneJSInit();

// a little delay after playback finishes before hitting record
var record_delay = 400;

// general functions

function diff(ary) {
    var newA = [];
    for (var i = 1; i < ary.length; i++)  newA.push(ary[i] - ary[i - 1]);
    newA.unshift(0); // pop a 0 on the front
    return newA;
}


/// playback stuff ///


// //  constants
var playback_count = 0; // number of times user presses play in a trial


// //  functions

function updatePlaybackCount() {

    playback_count =  playback_count + 1;

    var playbackTimes = [];

    // record playback values in time
    playbackTimes.push(Date.now());

    var playbackTimesDiff = diff(playbackTimes);
    var playbackTimesCumSum = [];
    playbackTimesDiff.reduce(function(a,b,i) { return playbackTimesCumSum[i] = a+b; },0);
    console.log(playbackTimesCumSum);

    Shiny.setInputValue("playback_count", playback_count);
    Shiny.setInputValue("playback_times", JSON.stringify(playbackTimesCumSum));

}

function toneJSInit() {

  // sound: i.e "tone" or "piano"

  console.log("toneJS Inited!");

  window.synthParameters = {
      oscillator: {
        type: 'sine',
        partialCount: 4
      },
      envelope: { // http://shura.shu.ac.uk/8259/1/96913_Soranzo_psychoacoustics.pdf
        attack: 0.01,
        decay: 0.01,
        sustain: 0.50, // this is changed from the parameters above, which was 0.25
        release: 0.01,
        attackCurve: 'cosine'
      }
    };

  //create a synth and connect it to the master output (your speakers)
  window.synth = new Tone.Synth(synthParameters).toMaster();


  // create a piano and connect to master output
  window.piano = SampleLibrary.load({
    instruments: "piano",
    minify: true
   });

  window.piano.toMaster();

}



function triggerNote(sound, freq_tone, seconds, time) {

  if (sound === "piano") {
  	piano.triggerAttackRelease(freq_tone, seconds, time);
  }

  else {
    synth.triggerAttackRelease(freq_tone, seconds, time);
  }

}

function  playTone(tone, seconds, id, sound) {
  // play a tone for x seconds
  rangeTest(tone);

  tone = Number(tone);
  console.log(tone);

  var freq_tone = Tone.Frequency(tone, "midi").toNote();
  console.log(freq_tone);

  triggerNote(sound, freq_tone, seconds);

  updatePlaybackCount();

  Shiny.setInputValue("stimuli_pitch", tone);

}



function playSeq(note_list, hidePlay, id, sound, page_type) {
    // hide play. boolean. whether to hide the play button

  //rangeTest(note_list);

  updatePlaybackCount();

  // seems to be a bug with the piano sound where it plays an octave higher

  if (sound === "piano") {
    note_list = note_list.map(x => x-12);
  }

  var freq_list = note_list.map(x => Tone.Frequency(x, "midi").toNote());
  console.log(freq_list);

  var last_note = freq_list.length;
  var count = 0;
  var pattern = new Tone.Sequence(function(time, note){
    console.log(note);
    triggerNote(sound, note, 0.50);

    count = count + 1;

    if (count === last_note) {

      if (playback_count === 1) {
        setTimeout(() => {  recordAndStop(null, true, hidePlay, id, page_type); }, record_delay); // delay to avoid catching stimuli in recording
      } // only record the first time

      pattern.stop();
      Tone.Transport.stop();
    }

  }, freq_list);

  pattern.start(0).loop = false;
  Tone.Transport.start();

  Shiny.setInputValue("stimuli_pitch", note_list);

}


function metronomeStart() {
		Tone.Transport.start();
}

function toneJSPlay (midi, note_no, hidePlay, transpose, id, sound, bpm = 90) {
    console.log('hey!');
    console.log(midi);

    // start timer

    window.startTime = new Date().getTime();
    console.log(window.startTime);

    // metronome stuff start
    metronomeStart();

    var player = new Tone.Player("./sounds/woodblock.wav").toMaster();
    console.log(player)
		Tone.Transport.bpm.value = bpm;

		Tone.Buffer.onload = function() {
			//this will start the player on every quarter note
			Tone.Transport.setInterval(function(time){
			    player.start(time);
			}, "4n");
			//start the Transport for the events to start
			Tone.Transport.start();
		};

		// metronome stuff end

    // change tempo to whatever defined in R
    adjusted_tempo = midi;
    adjusted_tempo.header.tempos.bpm = bpm;
    adjusted_tempo.header.tempos[0].bpm = bpm;


    console.log('tempo adjusted');
    console.log(adjusted_tempo);

    var now = Tone.now() + 0.5;
    var synths = [];
    adjusted_tempo.tracks.forEach(track => {

        if (note_no === "max") {
            notes_list = track.notes;

            // console.log(track.notes); // need to test full notes
            dur = track['duration'] * 1000;

        } else {
            // reduced note list
            var dur = 0;
            notes_list = track['notes'].slice(0, note_no);
            // get duration of contracted notes list
            notes_list.forEach(el => {
                   dur = dur + el['duration'];
                })
            dur = dur * 1000;

        }

        console.log(dur);

        setTimeout(() => {
          recordAndStop(null, true, hidePlay, id); }, dur + record_delay); // plus a little delay

        //create a synth for each track
        const synth = new Tone.PolySynth(2, Tone.Synth, synthParameters).toMaster();
        synths.push(synth);

        // pop end note message to end

        //schedule all of the events
        notes_list.forEach(note => {

          transposed_note = Tone.Frequency(note.name).transpose(transpose);

          // correct bug where piano sound plays an octave too high

          if (sound === "piano") {
            transposed_note = transposed_note.transpose(-12);
          }


          triggerNote(sound, transposed_note, note.duration, note.time + now);

        });

        // containers to pass to shiny
        shiny_notes = [];
        shiny_ticks = [];
        shiny_durations = [];
        shiny_durationTicks = [];

        notes_list.forEach(note => {
          shiny_notes.push(note.midi);
          shiny_ticks.push(note.ticks);
          shiny_durations.push(note.duration);
          shiny_durationTicks.push(note.durationTicks);
        });

        // round the durations
        shiny_durations_round = [];
        shiny_durations.forEach(el => shiny_durations_round.push(el.toFixed(2)));

        console.log('poo');
        console.log(shiny_durations_round);

        Shiny.setInputValue("stimuli_pitch", JSON.stringify(shiny_notes));
        Shiny.setInputValue("stimuli_ticks", JSON.stringify(shiny_ticks));
        Shiny.setInputValue("stimuli_durations", JSON.stringify(shiny_durations_round));
        Shiny.setInputValue("stimuli_durationTicks", JSON.stringify(shiny_durationTicks));

    });

}

async function midiToToneJS (url, note_no, hidePlay, transpose, id, sound, bpm) {

// load a midi file in the browser
const midi = await Midi.fromUrl(url).then(midi => {
    toneJSPlay(midi, note_no, hidePlay, transpose, id, sound, bpm);

})
}


// Define a function to handle status messages

function playMidiFile(url, toneJS, note_no, hidePlay, id, transpose, sound, bpm) {

    console.log("bpm is " + bpm);

    console.log(url, toneJS, note_no, hidePlay, id, transpose, sound, bpm);

    // hide after play
    hidePlayButton();

    // toneJS: boolean. true if file file to be played via toneJS. otherwise, via MIDIJS
    // note_no, optional no of notes to cap at

    if (toneJS === true) {
        midiToToneJS(url, note_no, hidePlay, transpose, id, sound, bpm);
    }

    else {
    function display_message(mes) {
        console.log(mes);
    }

    MIDIjs.message_callback = display_message;
    MIDIjs.player_callback = display_time;

    console.log(MIDIjs.get_audio_status());

    MIDIjs.play(url);

    // Define a function to handle player events
    function display_time(ev) {

    console.log(ev.time); // time in seconds, since start of playback

    MIDIjs.get_duration(url,  function(seconds) { console.log("Duration: " + seconds);

    if (ev.time > seconds) {
        console.log("file finished!");
        MIDIjs.player_callback = null;
    }

    });

    }
    }

}


// Define a function to handle status messages

function playMidiFileAndRecordAfter(url, toneJS, note_no, hidePlay, id, transpose, sound, bpm) {


    // toneJS: boolean. true if file file to be played via toneJS. otherwise, via MIDIJS
    // note_no, optional no of notes to cap at

    if (toneJS === true) {
        midiToToneJS(url, note_no, hidePlay, transpose, id, sound, bpm);
    }

    else {
    function display_message(mes) {
        console.log(mes);
    }

    MIDIjs.message_callback = display_message;
    MIDIjs.player_callback = display_time;

    console.log(MIDIjs.get_audio_status());

    MIDIjs.play(url);

    // Define a function to handle player events
    function display_time(ev) {

    console.log(ev.time); // time in seconds, since start of playback

    MIDIjs.get_duration(url,  function(seconds) { console.log("Duration: " + seconds);

    if (ev.time > seconds) {
        console.log("file finished!");
        MIDIjs.player_callback = null;
        recordAndStop(null, true, true, id);
    }

    });

    }
    }

}


// ranges

// //  constants

var soprano = range(60, 84, 1);
var alto = range(53, 77, 1);
var tenor = range(48, 72, 1);
var baritone = range(45, 69, 1);
var bass = range(40, 64, 1);


// // functions

function range(start, stop, step) {
  var a = [start], b = start;
  while (b < stop) {
      a.push(b += step || 1);
  }
  return a;
}

function rangeTest(notes_list) {

    if (typeof notes_list == 'number') {
      notes_list = [notes_list];
    }

    notes_list.forEach(function(note) {

      if (soprano.includes(note) === true) {
        console.log("this comes in the soprano range!");
      }

      if (alto.includes(note) === true) {
        console.log("this comes in the alto range!");
      }

      if (tenor.includes(note) === true) {
        console.log("this comes in the tenor range!");
      }

      if (baritone.includes(note) === true) {
        console.log("this comes in the baritone range!");
      }

      if (bass.includes(note) === true) {
        console.log("this comes in the bass range!");
      }

  });

}

// UI functions

function hidePlayButton() {
  console.log('now we real!');
  var x = document.getElementById("playButton");
  if (x.style.display === "none") {
  x.style.display = "block";
  } else {
  x.style.display = "none";
  }

}


function hideRecordButton() {
  var x = document.getElementById("recordButton");
  if (x.style.display === "none") {
  x.style.display = "block";
  } else {
  x.style.display = "none";
  }

}


//

function recordAndStop (ms, showStop, hidePlay, id, type = "aws_pyin") {
    // start recording but then stop after x milliseconds
    console.log("record and Stop!");
    console.log(hidePlay);
    console.log(showStop);
    console.log(type);

    if (type === "aws_pyin") {
      console.log('11');
      // aws record
      startRecording();
    }
    else if(type === "crepe") {
      console.log('22');
      // crepe record
      initAudio();crepeResume();
    }

    else if(type === "record_midi_page") {
      // leave this
      instantiateMIDI(midi_device);
    }

    else {
      console.log('33');
    }

     if (ms === null) {
        console.log('ms null');
        recordUpdateUI(showStop, hidePlay, type);
     }

     else {
        console.log('ms not null');
        console.log(ms);
        recordUpdateUI(showStop, hidePlay, type);
        setTimeout(() => {  NewAudio.stopRecording(id); }, ms);
     }

}

function recordUpdateUI(showStop, hidePlay, type = "aws_pyin") {

    // update the recording UI
    // if showStop is true, then give the user the option to press the stop button
    // if hidePlay is true, then hide the play button
    console.log('recordUpdateUI called');
    console.log(type);

    if  (hidePlay === true) {
      console.log('hide play bitch!');
      hidePlayButton();
    }


    if (showStop === true) {
        setTimeout(() => {  showStopButton(type); }, 500); // a little lag
    }

    setTimeout(() => {  showRecordingIcon(); }, 500); // a little lag

}


function showStopButton(type = "aws_pyin") {

    var stopButton = document.createElement("button");
    stopButton.style.display = "block";
    stopButton.innerText = "Stop"; // Insert text


    stopButton.addEventListener("click", function () {
        if(type === "crepe") {
           // crepe
          crepeStop();
        }

        else if (type === "record_midi_page") {
           WebMidi.disable();
           var button_area = document.getElementById("button_area");
           button_area.appendChild(stopButton);
        }
        else {
          //
        }
        next_page();
        });


        if(type === "crepe") {
            var button_area = document.getElementById("button_area");
           button_area.appendChild(stopButton);
        }

        else {
          console.log('here we go1 1!');
          startRecording();
          var stopButton = document.getElementById("stopButton");
          controls.style.visibility = 'visible';
          recordButton.style.visibility = 'hidden';
          stopButton.style.visibility = 'visible';
          stopButton.style.display = 'block';
          stopButton.disabled = false;
          var loading = document.getElementById("loading");
          loading.style.visibility = 'hidden';

          stopButton.onclick = function () {
            next_page();
            console.log('lettta 122');
            simpleStopRecording();
          };
        }

}

function showRecordingIcon() {

  var img = document.createElement("img");
  img.style.display = "block";

  img.src =  "./img/record.gif";
  img.width = "280";
  img.height = "280";

  var button_area = document.getElementById("button_area");
  button_area.appendChild(img);

}

function hideRecordImage() {

  var x = document.getElementById("button_area");
       if (x.style.display === "none") {
   x.style.display = "block";
   } else {
   x.style.display = "none";
   }

}

function toggleRecording(e) {
    if (e.classList.contains("recording")) {
        e.classList.remove("recording");
    } else {
        e.classList.add("recording");
    }
}


