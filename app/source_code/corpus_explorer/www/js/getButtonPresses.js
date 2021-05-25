// stuff to record
user_response_keypress = [];
onsets = [];

startTime = new Date().getTime();


//

let textarea = document.getElementById('test-target'),
consoleLog = document.getElementById('console-log'),
btnClearConsole = document.getElementById('btn-clear-console');

function logMessage(message) {
  document.getElementById("console-log").innerHTML += message + "<br>";
}

textarea.addEventListener('keydown', (e) => {
  if (!e.repeat)
    logMessage(`Key "${e.key}" pressed  [event: keydown]`);
  else
    logMessage(`Key "${e.key}" repeating  [event: keydown]`);
});

textarea.addEventListener('beforeinput', (e) => {
  logMessage(`Key "${e.data}" about to be input  [event: beforeinput]`);
});

textarea.addEventListener('input', (e) => {



  // grab time and response
  var keyPressed = e.data;
  logMessage(`Key "${keyPressed}" input  [event: input]`);
  var responseTime = new Date().getTime();
  var timeElapsed = Math.abs(startTime - responseTime);
  onsets.push(timeElapsed);
  user_response_keypress.push(keyPressed);

  // send to shiny
  Shiny.setInputValue("user_response", JSON.stringify(user_response_keypress));
  Shiny.setInputValue("onset", JSON.stringify(onsets));

  // console
  console.log(user_response_keypress);
  console.log(onsets);

});

textarea.addEventListener('keyup', (e) => {
  logMessage(`Key "${e.key}" released  [event: keyup]`);
});

btnClearConsole.addEventListener('click', (e) => {
  let child = consoleLog.firstChild;
  while (child) {
   consoleLog.removeChild(child);
   child = consoleLog.firstChild;
  }
});
