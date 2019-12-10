class MidiProcessor
{
  String[] _files;
  MidiInfo[] _midiInfos;
  int _songNum;

  void selectSong(int songNum) {
    _songNum = songNum;
  }

  int findAndProcessFiles() {
    ArrayList<String> mf = new ArrayList<String>();

    for (String name : new File(dataPath("")).list()) {
      if (name.endsWith(".mid.txt")) {
        mf.add(name.substring(0, name.indexOf('.')));
      }
    }

    _files = mf.toArray(new String[mf.size()]);
    _midiInfos = new MidiInfo[_files.length];

    for (int i = 0; i < _files.length; ++i) {
      _midiInfos[i] = processTune(i);
    }

    return _files.length;
  }

  private MidiInfo processTune(int id) {
    MidiInfo midinfo = new MidiInfo();

    midinfo.filename = _files[id];
    midinfo.midi = loadStrings(midinfo.filename+".mid.txt");

    // count the instances of each note in the song
    midinfo.noteCount = new TreeMap<Integer, Integer>();

    for (String s : midinfo.midi) {
      String[] parts = s.split(",", 6);
      int note = parseInt(parts[4].trim());
      int n = midinfo.noteCount.getOrDefault(note, 0) + 1;
      midinfo.noteCount.put(note, n);
    }

    // write raw mapping
    String s = midinfo.noteCount.toString();
    s = s.substring(1, s.length() - 1);
    String[] mapping = s.split(", ");

    ArrayList<String> s2 = new ArrayList<String>();
    s2.add(midinfo.filename);
    for (String ss : mapping) s2.add(ss);
    saveStrings(dataPath(midinfo.filename + ".map.txt"), s2.toArray(new String[s2.size()]));

    // map notes to controllers using cooked map
    midinfo.controllers = new Controller[10];
    for (int i = 0; i < 10; ++i) {
      midinfo.controllers[i] = new Controller();
    }


    int n = 0;
    mapping = loadStrings(midinfo.filename+".map");
    if (mapping != null && mapping.length != 0) {
      for (Controller controller : midinfo.controllers) {
        String[] m = mapping[n].split("=");
        controller.assignedNote = parseInt(m[0]);
        controller.lightMask = 1 << n;
        ++n;
      }
    }

    return midinfo;
  }
}
