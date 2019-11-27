import java.util.*;
import processing.sound.*;
import themidibus.*;

class midinfo {
  String filename;
  String[] midi;
}

midinfo[] midinfos;

AudioSample[] samples = new AudioSample[40];

int pos;

MidiBus midiout;

void setup() {
  size(640, 360);
  fill(0);

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  SoundFile f = new SoundFile(this, "bell-jar.aiff");
  int cliplen = f.frames() / 40;
  for (int i = 0; i < 40; ++i) {
    float[] data = new float[cliplen];
    f.read(i * cliplen, data, 0, cliplen); 
    samples[i] = new AudioSample(this, data);
  }

  Set<Integer> seenNotes = new HashSet<Integer>(); 

  String[] midinames = new File("/Users/charlierobson/Documents/gh/ooh-what-a-carillon/SimplePlayback/data").list();  

  List<midinfo> midis = new ArrayList<midinfo>();

  for (String name : midinames) {
    if (name.endsWith(".mid.txt")) {
      midinfo info = new midinfo();
      info.filename = name;

      info.midi = loadStrings(name);

      seenNotes.clear();        
      for (String s : info.midi) {
        String[] parts = s.split(",", 6);
        seenNotes.add(parseInt(parts[4].trim()));
      }

      println("\nmidi: " + name);
      List<Integer> toSort = new ArrayList<Integer>(seenNotes);
      Collections.sort(toSort);
      for (Integer i : toSort) {
        print(" " + str(i));
      }
      println("\nunique notes: " + str(seenNotes.size()));

      midis.add(info);
    }
  }
  midinfos = midis.toArray(new midinfo[midis.size()]);
}


int state = 0;
int startTime = 0;
int tune;
boolean done = false;

int chooseSong() {
  background(200);
  char letter = 'a';
  int x = 10, y = 30;
  for (midinfo info : midinfos) {
    text(letter + ": " + info.filename.substring(0, info.filename.indexOf('.')), x, y);
    y += 20;
    letter ++;
  }
  if (key >= 'a' && key < letter) {
    startTime = millis();
    tune = key - 'a';
    pos = 0;
    return 1;
  }

  return 0;
}

int[] noteOffTimes = new int[128];

int playSong() {
  int ticks = millis() - startTime;

  String[] parts = midinfos[tune].midi[pos].split(",", 6);
  int time = parseInt(parts[1].trim());

  if (ticks >= time) {
    int note = parseInt(parts[4].trim());
    midiout.sendNoteOn(0, note, 64);
    noteOffTimes[note] = ticks + 250;
    ++pos;
  }

  for (int i = 0; i < 127; ++i) {
    if (ticks > noteOffTimes[i]) {
      midiout.sendNoteOff(0, i, 0);
      noteOffTimes[i] = 0;
    }
  }
  
  background(255);
  text(midinfos[tune].filename, 10, 20);
  text(str(ticks/1000), 10, 40);

  return pos == midinfos[tune].midi.length ? 2 : 1;
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
