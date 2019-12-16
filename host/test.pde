

class SuperController {
  int _skillLevel;
  Controller _player;

  int _bpTicks, _bpEndTicks;

  int _x, _y;

  SuperController(int x, int y, Controller player) {
    _x = x;
    _y = y;
    _player = player;
    _skillLevel = 5;
    _bpEndTicks = 0;
    _bpTicks = Integer.MAX_VALUE;
    _player.reset();
  }

  int getEstimatedReaction() {
    float startVal = map(_skillLevel, 1, 10, 50, 20);
    float endVal = map(_skillLevel, 1, 10, 500, 100);
    return (int)(startVal + random(endVal - startVal));
  }

  void trigger(int ticks, int note) {
    if (_player.trigger(ticks, note)) {
      _bpTicks = ticks + getEstimatedReaction();
    }
  }

  void update(int ticks) {
    if (keyget) {
      if (keycode == ',') {
        for (SuperController c : controllers) {
          if (c._skillLevel > 1) c._skillLevel = c._skillLevel - 1;
        }
      }
      if (keycode == '.') {
        for (SuperController c : controllers) {
          if (c._skillLevel < 10) c._skillLevel = c._skillLevel + 1;
        }
      }
      keyget = false;
    }

    if (mouseclicked) {
      if (dist(mouseX, mouseY, _x, _y + 200 - 30) < 30) {
        if (_skillLevel < 10) _skillLevel = _skillLevel + 1;
      }
      if (dist(mouseX, mouseY, _x, _y + 200 + 30) < 30) {
        if (_skillLevel > 1) _skillLevel = _skillLevel - 1;
      }
    }

    if (ticks >= _bpTicks && _bpEndTicks == 0) {
      _bpEndTicks = _bpTicks + 375;
    }
    if (_bpEndTicks != 0 && ticks > _bpEndTicks) {
      _bpEndTicks = 0;
    }

    if (_bpEndTicks != 0) {
      _player.update(ticks, _player._lightMask);
    } else {
      _player.update(ticks, 0);
    }
  }

  void draw(int ticks) {
    fill(0);
    textAlign(CENTER, CENTER);

    String noteName = noteToNoteName(_player._nextNote);
    fill(0);
    text(noteName, _x, _y);
    fill(_player._lightOffTime > ticks ? color(255, 0, 0) : color(128, 0, 0));
    ellipse(_x, _y + 40, 30, 30);

    fill(_bpEndTicks != 0 ? color(0, 255, 0) : color(128, 0, 0));
    ellipse(_x, _y + 100, 30, 30);


    noFill();
    stroke(0);

    ellipse(_x, _y + 200 - 30, 30, 30);
    text("+", _x, _y + 200 - 30);

    text(str(_skillLevel), _x, _y + 200);

    ellipse(_x, _y + 200 + 30, 30, 30);
    text("-", _x, _y + 200 + 30);

    float ave = totalTickDelta / totalNoteCount;

    text("Total tick delta: " + str(totalTickDelta), 100, _y + 300);
    text("Total note count: " + str(totalNoteCount), 50, _y + 330);
    text("Average tick delta: " + str(floor(ave)), 50, _y + 360);
  }
}

ArrayList<SuperController> controllers = new ArrayList<SuperController>();

public class Test implements StateHandler
{
  int _ticks, _endTimer;
  int _startTime, _pos = 0;

  void begin()
  {
    _startTime = millis();
    textFont(titleFontSmall);

    _pos = 0;
    _endTimer = 10000;

    int x = 50;
    controllers.clear();
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    for (Controller c : midiInfo.controllers) {
      controllers.add(new SuperController(x, 100, c));
      x += 75;
    }

    totalTickDelta = 0;
    totalNoteCount = 0;
    score = 0;
  }

  private void requestNote(int ticks, int note) {
    for (SuperController c : controllers) {
      c.trigger(ticks, note);
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

    for (SuperController controller : controllers) {
      controller.update(_ticks);
    }

    mouseclicked = false;

    return _ticks > _endTimer ? "Title" : null;
  }

  void draw()
  {
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];

    background(255);
    fill(0);
    textAlign(TOP, LEFT);
    text(midiInfo.filename, 20, 20);

    for (SuperController c : controllers) {
      c.draw(_ticks);
    }
  }
}
