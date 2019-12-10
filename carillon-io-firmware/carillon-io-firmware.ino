inline int lightToPin(int num) {
  return 3 + (2 * num);
}

void buttonLight(int num, int state) {
  digitalWrite(lightToPin(num), state);
}

void setup() {
  Serial.begin(115200);

  // put your setup code here, to run once:
  for (int i = 0; i < 10; ++i)
  {
    pinMode(lightToPin(i), OUTPUT);
    digitalWrite(lightToPin(i), LOW);
    pinMode(lightToPin(i) - 1, INPUT_PULLUP);
  }

  for (int i = 0; i < 10; ++i) {
    buttonLight(i, 1);
    delay(50);
  }
  for (int i = 0; i < 10; ++i) {
    buttonLight(i, 0);
    delay(50);
  }
}

byte debounce[10];

void loop() {

  // bb collects a 1 bit for every button which is deemed to be held after debouncing
  int bb = 0;

  // loop from 0..9, but check pins in order 20..2
  for(int i = 0; i < 10; ++i) {
    // button is debounced when all the input collected over the last 8 cycles was 1
    debounce[i] <<= 1;
    debounce[i] |= digitalRead(20 - (i*2)) == LOW ? 1 : 0;

    bb <<= 1;
    bb |= debounce[i] == 0xff ? 1 : 0;
  }

  if (Serial.available() > 0) {
    byte cmd = Serial.read();
    if (cmd == 'w') {
      // receive lights from server
      while (Serial.available() < 2) {
        delay(1);
      }
      int low = Serial.read();
      int hi = Serial.read();
      int wordup = 256 * hi + low;
      for (int i = 0; i < 10; ++i) {
        buttonLight(i, (wordup & 1) == 1);
        wordup >>= 1;
      }
    }
    else if (cmd == 'r') {
      Serial.write((byte)(bb & 255));
      Serial.write((byte)(bb >> 8));
    }
  }
}
