#include <AccelStepper.h>
#include <SCServo.h>

SMS_STS st;

const int dirPin = 6;
const int stepPin = 5;
const int enblPin = 3;

float number = 0;
int ID = 0;
int steps = 0;

AccelStepper myStepper(AccelStepper::DRIVER, stepPin, dirPin);

void setup() {
   myStepper.setMaxSpeed(1000.0); // steps per sec
   myStepper.setAcceleration(200); // steps per sec
   myStepper.setCurrentPosition(0);
    
   pinMode(enblPin, OUTPUT);
   digitalWrite(enblPin, LOW);

   Serial.begin(9600);
   Serial1.begin(1000000);
   st.pSerial = &Serial1;

}

void loop() {

   if (Serial.available() > 0) {
    String input = Serial.readStringUntil('\n');

        int space1 = input.indexOf(' ');
        int space2 = input.indexOf(' ', space1 + 1);

        if (space1 > 0) {
            ID = input.substring(0, space1).toInt();
            number = input.substring(space1 + 1).toFloat();
        }
    if(ID == 1 || ID == 2)
    {
      if(ID == 2 && number >= 0 && number <= 20) moveServoToAngle(ID, number);
      else if(ID == 1) moveServoToAngle(ID, number);
    }
    else if(ID == 3)
    {
      steps = (number*200) / 0.8;

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

//int angleToPosition(int angle) {
//  angle = constrain(angle, 0, 360);
//  return map(angle, 0, 360, 0, 4095);
//}

int angleToPosition(float angle) {
  angle = constrain(angle, -180, 180);
  return map(angle, -180, 180, 0, 4095);
}

void moveServoToAngle(int ID, float angle) {
  float pos = angleToPosition(angle);

  st.WritePosEx(ID, pos, 500, 100); 
}