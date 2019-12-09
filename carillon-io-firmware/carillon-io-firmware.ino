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
  for(int i = 0; i < 10; ++i)
  {
    pinMode(lightToPin(i), OUTPUT);
    digitalWrite(lightToPin(i), LOW);
    Serial.println(lightToPin(i)-1, DEC);
    pinMode(lightToPin(i)-1, INPUT_PULLUP);
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
  if (Serial.available()) {
    int cmd = Serial.read();
    if (cmd == 42) {
      // receive lights from server
      int hi = Serial.read();
      int low = Serial.read();
      int wordup = 256 * hi + low;
      for(int i = 0; i < 10; ++i) {
        buttonLight(i, (wordup & 1) == 1);
        wordup >>= 1;
      }
    }
    else if (cmd == 0x42) {
      // send button states to server
      Serial.write(0xaa);
      Serial.write(0x55);
    }
  }
}
