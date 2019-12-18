class Title implements StateHandler
{
  void begin()
  {
    textFont(titleFontBig);

    image(titleImage, 0, 0);
    char letter = 'a';
    int x = 1400, y = 100;
    textFont(titleFontBig);
    textAlign(CENTER,CENTER);
    for (MidiInfo mi : midiProcessor._midiInfos) {
      fill(0);
      text(letter + ": " + mi.filename, x+3, y+3);
      fill(mi._mapped ? 255 : 150);
      text(letter + ": " + mi.filename, x, y);
      y += 55;
      letter ++;
    }

    if (serial != null) {
      serial.write('w');
      serial.write(0);
      serial.write(0);
    }
  }

  String update()
  {
    if (keyPressed) {
      if (key >= 'a' && key < 'a' + midiProcessor._midiInfos.length) {
        midiProcessor.selectSong(key - 'a');
        return "Player";
      }
    }

    return null;
  }

  void draw()
  {
  }
}
