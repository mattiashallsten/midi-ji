/*

- Send MIDI to Micro Modular
- Send Pitchbend to Micro Modular
- Write \freq in Pbind, convert to midi note + pitchbend
- Receive midi notes, convert to 


*/

// Send MIDI to Micro Modular
MIDIClient.init
m = MIDIOut.newByName("MIDI4x4", "Midi Out 2");

// Stop MIDI notes when pressing CmdPeriod
CmdPeriod.add({
	m.allNotesOff(0)
})

// Send Pitch bend
m.bend(0, 4096)

// Write \freq in Pbind, convert to midi note + pitchbend
(
Pbind(
	\type, \midi,
	\midiout, m,
	\dur, 2.0,
	\notfreq, 160 * Pseq([
		4/5, 1, 4/5
	],inf),
	\midinote, Pfunc{|e|
		var freq = e[\notfreq];
		var midi = freq.cpsmidi.round(1);

		("midi: " + midi).postln;
		
		midi
	},
		
	\bend, Pfunc{|e|
		var freq = e[\notfreq];
		var midi = freq.cpsmidi;

		var semitones = midi - midi.round(1);

		var bend = (8192 + (semitones * 8192)).asInteger;

		m.bend(0, bend);
		
		("bend: " + bend).postln;
	},
	\line, Pfunc{
		"--------------".postln;
	}
).play 
)

