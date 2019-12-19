public class Player implements StateHandler
{
  int _ticks, _endTimer;
  int _startTime, _pos = 0;
  int[] _bell;
  int _songLengthSecs;

  int renderPage(String[] lyrics, int startIdx, int x) {
    int y = 300;
    for (int idx = startIdx; idx < lyrics.length; ++idx) {
      if (lyrics[idx].equals("#")) return idx + 1;
      text(lyrics[idx], x, y);
      y += 50;
    }
    return 0;
  }

  void drawLyrics(String[] lyrics, int page) {
    if (lyrics != null) {
      fill(254);
      noStroke();
      rect(0, 200, width, height);

      fill(0);
      textAlign(CENTER, CENTER);
      textFont(titleFontBig);

      int y = 300;
      int idx = 0;
      if (Arrays.asList(lyrics).contains("#")) {
        idx = renderPage(lyrics, 0, width/3-100);
        renderPage(lyrics, idx, width/3*2+100);
      } else {
        renderPage(lyrics, 0, width/2);
      }
    }
  }

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

    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    drawLyrics(midiInfo._lyrics, 0);

    _songLengthSecs = ceil((float)midiInfo.midi[midiInfo.midi.length - 1]._tick / 1000);

    statsDatabase.clear();

    for (Controller controller : midiInfo.controllers) {
      controller.reset();
    }
  }

  String update()
  {
    _ticks = millis() - _startTime;

    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];

    int secs = _ticks / 10000;
    if (secs != statsDatabase.size() )
    {
      for (Controller controller : midiInfo.controllers) {
        controller.submitStats(_ticks);
      }
    }

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
        lightsup |= (1 << controller._id);
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
