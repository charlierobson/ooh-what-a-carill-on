import gifAnimation.*;
import processing.serial.*;
import java.util.*;
import themidibus.*;

PFont titleFontBig;
PFont titleFontSmall;
PImage titleImage;
PImage[] dingdong;
PImage[] balls;
PImage pud;

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
  String displayName;
  NoteInfo[] midi;
  float clockRate;
  SortedMap<Integer, Integer> noteCount;
  String[] _lyrics;
  boolean _mapped;
}

MidiBus midiout;
MidiProcessor midiProcessor;

StateHandler currentState;


void setup() {
  //size(1920, 1080);
  fullScreen(2);

  //try {
  //  printArray(Serial.list());
  //  serial = new Serial(this, Serial.list()[3], 115200);
  //}
  //catch(Exception ex) {
  //  // no serial port available
  //}

  titleImage = loadImage("title.png");
  titleFontBig = createFont("Baskerville-Italic", 50);
  titleFontSmall = createFont("Baskerville-Italic", 25);

  pud = loadImage("pud.png");

  balls = new PImage[10];
  for(int i = 0; i < 10; ++i) {
    balls[i] = loadImage("bbl1.png");
  }

  dingdong = Gif.getPImages(this, "dingdong.gif");

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  midiProcessor = new MidiProcessor();  
  midiProcessor.findAndProcessFiles();

  statsDatabase = new ArrayList<Stats>();

  states = new HashMap<String, StateHandler>();

  states.put("Title", new Title());
  states.put("Results", new Results());
  states.put("Ready", new Ready());

  // test mode 1
  states.put("Player", new Test());
  currentState = states.get("Title");

  //// test mode 2
  //roboMode = true;
  //states.put("Player", new Player());
  //currentState = states.get("Title");

  ////production mode
  //states.put("Player", new Player());
  //currentState = states.get("Ready");

  currentState = states.get("Results");

  currentState.begin();
}


void draw() {
  String newState = currentState.update();
  if (newState != null) {
    if (states.containsKey(newState)) {
      currentState = states.get(newState);
      currentState.begin();
    }
  }

  currentState.draw();
}
