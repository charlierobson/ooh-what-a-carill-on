class Results implements StateHandler
{
  int _startTime;
  int[] _scores;
  int[] _target;
  int _maxScore;
  float _scaleFactor;

  Results() {
    _scores = new int[10];
    _target = new int[10];
  }

  void begin() {
    //MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    //for (Controller controller : midiInfo.controllers) {
    //  controller.submitStats(-1);
    //}

    //Gson jsonStats = new Gson();
    //String[] xx = new String[1];
    //xx[0] = jsonStats.toJson(statsDatabase);
    //saveStrings("stats.json", xx);

    //    for (Stats s : statsDatabase) {
    //      float tote = s._deltaSum + 500 * (s._missed + s._early);
    //      float num = s._count + s._missed + s._early;
    //      float ave = tote / num;
    //      float recip = 1 / ave;
    //      float score = ceil(1000 * recip);
    //      _scores[s._id] = (int)score;
    //      _maxScore = max(_scores[s._id], _maxScore);
    //    }

    _scores[0] = 100;
    _scores[1] = 400;
    _scores[2] = 450;
    _scores[3] = 500;
    _scores[4] = 550;
    _scores[5] = 600;
    _scores[6] = 650;
    _scores[7] = 700;
    _scores[8] = 750;
    _scores[9] = 800;

    _maxScore = 800;
    _scaleFactor = 750.0 / _maxScore;

    _startTime = millis();
  }

  String update() {
    for (int i = 0; i < 10; ++i) {
      if (_target[i] < _scores[i]) {
        _target[i] += (_scores[i] - _target[i]) / 32;
      }
    }
    return millis() - _startTime > 5000 ? "Title" : null;
  }

  void draw() {
    background(255);

    fill(0);
    textFont(titleFontBig);
    textAlign(CENTER,CENTER);
    text("The results are in..!", width / 2, 100);

    fill(color(120, 67, 33));
    stroke(0);
    strokeWeight(1);

    for (int i = 0; i < 10; ++i) {

      float h = _target[i] * _scaleFactor;

      rect (236 + (150*i), 900 - h, 97, h);
      image(pud, 235 + (150*i), 900 - h - 98);
      image(balls[i], 210 + (150 * i), 900);
    }
  }
}
