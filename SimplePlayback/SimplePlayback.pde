import java.util.*;
import themidibus.*;

// responsible for collating data related to playback of tune
class MidiInfo {
  String filename;
  String[] midi;
  SortedMap<Integer, Integer> noteCount;
  int pos;
}

// responsible for reading input and feedback and output 
class Controller {
  int assignedNote;
  int requestEndTime;
}

MidiBus midiout;

// filenames of available midis
String[] files;

// info about selected/playing midi
MidiInfo midinfo;

Controller[] controllers = new Controller[10];


void setup() {
  size(640, 480);
  fill(0);

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  for (int i = 0; i < 10; ++i) {
    controllers[i] = new Controller();
  }

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

  // write raw mapping
  String s = midinfo.noteCount.toString();
  s = s.substring(1, s.length() - 1);
  String[] mapping = s.split(", ");
  saveStrings(dataPath(midinfo.filename + ".map.txt"), mapping);


  // map notes to controllers using cooked map
  int n = 0;

  mapping = loadStrings(midinfo.filename+".map");
  if (mapping != null && mapping.length != 0) {
    for (Controller controller : controllers) {
      String[] m = mapping[n].split("=");
      controller.assignedNote = parseInt(m[0]);
      ++n;
    }
  }
}


int state = 0;
int startTime = 0;

int tune;
boolean done = false;

int chooseSong() {
  background(200);
  fill(0);

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
  for (Controller c : controllers) {
    if (c.assignedNote == note) {
      //midiout.sendNoteOn(0, note, 64);
      //noteOffTimes[note] = ticks + 250;
      c.requestEndTime = ticks + 250;
    }
  }
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
  fill(0);
  text(midinfo.filename, 10, 20);
  text(str(ticks/1000), 10, 40);

  int x = 15;
  for (Controller controller : controllers) {
    if (ticks > controller.requestEndTime) {
        controller.requestEndTime = 0;
    }

    String noteName = noteToNoteName(controller.assignedNote);
    fill(0);
    text(noteName, x, 60);
    fill(controller.requestEndTime > ticks ? color(255, 0, 0) : color(128, 0, 0));
    ellipse(x+5, 75, 10, 10);
    x += 35;
  }

  return midinfo.pos == midinfo.midi.length ? 2 : 1;
}


int songComplete() {
  background(255);
  fill(0);

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
