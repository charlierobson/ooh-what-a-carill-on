import processing.serial.*;
import java.util.*;
import themidibus.*;

PFont titleFontBig;
PFont titleFontSmall;
PImage titleImage;
Serial serial;

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

// responsible for reading input and feedback and output 
class Controller {
  int _assignedNote;
  int _requestEndTime;
  int _lightMask;
  int _noteOffTime;
  boolean _lastTriggerState;

  boolean trigger(int ticks, int note) {
    if (note == _assignedNote) {
      _requestEndTime = ticks + 500;
      return true;
    }
    return false;
  }

  boolean update(int ticks, int buttonMask) {
    if (ticks > _requestEndTime) {
      _requestEndTime = 0;
    }

    boolean triggered = (buttonMask & _lightMask) != 0;
    if (triggered && !_lastTriggerState) {
      _noteOffTime = ticks + 500;
      midiout.sendNoteOn(0, _assignedNote, 127);
    }
    _lastTriggerState = triggered;

    if (_noteOffTime != 0 && ticks > _noteOffTime) {
      midiout.sendNoteOff(0, _assignedNote, 0);
      _noteOffTime = 0;
    }

    return _requestEndTime != 0;
  }
}

MidiBus midiout;

MidiProcessor midiProcessor;

StateHandler currentState;

void setup() {
  size(1440, 900);
  //  fullScreen();
  //  size(640,480);

  //printArray(serial.list());
 // serial = new Serial(this, Serial.list()[3], 115200); 

  titleImage = loadImage("title.png");
  titleFontBig = createFont("Baskerville-Italic", 50);
  titleFontSmall = createFont("Baskerville-Italic", 25);

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  midiProcessor = new MidiProcessor();  
  midiProcessor.findAndProcessFiles();

  states = new HashMap<String, StateHandler>();
  states.put("Test", new Test());
  states.put("Title", new Title());
  states.put("Player", new Player());

  currentState = states.get("Title");
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
