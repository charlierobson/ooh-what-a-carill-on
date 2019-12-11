import processing.serial.*;
import java.util.*;
import themidibus.*;

PFont titleFont;
PImage titleImage;
Serial serial;

int keycode;
boolean keyget = false;

void keyPressed() {
  keycode = key;
  keyget = true;
}


interface StateHandler
{
  abstract void begin();
  abstract String update();
  abstract void draw();
};

HashMap<String,StateHandler> states;

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

// responsible for reading input and feedback and output 
class Controller {
  int _assignedNote;
  int _requestEndTime;
}

MidiBus midiout;

MidiProcessor midiProcessor;
 
StateHandler currentState;

void setup() {
  size(1440, 900);
//  fullScreen();
//  size(640,480);

  serial = new Serial(this, Serial.list()[3], 115200); 

  titleImage = loadImage("title.png");
  titleFont = createFont("Baskerville-Italic", 50);

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  midiProcessor = new MidiProcessor();  
  midiProcessor.findAndProcessFiles();

  states = new HashMap<String, StateHandler>();
  states.put("Test", new Test());
  states.put("Title", new Title());
  states.put("Player", new Player());

  currentState = states.get("Title");
}



void draw() {
  String newState = currentState.update();
  if (newState != null) {
    println(newState);
    if (states.containsKey(newState)) {
      currentState = states.get(newState);
      currentState.begin();
    }
  }

  currentState.draw();
}
