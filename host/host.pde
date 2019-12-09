import java.util.*;
import themidibus.*;

PFont titleFont;
PImage titleImage;

interface StateHandler
{
  abstract void begin();
  abstract String update();
  abstract void draw();
};

HashMap<String,StateHandler> states;

// responsible for collating data related to playback of tune
class MidiInfo {
  String filename;
  String[] midi;
  SortedMap<Integer, Integer> noteCount;
}

// responsible for reading input and feedback and output 
class Controller {
  int assignedNote;
  int requestEndTime;
}

MidiBus midiout;

Controller[] controllers = new Controller[10];

MidiProcessor midiProcessor;
 
StateHandler currentState;

void setup() {
  size(1440, 900);
//  fullScreen();

  titleImage = loadImage("title.png");
  titleFont = createFont("Baskerville-Italic", 50);

  midiout = new MidiBus(this, -1, 1);
  MidiBus.list();

  for (int i = 0; i < 10; ++i) {
    controllers[i] = new Controller();
  }

  midiProcessor = new MidiProcessor();  
  midiProcessor.findAndProcessFiles();

  states = new HashMap<String, StateHandler>();
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
