void setup() {
  // put your setup code here, to run once:
  pinMode(21, OUTPUT);
  digitalWrite(21, LOW);
  pinMode(20, INPUT_PULLUP);
}

void loop() {
  // put your main code here, to run repeatedly:

  digitalWrite(21, !digitalRead(20));
}
