

# constants


gamut.midi <- 35:85
gamut.freqs <- hrep::midi_to_freq(gamut.midi)
# 61.73541 -> 1108.731 hz
bandwidth <- 1108.731 - 61.73541
lowest.allowed.freq <- round(gamut.freqs[[1]], 3)
highest.allowed.freq <- round(gamut.freqs[[length(gamut.freqs)]], 3)
min.confidence <- 0.8


pitch.classes <- c("A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab")

midi.sci.notation.nos <- c(rep(0,3),rep(1,12),rep(2,12),rep(3,12),rep(4,12),rep(5,12),rep(6,12),rep(7,12), 8)

scientific.pitch.classes <- paste0(pitch.classes, midi.sci.notation.nos)

midi.to.pitch.classes.list <- as.list(rep(pitch.classes, 8)[c(1:88)])
names(midi.to.pitch.classes.list) <- c(21:108)

midi.to.pitch.classes.numeric.list <- as.list(rep(as.integer(1:12), 8)[c(1:88)])
names(midi.to.pitch.classes.numeric.list) <- c(21:108)

midi.to.sci.notation.list <- scientific.pitch.classes
names(midi.to.sci.notation.list) <- c(21:108)


enable.cors <- '
// Create the XHR object.
function createCORSRequest(method, url) {
var xhr = new XMLHttpRequest();
if ("withCredentials" in xhr) {
// XHR for Chrome/Firefox/Opera/Safari.
xhr.open(method, url, true);
} else if (typeof XDomainRequest != "undefined") {
// XDomainRequest for IE.
xhr = new XDomainRequest();
xhr.open(method, url);
} else {
// CORS not supported.
xhr = null;
}
return xhr;
}

// Helper method to parse the title tag from the response.
function getTitle(text) {
return text.match(\'<title>(.*)?</title>\')[1];
}

// Make the actual CORS request.
function makeCorsRequest() {
// This is a sample server that supports CORS.
var url = \'https://eartrainer.app/melodic-production/js/midi.js\';

var xhr = createCORSRequest(\'GET\', url);
if (!xhr) {
alert(\'CORS not supported\');
return;
}

// Response handlers.
xhr.onload = function() {
var text = xhr.responseText;
var title = getTitle(text);
alert(\'Response from CORS request to \' + url + \': \' + title);
};

xhr.onerror = function() {
alert(\'Woops, there was an error making the request.\');
};

xhr.send();
}
'
