class Results implements StateHandler
{
  void begin() {
    Gson jsonStats = new Gson();
    String[] xx = new String[1];
    xx[0] = jsonStats.toJson(statsDatabase);
    saveStrings("stats.json", xx);

    //Stats[] s = statsDatabase.toArray(new Stats[statsDatabase.size()]);
    //for (Stats ss : s) {
    //  ss.dump();
    //}
  }

  String update() {
    return "Title";
  }

  void draw() {
  }
}
