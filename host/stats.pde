ArrayList<Stats> statsDatabase;

class Stats
{
  int _deltaSum, _count;
  int _minDelta, _maxDelta;
  int _missed, _early;

  Stats() {
    _minDelta = Integer.MAX_VALUE;
    _maxDelta = Integer.MIN_VALUE;
  }

  void delta(int delta) {
    _minDelta = min(delta, _minDelta);
    _maxDelta = max(delta, _maxDelta);
    _deltaSum += delta;
    ++_count;
  }

  void early() {
    ++_early;
  }

  void missed() {
    ++_missed;
  }

  void dump() {
    println("count: " + str(_count) + "  deltaSum: " + str(_deltaSum));
    println("minDelta: " + str(_minDelta) + "  maxDelta: " + str(_maxDelta));
    println("missed: " + str(_missed) + "  early: " + str(_early));
    println("");
  }
}
