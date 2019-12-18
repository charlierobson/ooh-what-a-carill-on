class Results implements StateHandler
{
  void begin() {
    Stats[] s = statsDatabase.toArray(new Stats[statsDatabase.size()]);
    for (Stats ss : s) {
      println(ss);
    }
  }

  String update() {
    return "Title";
  }

  void draw() {
  }
}
