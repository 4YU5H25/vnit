#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "BluetoothSerial.h" // Include the BluetoothSerial library

int touchpin = 4;

#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64

#define OLED_RESET 4
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

BluetoothSerial SerialBT; // Define the BluetoothSerial object

const int ANALOG_INPUT_PIN = A0;
const int DELAY_LOOP_MS = 200;

int _curWriteIndex = 0;
int _circularBuffer[SCREEN_WIDTH];
int _maxValue = 0;
int _minValue = 1023;

void setup() {
  Serial.begin(115200);
  pinMode(touchpin, INPUT);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    while (1); // Halt execution
  }

  display.clearDisplay();
  display.display();
  delay(500);
  display.clearDisplay();
  display.display();

  SerialBT.begin("ESP32test"); // Start Bluetooth Serial with the given name

  delay(1000);
}

void loop() {
  display.clearDisplay();

  int analogVal = touchRead(touchpin);
  Serial.println(analogVal);

  _circularBuffer[_curWriteIndex++] = analogVal;

  if (_curWriteIndex >= SCREEN_WIDTH) {
    _curWriteIndex = 0;
  }

  // Update max and min values
  _maxValue = max(_maxValue, analogVal);
  _minValue = min(_minValue, analogVal);

  // Draw the graph with autoscaling
  drawGraph();

  display.display();

  // Send analog value to connected device via Bluetooth Serial
  SerialBT.println(analogVal);

  delay(DELAY_LOOP_MS);
}

void drawGraph() {
  int maxValue = max(_maxValue, 1); // Prevent division by zero
  int minValue = _minValue;
  int graphHeight = SCREEN_HEIGHT - 10; // Leave space for status bar

  for (int i = 0; i < SCREEN_WIDTH - 1; i++) {
    int x0 = i;
    int y0 = map(_circularBuffer[i], minValue, maxValue, graphHeight, 0);
    int x1 = i + 1;
    int y1 = map(_circularBuffer[(i + 1) % SCREEN_WIDTH], minValue, maxValue, graphHeight, 0);

    display.drawLine(x0, y0, x1, y1, WHITE);
  }
}