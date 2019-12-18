

import java.util.LinkedList;

import java.util.Queue;

// responsible for reading input and feedback and output 
class Controller {
  ArrayList<Integer> _assignedNotes = new ArrayList<Integer>();

  // first in first out
  Queue<NoteInfo> _noteOffQueue = new LinkedList<NoteInfo>(); 

  // last in first out
  Stack<NoteInfo> _noteOnStack = new Stack<NoteInfo>(); 

  int _nextNote;
  int _lightOnTime;
  int _lightOffTime;
  int _lightMask;
  int _noteInstances;
  boolean _lastTriggerState;
  boolean _justTriggered;

  boolean _playOdd = true;
  boolean _playEven = true;

  void reset() {
    _noteInstances = 0;
    _lightOffTime = 0;
    _lightOnTime = 0;
    _noteOnStack.clear();
    _noteOffQueue.clear();
  }


  void assignNotes(String notes) {
    // notes string is of form:
    //   65        - responsible for single note
    //   65,66,..  - responsible for multiple notes    
    //   65.x      - responsible for 1/2 of instances of some particular note

    if (notes.contains(",")) {
      // one controller multiple notes
      String[] noteValues = notes.split(",");
      for (String v : noteValues) {
        _assignedNotes.add(parseInt(v));
      }
    } else if (notes.contains(".")) {
      // play either odd or even instances of our assigned note
      String[] noteValues = notes.trim().split("\\.");
      _assignedNotes.add(parseInt(noteValues[0]));        
      if (noteValues[1].compareTo("1") == 0) {
        _playOdd = true;
        _playEven = false;
      } else {
        _playOdd = false;
        _playEven = true;
      }
    } else {
      // straight up
      _assignedNotes.add(parseInt(notes));
    }
  }


  boolean trigger(int ticks, int note) {
    // check if we respond to this note
    //
    if (_assignedNotes.contains(note)) {
      // we do! keep track of how many instances of the note have been played
      // some controllers only respond to every other instance of a note
      // playodd and playeven are both true for controllers that respond to all notes
      //
      _noteInstances++;
      if (((_noteInstances & 1) == 1) && _playOdd || ((_noteInstances & 1) == 0) && _playEven) {
        // turn on the light, and note which .. note we'll play next
        //
        _noteOnStack.push(new NoteInfo(ticks, note));

        // test mode
        if (serial == null) {
          midiout.sendNoteOn(0, note, 127);
        }

        // light is on when lightOffTime != 0
        //
        _lightOnTime = ticks;
        _lightOffTime = ticks + 500;

        return true;
      }
    }
    return false;
  }


  // returns true if light is on
  //
  boolean update(int ticks, int buttonMask) {
    // check if it's time to turn the lights out
    //
    if (ticks > _lightOffTime) {
      _lightOffTime = 0;
    }

    // flag if we've been triggered just now
    //
    _justTriggered = false;

    boolean triggered = (buttonMask & _lightMask) != 0;
    if (triggered && !_lastTriggerState) {
      // play a note when buttons state transitions not triggered -> triggered
      //
      if (_noteOnStack.size() == 0) {
        // uh-oh, nothing ready to play
        //
        stats.early();
      } else {
        // get latest note from the stack and play it
        NoteInfo ni = _noteOnStack.pop();
        midiout.sendNoteOn(0, ni._note, 127);

        // note how long it took to respond
        stats.delta(ticks - ni._tick);

        // adjust time into the future and add note to note-off queue
        ni._tick = ticks + 300;
        _noteOffQueue.add(ni);

        // if the on stack isn't empty it means we missed some notes...
        while (_noteOnStack.size() != 0) {
           stats.missed();
          _noteOnStack.pop();
        }
      }
      _justTriggered = true;
    }
    _lastTriggerState = triggered;

    // retire notes if necessary
    while(_noteOffQueue.peek() != null && _noteOffQueue.peek()._tick < ticks) {
      NoteInfo ni = _noteOffQueue.remove();
      midiout.sendNoteOff(0, ni._note, 0);
    }

    return _lightOffTime != 0;
  }
}
