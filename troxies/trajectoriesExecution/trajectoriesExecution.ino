#include <AccelStepper.h>
#include <SCServo.h>

SMS_STS st;

//Stepper Pins
const int dirPin = 6;
const int stepPin = 5;
const int enblPin = 3;

//Stepper Initialization
AccelStepper myStepper(AccelStepper::DRIVER, stepPin, dirPin);

String inputString = "";

void setup() {
  
  pinMode(enblPin, OUTPUT);
  digitalWrite(enblPin, LOW);

  myStepper.setMaxSpeed(2000.0);    
  myStepper.setAcceleration(1000.0); 

  //Servo Initialization
  Serial.begin(115200);
  Serial1.begin(1000000);
  st.pSerial = &Serial1;

  inputString.reserve(50);
}

void loop() {
  myStepper.run();

  while (Serial.available() > 0) {
    myStepper.run(); // Keep running while reading
   
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      executeTraj(inputString);
      inputString = "";
    } else {
      inputString += inChar;
    }
  }

  //if (myStepper.distanceToGo() == 0){
   //   digitalWrite(enblPin, LOW);
  //}
}

void executeTraj(String input) {
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
    // Calculate steps 
    int steps = (val3 * 400) / 0.8;
   
    if (steps != 0) {
      digitalWrite(enblPin, HIGH);
      myStepper.move(steps);
    }
  }
}

float angleToPosition(float angle) {
  angle = constrain(angle, -180, 180);
  return map(angle, -180, 180, 0, 4095);
}

void moveServoToAbsolute(int ID, float angle) {
  float pos = angleToPosition(angle);
  st.WritePosEx(ID, pos, 0, 0);
}