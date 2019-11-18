/*

~~REMEMBER~~
- Pitch bend 2 semitones (standard amount)!
- MIDI from Daw -> SC
- MIDI from SC -> synth

1. Receive MIDI
2. Convert to frequenies via scale array, step and octave variables
3. Send to MIDI out with pitchbend

~~TODO~~

- Create a GUI for selecting MIDI IN and MIDI OUT

*/

// Initialize


(
var window, inSelector, outSelector;
var midiOutIndex = 2;
var midiInIndex = 0;
var root = 20;
var scale = [
	1,
	11/10,
	9/8,
	6/5,
	5/4,
	4/3,
	nil,
	3/2,
	8/5,
	7/4,
	9/5,
	15/8
];

var midiOut, midiIn, midiSources, midiDestinations;

// Initialize MIDIClient
MIDIClient.init;
MIDIIn.connectAll;

// Get list of available MIDI connections
midiDestinations = MIDIClient.destinations;
midiSources = MIDIClient.sources;

// Assign a MIDI connection (done in GUI?)
midiOut = MIDIOut.newByName(midiDestinations[midiOutIndex].device, midiDestinations[midiOutIndex].name);

// Get rid of hanging MIDI notes
midiOut.allNotesOff(0);

MIDIFunc.noteOn({|val,num,chan,src|
	var step = scale[num%12];
	var octave = (num / 12).floor;
	var freq = root * step * 2.pow(octave);

	var midi = freq.cpsmidi;
	var semitones = midi - midi.round(1);
	var bend = (8192 + (semitones * 4096)).asInteger;

	"midi on".postln;
	src.postln;

	midiOut.bend(0, bend);
	midiOut.noteOn(0, midi.round(1), val);

	freq.postln;
}, srcID: midiSources[midiInIndex].uid);

midiDestinations[1].uid.postln;

MIDIFunc.noteOff({|val,num|
	var step = scale[num%12];
	var octave = (num / 12).floor;
	var freq = root * step * 2.pow(octave);

	var midi = freq.cpsmidi;

	midiOut.noteOff(0, midi.round(1));
}, srcID: midiSources[midiInIndex].uid);

// GUI
window = Window("menu", Rect(100,100,250,250));

window.layout = HLayout(
	VLayout(
		StaticText().string_("IN").align_(\center),
		inSelector = PopUpMenu().items_(
			midiDestinations.collect{|item| item.device + item.name}
		)
	),
	VLayout(
		StaticText().string_("OUT").align_(\center),
		outSelector = PopUpMenu().items_(
			midiDestinations.collect{|item| item.device + item.name}
		)
	)
);

inSelector.action = {|i|
	midiInIndex = i.value
};

outSelector.action = {|i|
	midiOutIndex = i.value;
	midiOut = MIDIOut.newByName(midiDestinations[midiOutIndex].device, midiDestinations[midiOutIndex].name);
};

window.front;
)
	