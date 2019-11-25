/**
 * This is a simple sound file player. Use the mouse position to control playback
 * speed, amplitude and stereo panning.
 */

import processing.sound.*;

SoundFile soundfile;
String[] midi;
float[] mf;
int pos;

void setup() {
  size(640, 360);
  background(255);

  mf = new float[128];
  for (int x = 0; x < 127; ++x)
  {
     mf[x] = (float)(27.5 * Math.pow((float)(x - 21) / 12.0, 2.0));
  }

  // Load a soundfile
  soundfile = new SoundFile(this, "hit.aiff");

  midi = loadStrings("musdat.txt");
  pos = 0;

  // These methods return useful infos about the file
  println("SFSampleRate= " + soundfile.sampleRate() + " Hz");
  println("SFSamples= " + soundfile.frames() + " samples");
  println("SFDuration= " + soundfile.duration() + " seconds");
}      


void draw() {
  if (pos < midi.length) {
    String[] parts = midi[pos].split(",", 6);
      int time = parseInt(parts[1].trim());
      int note = parseInt(parts[4].trim());
      
      float rate;
      if (note < 69) {
        rate = ((69 - note) / 12) * .5;
      } else {
        rate = 1 + ((note - 69) / 12) * 2;
      }
      if (millis() >= time) {
        soundfile.play(rate, 1.0);
        println(rate);
        ++pos;
      }
  }
}
