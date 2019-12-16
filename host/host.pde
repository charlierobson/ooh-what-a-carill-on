import processing.serial.*;
import java.util.*;
import themidibus.*;

PFont titleFontBig;
PFont titleFontSmall;
PImage titleImage;
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


float totalTickDelta;
float totalNoteCount;


// responsible for collating data related to playback of tune
class MidiInfo {
  Controller[] controllers;
  String filename;
  NoteInfo[] midi;
  float clockRate;
  SortedMap<Integer, Integer> noteCount;
}

float score = 0;

// responsible for reading input and feedback and output 
class Controller {
  ArrayList<Integer> _assignedNotes = new ArrayList<Integer>();
  int _nextNote;
  int _lightOnTime;
  int _lightOffTime;
  int _lightMask;
  int _noteOffTime;
  int _noteInstances;
  boolean _lastTriggerState;
  boolean _noteMissed;

  boolean _playOdd = true;
  boolean _playEven = true;

  void reset() {
    _noteInstances = 0;
    _lightOffTime = 0;
    _lightOnTime = 0;
    _noteOffTime = 0;
    _noteMissed = false;
  }

  void assignNotes(String notes) {
    // string is of form:
    //   65        - responsible for single note
    //   65,66,..  - responsible for multiple notes    
    //   65.x      - responsible for 1/2 of a some particular note

    if (notes.contains(",")) {
      // one controller multiple notes
      //println("it's a multi: " + notes);
      String[] noteValues = notes.split(",");
      for (String v : noteValues) {
        _assignedNotes.add(parseInt(v));
      }
    } else if (notes.contains(".")) {
      // play either odd or even instances of our assigned note
      //println("it's a timeshare: " + notes);
      String[] noteValues = notes.trim().split("\\.");
      _assignedNotes.add(parseInt(noteValues[0]));        
      if (noteValues[1] == "1") {
        _playOdd = true;
        _playEven = false;
      } else {
        _playOdd = false;
        _playEven = true;
      }
    } else {
      // straight up
      //println("it's a regular: " + notes);
      _assignedNotes.add(parseInt(notes));
    }
  }

  void updateDelta(int delta) {
    float oldAverage = totalTickDelta / (totalNoteCount-1);
    totalTickDelta += delta;
    float newAverage = totalTickDelta / totalNoteCount;
    score += ceil(newAverage - oldAverage);
    println("delta ave: " + str(ceil(newAverage - oldAverage)) + " score: " + str(floor(score)));
  }

  boolean trigger(int ticks, int note) {
    if (_assignedNotes.contains(note)) {
      _noteInstances++;
      if ((_noteInstances & 1) == 1 && _playOdd || (_noteInstances & 1) == 0 && _playEven) {
        // turn on the light, and note which .. note we'll play next
        _nextNote = note;
        // light is on when lightOffTime != 0
        _lightOnTime = ticks;
        _lightOffTime = ticks + 500;

        ++totalNoteCount;

        if (_noteMissed) {
          updateDelta(500);
        }

        _noteMissed = true;

        return true;
      }
    }
    return false;
  }

  // returns true if light is on
  //
  boolean update(int ticks, int buttonMask) {
    if (ticks > _lightOffTime) {
      _lightOffTime = 0;
    }

    boolean triggered = (buttonMask & _lightMask) != 0;
    if (triggered && !_lastTriggerState) {
      // play a note when buttons state transitions not triggered -> triggered
      midiout.sendNoteOn(0, _nextNote, 127);

      // handle case where player hits note or is early
      int tickDelta = ticks - _lightOnTime;
      if (tickDelta > 500) {
        tickDelta = 500;
      }
      updateDelta(tickDelta);

      _noteOffTime = ticks + 500;
      _noteMissed = false;
    }
    _lastTriggerState = triggered;

    if (_noteOffTime != 0 && ticks > _noteOffTime) {
      midiout.sendNoteOff(0, _nextNote, 0); // !!!! edge condition n- use queue??
      _noteOffTime = 0;
    }

    return _lightOffTime != 0;
  }
}

MidiBus midiout;

MidiProcessor midiProcessor;

StateHandler currentState;

void setup() {
  size(1440, 900);
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

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  midiProcessor = new MidiProcessor();  
  midiProcessor.findAndProcessFiles();

  states = new HashMap<String, StateHandler>();
  states.put("Title", new Title());
  states.put("Player", new Test());
  //states.put("Player", new Player());

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
