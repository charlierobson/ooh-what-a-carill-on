String[] noteNames = {
  "A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"
};

String noteToNoteName(int note) {
  if (note < 21) return "-X-";
  int nn = (note - 21) % 12;
  int nm = note/12;
  return noteNames[nn] + str(nm);
}

String toCamelCase(String s){
   String[] parts = s.split(" ");
   String camelCaseString = "";
   for (String part : parts){
      camelCaseString = camelCaseString + " " + toProperCase(part);
   }
   return camelCaseString;
}

String toProperCase(String s) {
    return s.substring(0, 1).toUpperCase() +
               s.substring(1).toLowerCase();
}

class MidiProcessor
{
  MidiInfo[] _midiInfos;
  int _songNum;

  void selectSong(int songNum) {
    _songNum = songNum;
  }

  int findAndProcessFiles() {
    // find all files named with extension(s) '.mid.txt'
    // parse the files and make a midi info class for each
    ArrayList<MidiInfo> miffo = new ArrayList<MidiInfo>();

    for (String name : new File(dataPath("")).list()) {
      if (name.endsWith(".mid.txt")) {
        MidiInfo mi = processTune(name);
        if (mi != null) {
          miffo.add(mi);
        }
      }
    }
    _midiInfos = miffo.toArray(new MidiInfo[miffo.size()]);

    return _midiInfos.length;
  }

  private MidiInfo processTune(String filename) {
    String[] midi = loadStrings(filename);

    // check the header for tempo information. we need:
    //  PPQ or ticks-per-quarter-note
    //  TEMPO or microseconds-per-quarter-note

    float ppqn = -1;
    for (String s : midi) {
      if (s.contains(", Header, ")) {
        String[] parts = s.split(",");
        ppqn = parseFloat(parts[5]);
        break;
      }
    }

    if (ppqn == -1) return null;

    float tempo = -1;
    for (String s : midi) {
      if (s.contains(", Tempo, ")) {
        String[] parts = s.split(",");
        tempo = parseFloat(parts[3]);
        break;
      }
    }

    if (tempo == -1) return null;

    MidiInfo midinfo = new MidiInfo();
    midinfo.filename = filename.substring(0, filename.indexOf('.'));
    midinfo.displayName = toCamelCase(midinfo.filename);
    midinfo.clockRate = tempo / ppqn / 1000.0;

    ArrayList<NoteInfo> notes = new ArrayList<NoteInfo>();
    for (String s : midi) {
      if (s.contains(", Note_on_c,")) {
        String[] parts = s.split(",", 6);
        notes.add(new NoteInfo((int)(parseFloat(parts[1].trim()) * midinfo.clockRate), parseInt(parts[4].trim())));
      }
    }

    midinfo.midi = notes.toArray(new NoteInfo[notes.size()]);

    // count the instances of each note in the song
    midinfo.noteCount = new TreeMap<Integer, Integer>();

    for (NoteInfo noteinfo : midinfo.midi) {
      // if there's no note of this value in the map we'll get the default, 0, back.
      int n = midinfo.noteCount.getOrDefault(noteinfo._note, 0) + 1;
      midinfo.noteCount.put(noteinfo._note, n);
    }

    // write raw mapping
    String s = midinfo.noteCount.toString();
    s = s.substring(1, s.length() - 1);
    String[] mapping = s.split(", ");

    ArrayList<String> s2 = new ArrayList<String>();
    s2.add(midinfo.filename);
    for (String ss : mapping) s2.add(ss);
    saveStrings(dataPath(midinfo.filename + ".map.txt"), s2.toArray(new String[s2.size()]));

    // create controllers
    midinfo.controllers = new Controller[10];
    for (int i = 0; i < 10; ++i) {
      midinfo.controllers[i] = new Controller();
    }

    // map notes to controllers using cooked map
    int n = 0;
    midinfo._mapped = false;
    mapping = loadStrings(midinfo.filename+".map");
    if (mapping != null && mapping.length != 0) {
      midinfo._mapped = true;
      for (Controller controller : midinfo.controllers) {
        String[] m = mapping[n].split("=");
        controller.assignNotes(m[0]);
        controller._lightMask = 1 << n;
        ++n;
      }
    }

    // read lyrics
    midinfo._lyrics = loadStrings(midinfo.filename+".lyrics");
    
    return midinfo;
  }
}
