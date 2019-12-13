public class Player implements StateHandler
{
  int _ticks, _endTimer;
  int _startTime, _pos = 0;

  void begin()
  {
    _startTime = millis();
    textFont(titleFontSmall);
    _pos = 0;
    _endTimer = 10000;
  }

  String update()
  {
    _ticks = millis() - _startTime;
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];

    if (_pos < midiInfo.midi.length) {
      NoteInfo ni = midiInfo.midi[_pos];
      while (_pos < midiInfo.midi.length && _ticks >= ni._tick) {
        requestNote(ni._note, _ticks);
        _endTimer = _ticks + 5000; // endTimer is set whenever a note is played, times out 5 secs after last note
        ++_pos;

        if (_pos < midiInfo.midi.length) {
          ni = midiInfo.midi[_pos];
        }
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
    for (Controller controller : midiInfo.controllers) {
      boolean active = controller.update(_ticks, buttonBits);
      if (active) {
        lightsup |= controller.lightMask;
      }
    }

    serial.write('w');
    serial.write((byte)(lightsup & 0xff));
    serial.write((byte)(lightsup >> 8));

    return _ticks > _endTimer ? "Title" : null;
  }

  void draw()
  {
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];

    background(255);
    fill(0);
    text(midiInfo.filename, 20, 50);
    text(str(_ticks/1000), 20, 100);

    int x = 50;
    for (Controller controller : midiInfo.controllers) {
      String noteName = noteToNoteName(controller._assignedNote);
      fill(0);
      text(noteName, x, 150);
      fill(controller._requestEndTime > _ticks ? color(255, 0, 0) : color(128, 0, 0));
      ellipse(x+5, 200, 30, 30);
      x += 50;
    }
  }

  private void requestNote(int note, int ticks) {
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    for (Controller c : midiInfo.controllers) {
      c.trigger(ticks, note);
    }
  }
}
