/*

~~REMEMBER~~
- Pitch bend 2 semitones (standard amount)!
- MIDI from Daw -> SC
- MIDI from SC -> synth

1. Receive MIDI
2. Convert to frequenies via scale array, step and octave variables
3. Send to MIDI out with pitchbend

*/

// Initialize


(
var micro;
var scale = [
	1,
	nil,
	9/8,
	6/5,
	5/4,
	4/3,
	nil,
	3/2,
	8/5,
	5/3,
	7/4,
	15/8
];

var root = 20;

MIDIClient.init;
MIDIIn.connectAll;

micro = MIDIOut.newByName("MIDI4x4", "Midi Out 2");

micro.allNotesOff(0);

MIDIFunc.noteOn({|val,num|
	var step = scale[num%12];
	var octave = (num / 12).floor;
	var freq = root * step * 2.pow(octave);

	var midi = freq.cpsmidi;
	var semitones = midi - midi.round(1);
	var bend = (8192 + (semitones * 4096)).asInteger;

	"midi on".postln;

	micro.bend(0, bend);
	micro.noteOn(0, midi.round(1), val);

	freq.postln;
});

MIDIFunc.noteOff({|val,num|
	var step = scale[num%12];
	var octave = (num / 12).floor;
	var freq = root * step * 2.pow(octave);

	var midi = freq.cpsmidi;

	micro.noteOff(0, midi.round(1));
});
)
	