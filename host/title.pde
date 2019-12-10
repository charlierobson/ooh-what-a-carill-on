class Title implements StateHandler
{
  void begin()
  {
    textFont(titleFontBig);
  }

  String update()
  {
    if (keyPressed) {
      if (key >= 'a' && key < 'a' + midiProcessor._files.length) {
        midiProcessor.selectSong(key - 'a');
        return "Player";
      }
    }

    return null;
  }

  void draw()
  {
    image(titleImage, 0, 0);
    char letter = 'a';
    int x = 900, y = 100;
    for (String name : midiProcessor._files) {
      fill(0);
      text(letter + ": " + name, x+5, y+5);
      fill(255);
      text(letter + ": " + name, x, y);
      y += 55;
      letter ++;
    }
  }
}
