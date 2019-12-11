public class Player implements StateHandler
{
  int _ticks;
  int _startTime;

  MidiInfo _midiInfo;

  int _pos = 0;

  void begin()
  {
    _startTime = millis();
    int index = midiProcessor._songNum;
    print(index);
    _midiInfo = midiProcessor._midiInfos[index];
  }

  String update()
  {
    _ticks = millis() - _startTime;

    NoteInfo ni = _midiInfo.midi[_pos];

    while (_ticks >= ni._tick && _pos < _midiInfo.midi.length) {
      requestNote(ni._note, _ticks);
      ++_pos;

      if (_pos < _midiInfo.midi.length) {
        ni = _midiInfo.midi[_pos];
      }
    }

    for (int i = 0; i < 127; ++i) {
      if (_ticks > noteOffTimes[i]) {
        midiout.sendNoteOff(0, i, 0);
        noteOffTimes[i] = 0;
      }
    }

    return _pos == _midiInfo.midi.length ? "Title" : null;
  }

  void draw()
  {
    background(255);
    fill(0);
    text(_midiInfo.filename, 10, 20);
    text(str(_ticks/1000), 10, 40);

    int x = 15;
    for (Controller controller : _midiInfo.controllers) {
      if (_ticks > controller._requestEndTime) {
        controller._requestEndTime = 0;
      }

      String noteName = noteToNoteName(controller._assignedNote);
      fill(0);
      text(noteName, x, 60);
      fill(controller._requestEndTime > _ticks ? color(255, 0, 0) : color(128, 0, 0));
      ellipse(x+5, 75, 10, 10);
      x += 35;
    }
  }

  private void requestNote(int note, int ticks) {
    for (Controller c : _midiInfo.controllers) {
      if (c._assignedNote == note) {
        midiout.sendNoteOn(0, note, 64);
        noteOffTimes[note] = ticks + 250;
        c._requestEndTime = ticks + 250;
      }
    }
  }

  String[] noteNames = {
    "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"
  };

  String noteToNoteName(int note) {
    if (note < 21) return "-X-";
    int nn = (note - 21) % 12;
    int nm = note/12;
    return noteNames[nn] + str(nm);
  }

  int[] noteOffTimes = new int[128];
}
