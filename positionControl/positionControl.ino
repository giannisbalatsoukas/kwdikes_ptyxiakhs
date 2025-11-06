#include <AccelStepper.h>
#include <SCServo.h>

SMS_STS st;

const int dirPin = 5;
const int stepPin = 6;
const int enblPin = 3;

float number = 0;
int ID = 0;
int steps = 0;

AccelStepper myStepper(AccelStepper::DRIVER, stepPin, dirPin);

void setup() {
   myStepper.setMaxSpeed(150.0); // steps per sec
   myStepper.setAcceleration(50); // steps per sec
   myStepper.setCurrentPosition(0);
    
   pinMode(enblPin, OUTPUT);
   digitalWrite(enblPin, LOW);

   Serial.begin(9600);
   Serial1.begin(1000000);
   st.pSerial = &Serial1;

   Serial.println("FOR STEPPER: 3 DISTANCE\nFOR 1ST SERVO: 1 ANGLE\nFRO 2ND SERVO: 2 ANGLE");
}

void loop() {

   if (Serial.available() > 0) {

    if(ID == 1 || ID == 2)
    {
      if(ID == 2 && number >= 0 && number <= 20) moveServoToAngle(ID, number);
      else if(ID == 1) moveServoToAngle(ID, number);
    }
    else if(ID == 3)
    {
      steps = (number * 200) / 0.8;

      if (steps != 0) {
        digitalWrite(enblPin, HIGH);
        myStepper.move(steps);
      }
    }
   }
   
    myStepper.run();
    //Serial.println(myStepper.speed());

    if (myStepper.distanceToGo() == 0) {
      digitalWrite(enblPin, LOW);
    }
}

int angleToPosition(int angle) {
  angle = constrain(angle, 0, 360);
  return map(angle, 0, 360, 0, 4095);
}

void moveServoToAngle(int ID, int angle) {
  int pos = angleToPosition(angle);

  st.WritePosEx(ID, pos, 1000, 100); 
}