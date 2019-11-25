/**
 * This is a simple sound file player. Use the mouse position to control playback
 * speed, amplitude and stereo panning.
 */

import java.util.*;
import processing.sound.*;

int pos;
Set<Integer> seenNotes = new HashSet<Integer>(); 
SoundFile[] soundfiles = new SoundFile[16];
float[] mf = new float[128];
String[] midi;


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
  background(255);

  for (int x = 0; x < 127; ++x) {
     mf[x] = getRate(x);
  }

  for (int i = 0; i < 16; ++i) {
    soundfiles[i] = new SoundFile(this, "bell-end.aiff");
  }
  
  midi = loadStrings("once-in-royal.mid.txt");
  pos = 0;
}      



int startTime = 0;
boolean done = false;

void draw() {
   if (startTime == 0) startTime = millis();
 
  int ticks = millis() - startTime;

  if (!done) {
    String[] parts = midi[pos].split(",", 6);
      int time = parseInt(parts[1].trim());
      
      if (ticks >= time) {
        int note = parseInt(parts[4].trim());

        for(int i = 0; i < 16; ++i) {
          if (!soundfiles[i].isPlaying()) {
            soundfiles[i].play(mf[note], 1.0);
            seenNotes.add(note);
            break;
          }
        }
        ++pos;
      }
      done = pos == midi.length;
      if (done) {
        println("unique notes: " + str(seenNotes.size()));
      }
  }
}
