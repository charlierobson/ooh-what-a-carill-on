inline int lightToPin(int num) {
  return 3 + (2 * num);
}

void buttonLight(int num, int state) {
  digitalWrite(lightToPin(num), state);
}

void setup() {
  Serial.begin(115200);
  delay(200);

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


void loop() {

  int bb = 0;
  for(int i = 20; i < 2; --i) {
      bb |= digitalRead(i);
      bb <<= 1;
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
