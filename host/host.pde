import gifAnimation.*;
import processing.serial.*;
import java.util.*;
import themidibus.*;

PFont titleFontBig;
PFont titleFontSmall;
PImage titleImage;
PImage[] dingdong;

Serial serial = null;

int keycode;
boolean keyget = false;

void keyPressed() {
  keycode = key;
  keyget = true;
}

boolean mouseclicked;

void mouseClicked() {
  mouseclicked = true;
}

interface StateHandler
{
  abstract void begin();
  abstract String update();
  abstract void draw();
};

HashMap<String, StateHandler> states;

class NoteInfo {
  int _tick, _note;
  NoteInfo(int tick, int note) {
    _tick = tick;
    _note = note;
  }
}

// responsible for collating data related to playback of tune
class MidiInfo {
  Controller[] controllers;
  String filename;
  NoteInfo[] midi;
  float clockRate;
  SortedMap<Integer, Integer> noteCount;
}

float totalTickDelta;
float totalNoteCount;
float score = 0;
MidiBus midiout;
MidiProcessor midiProcessor;

StateHandler currentState;


void setup() {
  size(1920, 1080);
  pixelDensity(2);

  //  fullScreen();
  //  size(640,480);

  try {
    printArray(Serial.list());
    serial = new Serial(this, Serial.list()[3], 115200);
  }
  catch(Exception ex) {
    // no serial port available
  }

  titleImage = loadImage("title.png");
  titleFontBig = createFont("Baskerville-Italic", 50);
  titleFontSmall = createFont("Baskerville-Italic", 25);

  PImage[] dingdongtemp = Gif.getPImages(this, "dingdong.gif");
  dingdong = new PImage[dingdongtemp.length];

  int w = dingdongtemp[0].width;
  int h = dingdongtemp[0].height;
  int n = 0;
  for(PImage frame : dingdongtemp) {
    PImage newImg = createImage( w, h, ARGB );
    for (int i = 0; i < w * h; ++i) {
      if ((frame.pixels[i] & 0x00ffffff) == 0x00fefefe) {
        newImg.pixels[i] = 0;
      }
      else {
        newImg.pixels[i] = frame.pixels[i];
      }
    }
    dingdong[n] = newImg;
    ++n;
  }

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  midiProcessor = new MidiProcessor();  
  midiProcessor.findAndProcessFiles();

  states = new HashMap<String, StateHandler>();
  states.put("Title", new Title());
  //states.put("Player", new Test());
  states.put("Player", new Player());

  currentState = states.get("Title");
  currentState.begin();
}


int fc = 0;
void draw() {
  String newState = currentState.update();
  if (newState != null) {
    if (states.containsKey(newState)) {
      currentState = states.get(newState);
      currentState.begin();
    }
  }

  currentState.draw();
  image(dingdong[fc % dingdong.length], 10, 10);
  ++fc;
}
