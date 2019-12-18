public class Player implements StateHandler
{
  int _ticks, _endTimer;
  int _startTime, _pos = 0;
  int[] _bell;
  int _songLengthSecs;

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
        if (s.equals("#")) break;
        text(s, width/2, y);
        y += 50;
      }
    }

    _songLengthSecs = ceil((float)midiInfo.midi[midiInfo.midi.length - 1]._tick / 1000);

    statsDatabase.clear();
    stats = new Stats();
  }

  String update()
  {
    _ticks = millis() - _startTime;

    int secs = _ticks / 1000;
    if (secs != statsDatabase.size() )
    {
      statsDatabase.add(stats);
      stats = new Stats();
    }

    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];

    if (_pos < midiInfo.midi.length) {
      NoteInfo ni = midiInfo.midi[_pos];
      while (_pos < midiInfo.midi.length && _ticks >= ni._tick) {
        requestNote(_ticks, ni._note);
        _endTimer = _ticks + 2500; // endTimer is set whenever a note is played, times out after last note requested
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

    if (keyget && keycode =='q') { 
      keyget = false; 
      return "Title";
    };

    return _ticks > _endTimer ? "Results" : null;
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
