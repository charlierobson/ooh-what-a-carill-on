class Ready implements StateHandler
{
  int _linenum;
  int _y, _mode;
  String[] _program;
  String _runText;

  Ready() {
    _program = loadStrings("controller.pde");
  }

  void begin() {
    _y = 0;
    _mode = 0;
    _linenum = 0;
    _runText = "";
    background(0);
    fill(color(0, 240, 0));
    textAlign(LEFT, TOP);
  }

  String update() {
    if (keyget) {
      keyget = false;
      _linenum += 2;
      if (_linenum >= _program.length) {
        _mode = 1;
        delay(250);
        if (_runText.equals("RUN")) { delay(500); return "Title"; }
        if (_runText.equals("RU")) _runText = "RUN";
        if (_runText.equals("R")) _runText = "RU";
        if (_runText.equals("")) _runText = "R";
        return null;
      }

      _y += 15;
      if (_y > 1040) {
        _y = 0;
        background(0);
      }
    }
    return null;
  }

  void draw() {
    _program[0] = (millis()&512) == 512 ? "Ready " : "Ready _";

    if (_mode == 0) {
      text(_program[_linenum], 10, _y);
    } else {
      text(_runText, 10, _y + 30);
    }
  }
}
