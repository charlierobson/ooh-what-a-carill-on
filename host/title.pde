class Title implements StateHandler
{
  void begin()
  {
    textFont(titleFontBig);
  }

  String update()
  {
    if (keyPressed) {
      if (key >= 'a' && key < 'a' + midiProcessor._midiInfos.length) {
        midiProcessor.selectSong(key - 'a');
        println("Song " + str(midiProcessor._songNum));
       // return "Player";
 return "Test";
      }
    }

    return null;
  }

  void draw()
  {
    image(titleImage, 0, 0);
    char letter = 'a';
    int x = 900, y = 100;
    textFont(titleFontBig);
    for (MidiInfo mi : midiProcessor._midiInfos) {
      fill(0);
      text(letter + ": " + mi.filename, x+3, y+3);
      fill(255);
      text(letter + ": " + mi.filename, x, y);
      y += 55;
      letter ++;
    }
  }
}
