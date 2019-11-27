import java.util.*;
import themidibus.*;

class MidiInfo {
  String filename;
  String[] midi;
  SortedMap<Integer, Integer> noteCount;
  int pos;
}

MidiBus midiout;

// filenames of available midis
String[] files;

// info about selected/playing midi
MidiInfo midinfo;



void setup() {
  size(640, 480);
  fill(0);

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  // find midi files
  ArrayList<String> mf = new ArrayList<String>();

  for (String name : new File(dataPath("")).list()) {
    if (name.endsWith(".mid.txt")) {
      mf.add(name.substring(0, name.indexOf('.')));
    }
  }

  files = mf.toArray(new String[mf.size()]);
}


void processTune(int id) {
  midinfo = new MidiInfo();
  
  midinfo.pos = 0;
  midinfo.filename = files[id];
  midinfo.midi = loadStrings(midinfo.filename+".mid.txt");

  // count the instances of each note in the song
  midinfo.noteCount = new TreeMap<Integer, Integer>();

  for (String s : midinfo.midi) {
    String[] parts = s.split(",", 6);
    int note = parseInt(parts[4].trim());
    int n = midinfo.noteCount.getOrDefault(note, 0) + 1;
    midinfo.noteCount.put(note, n);
  }
}


int state = 0;
int startTime = 0;

int tune;
boolean done = false;

int chooseSong() {
  background(200);

  char letter = 'a';
  int x = 10, y = 30;
  for (String name : files) {
    text(letter + ": " + name, x, y);
    y += 20;
    letter ++;
  }

  if (key >= 'a' && key < letter) {
    startTime = millis();
    processTune(key - 'a');
    return 1;
  }

  return 0;
}


void requestNote(int note, int ticks) {
  midiout.sendNoteOn(0, note, 64);
  noteOffTimes[note] = ticks + 250;
}

String[] noteNames = {
  "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"
};

String noteToNoteName(int note) {
  if (note < 21) return "-X-";
  int nn = (note - 21) % 12;
  int nm = note/12;
  return noteNames[nn] + str(nm);
}

int[] noteOffTimes = new int[128];

int playSong() {
  int ticks = millis() - startTime;

  String[] parts = midinfo.midi[midinfo.pos].split(",", 6);
  int time = parseInt(parts[1].trim());

  while (ticks >= time && midinfo.pos < midinfo.midi.length) {
    int note = parseInt(parts[4].trim());
    requestNote(note, ticks);
    ++midinfo.pos;

    if (midinfo.pos < midinfo.midi.length) {
      parts = midinfo.midi[midinfo.pos].split(",", 6);
      time = parseInt(parts[1].trim());
    }
  }

  for (int i = 0; i < 127; ++i) {
    if (ticks > noteOffTimes[i]) {
      midiout.sendNoteOff(0, i, 0);
      noteOffTimes[i] = 0;
    }
  }

  background(255);
  text(midinfo.filename, 10, 20);
  text(str(ticks/1000), 10, 40);
  int x = 10;
  for (int note : midinfo.noteCount.keySet()) {
    String noteName = noteToNoteName(note);
    int noteCount = midinfo.noteCount.get(note);
    text(noteName, x, 60);
    text(str(noteCount), x, 75);
    x += 35;
  }

  return midinfo.pos == midinfo.midi.length ? 2 : 1;
}


int songComplete() {
  background(255);
  text("Press space", 10, 20);
  return key == ' ' ? 0 : 2;
}


void draw() {
  switch (state) {
  case 0:
    state = chooseSong();
    break;
  case 1:
    state = playSong();
    break;
  case 2:
    state = songComplete();
    break;
  }
}
