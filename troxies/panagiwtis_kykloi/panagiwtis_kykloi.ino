#include <AccelStepper.h>
#include <SCServo.h>

// ================= CONFIGURATION =================
const bool IS_ENABLED_HIGH = true;
const int dirPin = 6;
const int stepPin = 5;
const int enblPin = 3;
// =================================================

SMS_STS st;
AccelStepper myStepper(AccelStepper::DRIVER, stepPin, dirPin);

String inputString = "";      

void setup() {
  // 1. Force Enable Pin (Lock the motor)
  pinMode(enblPin, OUTPUT);
  digitalWrite(enblPin, IS_ENABLED_HIGH ? HIGH : LOW);

  // 2. Stepper Config
  // High speed/accel is needed to "catch up" to the commands instantly
  myStepper.setMaxSpeed(2000.0);    
  myStepper.setAcceleration(1000.0);

  // 3. Serial
  Serial.begin(115200); // 115200 is required for smooth sync
  Serial1.begin(1000000);
  st.pSerial = &Serial1;
 
  inputString.reserve(50);
}

void loop() {
  // ALWAYS run the stepper
  myStepper.run();

  while (Serial.available() > 0) {
    myStepper.run(); // Keep running while reading
   
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      parseAndExecute(inputString);
      inputString = "";
    } else {
      inputString += inChar;
    }
  }
}

void parseAndExecute(String input) {
  int comma1 = input.indexOf(',');
  int comma2 = input.indexOf(',', comma1 + 1);

  if (comma1 > 0 && comma2 > 0) {
    // Extract values
    float val1 = input.substring(0, comma1).toFloat();
    float val2 = input.substring(comma1 + 1, comma2).toFloat();
    float val3 = input.substring(comma2 + 1).toFloat();

    // --- SERVO 1 (ABSOLUTE) ---
    // Pass the absolute angle directly
    moveServoToAbsolute(1, val1);

    // --- SERVO 2 (ABSOLUTE) ---
    // Pass the absolute angle directly
    moveServoToAbsolute(2, val2);

    // --- STEPPER (RELATIVE) ---
    // Calculate steps from the Delta Distance
    long steps = (long)((val3 * 2000.0) / 0.8);
   
    if (steps != 0) {
      myStepper.move(steps);
    }
  }
}

int angleToPosition(float angle) {
  angle = constrain(angle, -180, 180);
  return map(angle, -180, 180, 0, 4095);
}

void moveServoToAbsolute(int ID, float angle) {
  int pos = angleToPosition(angle);
  // Speed = 0 (Max speed).
  // We rely on the frequent updates from MATLAB (every 0.2s)
  // to control the speed profile, rather than the servo's internal speed.
  st.WritePosEx(ID, pos, 0, 0);
}