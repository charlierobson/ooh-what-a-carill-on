class Ready implements StateHandler
{
  int _linenum;
  int _y, _startRun;
  String[] _program;
  String _runText;

  Ready() {
    _program = loadStrings("controller.pde");
  }

  void begin() {
    _y = 0;
    _startRun = 0;
    _linenum = 0;
    _runText = "";
    background(0);
    fill(color(0, 240, 0));
    textAlign(LEFT, TOP);
  }

  String update() {
    if (_startRun != 0) {
      int t = millis() - _startRun;
      if (t > 3000) return "Title";
      return null;
    }

    if (keyget) {
      keyget = false;
      _linenum += 2;
      if (_linenum >= _program.length) {
        _startRun = millis();
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
    _program[0] = (millis()&512) == 512 ? "Ready  " : "Ready _";

    if (_startRun == 0) {
      text(_program[_linenum], 10, _y);
    } else {
      int t = (millis() - _startRun) / 128;
      if (t > 5) t = 5;
      text("RUN    ".substring(0, t), 10, _y + 30);
    }
  }
}
