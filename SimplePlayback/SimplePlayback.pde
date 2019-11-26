/**
 * This is a simple sound file player. Use the mouse position to control playback
 * speed, amplitude and stereo panning.
 */

import java.util.*;
import processing.sound.*;

class midinfo {
  String filename;
  String[] midi;
}

int pos;
Set<Integer> seenNotes = new HashSet<Integer>(); 
SoundFile[] soundfiles = new SoundFile[16];
midinfo[] midinfos;
float[] mf = new float[128];

int root = 48;

float getRate(float note) {
  float rate = 1.0;
  if (note < root) {
    rate = 1 / (float)Math.pow(2, (root - note) / 12.0);
  } else {
    rate = (float)Math.pow(2, (note - root) / 12.0);
  } 
  return rate;
}


void setup() {
  size(640, 360);
  fill(0);

  for (int x = 0; x < 127; ++x) {
    mf[x] = getRate(x);
  }

  for (int i = 0; i < 16; ++i) {
    soundfiles[i] = new SoundFile(this, "bell-end.aiff");
  }

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
  midinfos = midis.;
}


int state = 0;
int startTime = 0;
int tune;
boolean done = false;

int chooseSong() {
  background(200);
  char letter = 'a';
  int x = 10, y = 30;
  for (midinfo info : midis) {
    text(letter + ": " + info.filename, x, y);
    y += 25;
  }
  if (key >= 'a' && key < letter) {
    startTime = millis();
    tune = key - 'a';
    pos = 0;
    return 1;
  }

  return 0;
}

int playSong() {
  int ticks = millis() - startTime;

  String[] parts = midi[pos].split(",", 6);
  int time = parseInt(parts[1].trim());

  if (ticks >= time) {
    int note = parseInt(parts[4].trim());

    for (int i = 0; i < 16; ++i) {
      if (!soundfiles[i].isPlaying()) {
        soundfiles[i].play(mf[note], 1.0);
        break;
      }
    }
    ++pos;
  }

  background(255);
  text("title", 10, 20);
  text(str(ticks/1000), 10, 40);
  
  return pos == midi.length ? 0 : 1;
}


void draw() {
  switch (state) {
  case 0:
    state = chooseSong();
    break;
  case 1:
    state = playSong();
    break;
  }
}
