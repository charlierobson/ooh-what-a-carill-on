public class Player implements StateHandler
{
  int _ticks, _endTimer;
  int _startTime, _pos = 0;
  int[] _bell;

  void begin()
  {
    _startTime = millis();
    textFont(titleFontSmall);
    _pos = 0;
    _endTimer = 10000;
    _bell = new int[10];
    background(254);
    for (int i = 0; i < 10; ++i) {
      image (dingdong[0], i * 190, 0);
      _bell[0] = 0;
    }

    textAlign(CENTER, CENTER);
    textFont(titleFontBig);
    fill(0);

    int y = 300;
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    if (midiInfo._lyrics != null) {
      for (String s : midiInfo._lyrics) {
        text(s, width/2, y);
        y += 50;
      }
    }
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

    int n = 0;
    int lightsup = 0;
    for (Controller controller : midiInfo.controllers) {
      boolean active = controller.update(_ticks, buttonBits);
      if (active) {
        lightsup |= controller._lightMask;
      }
      if (controller._justTriggered) {
        _bell[n] = 1;
      }
      ++n;
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
    for (int i = 0; i < 10; ++i) {
      image (dingdong[_bell[i]], i * 190, 0);
      if (_bell[i] != 0) {
        ++_bell[i];
        if (_bell[i] == dingdong.length) {
          _bell[i] = 0;
        }
      }
    }
  }

  private void requestNote(int ticks, int note) {
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    for (Controller c : midiInfo.controllers) {
      c.trigger(ticks, note);
    }
  }
}
