
// Globals to access them later.
let midiIn = [];
let midiOut = [];
let notesOn = new Map(); 

// Start up WebMidi.
function midi_connect() {
  if (typeof(navigator.requestMIDIAccess)!=='function')
    return;
  navigator.requestMIDIAccess()
  .then(
    (midi) => midiReady(midi),
    (err) => console.log('Something went wrong', err));
}

function midiReady(midi) {
  // Also react to device changes.
  initDevices(midi);
  midi.onstatechange = function() { initDevices(midi)};
}

let deviceSelectors = [];

function addDeviceSelector(selector) {
	deviceSelectors[selector] = true;
}

function initDevices(midi) {
  // Reset.
  midiIn = [];
  midiOut = [];
  
  // MIDI devices that send you data.
  const inputs = midi.inputs.values();
  for (let input = inputs.next(); input && !input.done; input = inputs.next()) {
    midiIn.push(input.value);
  }
  
  // MIDI devices that you send data to.
  const outputs = midi.outputs.values();
  for (let output = outputs.next(); output && !output.done; output = outputs.next()) {
    midiOut.push(output.value);
  }
  
  displayDevices();
  startListening();
}

function displayDevices() {
   for (d in deviceSelectors) {
	var s = document.getElementById(d);
	if (!s)
	   continue;
	if (s!==undefined && s!==null) {
           let i = 0;
     	   s.innerHTML = midiIn.map(device => `<option value="${device.id}">${i++}: ${device.name}</option>`).join('');
	}
   }

  var sout = document.getElementById("selectOut");
  if (sout!==undefined && sout!==null)
    sout.innerHTML = midiOut.map(device => `<option value="${device.id}">${device.name}</option>`).join('');
}

function startListening() {
  // Start listening to MIDI messages.
  for (const input of midiIn) {
    input.onmidimessage = midiMessageReceived;
  }
}

var midi_receive_callback = [];
function midiSetReceiveCallback(selector, cb)
{
	midi_receive_callback[selector] = cb;
}

function midiMessageReceived(event) {
  for (var o in midi_receive_callback) {
	var as = document.getElementById(o);
	if (!as)
    	 	continue;
  	if (event.srcElement.id != as.value)
       		continue;
	var cb = midi_receive_callback[o];
	if (typeof(cb) != 'function')
    		continue;

  	cb(event.data);
  }
}

function sendMidiMessage(pitch, velocity, duration) {
  const NOTE_ON = 0x90;
  const NOTE_OFF = 0x80;
  
  const device = midiOut[selectOut.selectedIndex];
  const msgOn = [NOTE_ON, pitch, velocity];
  const msgOff = [NOTE_ON, pitch, velocity];
  
  // First send the note on;
  device.send(msgOn); 
    
  // Then send the note off. You can send this separately if you want 
  // (i.e. when the button is released)
  device.send(msgOff, Date.now() + duration); 
}
  
function copy(event) {
  const str = event.target.nextElementSibling.textContent;
  
  const el = document.createElement('textarea');
  el.value = str;
  document.body.appendChild(el);
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
  
  event.target.textContent = 'Done!';
  event.target.classList.add('active');
  setTimeout(() => {
    event.target.textContent = 'Copy';
    event.target.classList.remove('active');
  }, 1000);
}

