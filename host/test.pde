public class Test implements StateHandler
{
  byte[] _dataOut;
  int _buttonBits;

  Test() {
    _dataOut = new byte[3];
  }

  void begin() {
    _dataOut[0] = 'w';
    _dataOut[1] = 0;
    _dataOut[2] = 0;
    _buttonBits = 0;    
  }

  String update() {
    if (keyget) {
      if (keycode == 'a') {
        _dataOut[1] ^= 32;
        serial.write('w');
        serial.write(_dataOut[1]);
        serial.write(_dataOut[2]);
      }
      if (keycode == 's') {
        serial.write('r');
        while(serial.available() < 2) { delay(1); }
        int low = serial.read();
        int hi = serial.read();
        _buttonBits = 256 * hi + low;       
      }
      keyget = false;
    }

    //while (serial.available() != 0) {      
    //  print((char)serial.read());
    //}
    return null;
  }

  void draw() {
    background(color(0, 200, 0));

    for (int i = 0, mask = 512; i < 10; ++i) {
      fill(0);
      if ((_buttonBits & mask) != 0) {
        fill(color(255,0,0));
      }
      rect(i * 20 + 100, 100, 15, 15);
      mask >>= 1;
    }
  }
}
