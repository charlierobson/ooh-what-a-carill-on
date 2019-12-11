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
    textFont(titleFontSmall);
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

    serial.write('r');
    while (serial.available() < 2) { 
      delay(1);
    }
    int low = serial.read();
    int hi = serial.read();
    int buttonBits = 256 * hi + low;       
    println(low, hi);

    int lightsup = 0;
    for (Controller controller : _midiInfo.controllers) {
      boolean active = controller.update(_ticks, buttonBits);
      if (active) {
        lightsup |= controller.lightMask;
      }
    }

    serial.write('w');
    serial.write((byte)(lightsup & 0xff));
    serial.write((byte)(lightsup >> 8));

    return _pos == _midiInfo.midi.length ? "Title" : null;
  }

  void draw()
  {
    background(255);
    fill(0);
    text(_midiInfo.filename, 20, 50);
    text(str(_ticks/1000), 20, 100);

    int x = 50;
    for (Controller controller : _midiInfo.controllers) {
      String noteName = noteToNoteName(controller.assignedNote);
      fill(0);
      text(noteName, x, 150);
      fill(controller.requestEndTime > _ticks ? color(255, 0, 0) : color(128, 0, 0));
      ellipse(x+5, 200, 30, 30);
      x += 50;
    }
  }

  private void requestNote(int note, int ticks) {
    for (Controller c : _midiInfo.controllers) {
      c.trigger(ticks, note);
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
}
