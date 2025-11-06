#include <SCServo.h>
#include <AccelStepper.h>

SMS_STS st;

float number = 0;
int ID = 0;
int steps = 0;

const int dirPin = 6;
const int stepPin = 5;
const int enblPin = 3;

AccelStepper myStepper(AccelStepper::DRIVER, stepPin, dirPin);


void setup() {
  // put your setup code here, to run once:
  myStepper.setMaxSpeed(150.0); // steps per sec
   myStepper.setAcceleration(50); // steps per sec
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
    input.trim();

    // Example commands:
    // "1 45" → move servo 1 to 45°
    // "3 10" → move stepper 10mm
    // "cal 1" → make current servo 1 position new zero

    if (input.startsWith("cal")) {
      int id = input.substring(3).toInt();
      calibrateServo(id);
    } 
    else {
      int spaceIndex = input.indexOf(' ');
      if (spaceIndex > 0) {
        ID = input.substring(0, spaceIndex).toInt();
        number = input.substring(spaceIndex + 1).toFloat();

        if (ID == 1 || ID == 2) {
          moveServoToAngle(ID, number);
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
    }
  }

  myStepper.run();
    //Serial.println(myStepper.speed());

    if (myStepper.distanceToGo() == 0) {
      digitalWrite(enblPin, LOW);
    }
}

int angleToPosition(int angle) {
  //angle = constrain(angle, 0, 360);
  return map(angle, -180, 180, 0, 4095);
}

void moveServoToAngle(int ID, int angle) {
  int pos = angleToPosition(angle);

  st.WritePosEx(ID, pos, 1000, 100); 
}

void calibrateServo(int ID) {
  int result = st.CalibrationOfs(ID);
  if (result == 1) {
    Serial.print("✅ Servo ");
    Serial.print(ID);
    Serial.println(" calibrated: current position set as zero.");
  } else {
    Serial.print("⚠️ Calibration failed on servo ");
    Serial.print(ID);
    Serial.print(" (error code ");
    Serial.print(result);
    Serial.println(").");
  }
}