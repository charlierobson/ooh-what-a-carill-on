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
        requestNote(_ticks, ni._note);
        _endTimer = _ticks + 5000; // endTimer is set whenever a note is played, times out 5 secs after last note
        ++_pos;

        if (_pos < midiInfo.midi.length) {
          ni = midiInfo.midi[_pos];
        }
      }
    }

    int buttonBits = 0;       
    if (serial != null) {
      serial.write('r');
      while (serial.available() < 2) { 
        delay(1);
      }
      int low = serial.read();
      int hi = serial.read();
      buttonBits = 256 * hi + low;
    }

    int lightsup = 0;
    for (Controller controller : midiInfo.controllers) {
      boolean active = controller.update(_ticks, buttonBits);
      if (active) {
        lightsup |= controller._lightMask;
      }
    }

    if (serial != null) {
      serial.write('w');
      serial.write((byte)(lightsup & 0xff));
      serial.write((byte)(lightsup >> 8));
    }

    return _ticks > _endTimer ? "Title" : null;
  }

  void draw()
  {
    background(254);
  }

  private void requestNote(int ticks, int note) {
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    for (Controller c : midiInfo.controllers) {
      c.trigger(ticks, note);
    }
  }
}
