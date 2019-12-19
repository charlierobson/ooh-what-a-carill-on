class Results implements StateHandler
{
  int _startTime;
  float[] _scores;
  float[] _target;
  float _maxScore;
  float _scaleFactor;

  Results() {
    _scores = new float[10];
    _target = new float[10];
  }

  void begin() {
    MidiInfo midiInfo = midiProcessor._midiInfos[midiProcessor._songNum];
    for (Controller controller : midiInfo.controllers) {
      controller.submitStats(-1);
    }

    //Gson jsonStats = new Gson();
    //String[] xx = new String[1];
    //xx[0] = jsonStats.toJson(statsDatabase);
    //saveStrings("stats.json", xx);

    println(statsDatabase.size());

    for (Stats s : statsDatabase) {
      float tote = s._deltaSum + 500 * (s._missed + s._early);
      float num = s._count + s._missed + s._early;
      float ave = tote / num;
      float recip = 1 / ave;
      _scores[s._id] = ceil(1000 * recip);
      _maxScore = max(_scores[s._id], _maxScore);
      println("score " + str(_scores[s._id]));
    }

    _scaleFactor = 600.0 / _maxScore;
    println("scale factor " + str(_scaleFactor));

    _startTime = millis();
  }

  String update() {
    for (int i = 0; i < 10; ++i) {
      if (_target[i] < _scores[i]) {
        _target[i] += (_scores[i] - _target[i]) / 64;
      }
    }
    return keyget && keycode == ' ' ? "Title" : null;
  }

  void draw() {
    background(255);

    fill(0);
    textFont(titleFontBig);
    textAlign(CENTER, CENTER);
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
