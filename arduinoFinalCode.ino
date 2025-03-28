//  File Name:    Ultrasonic_Signal_Processing.ino
//  Edited:       03/18/2025
//  Author:       David L. Garcia
//  Created:      1-Jan-2025
//
//  Revision:     1
//  Date:         30-Jan-2025
//  By:           David L. Garcia
//  Change:       Fixed Arduino-Uno-R3 pin-outs     
// ================================================================================================
//  This code is for free and unrestricted public use.
//
//  This file contains code to simulate radar operation with: 
//      Arduino-Uno-R3 microcontroller board, 
//      HC-SR04 Ultrasonic sensor,
//      SG90 Servo Motor (or MG995, or MG996R).
//      
//  Serial data triplets of distance, angle, and ping count will be sent to the Arduino Serial Port.
//
//  The serial data can be received by a RaspberryPi microprocessor board.
//  The RaspberryPi can generate a radar display on an HDMI monitor and display the data as dots on 
//  a screen at a distance and angle from the Ultrasonic sensor.
//
//  The Radar_Display program expects the serial data triplets to be separated with ": , ; ."
//   as follows:  :angle, distance; Num_Pings.  
//
//  Connection of HC-SR04 Ultrasonic sensor and SG90 Servo to Arduino Uno R3 is:
//
//      HC-SR04:                       Arduino Uno R3:          
//         VCC                --        5V  
//         GND                --        Gnd
//         Trig               --        10  (Digital)
//         Echo               --        11  (Digital) 
//
//        SG90:
//         5V                 --        5V      
//         GND                --        GND
//         Drive              --        12  (Digital)
//           
// =================================================================================================

#include <Servo.h>                 // Library for SG90 / MG995 / MG996R Servo Motors
#include <NewPing.h>               // Library for HC-SR04 Ultrasonic Sensor

#define TRIGGER_PIN  10            // Arduino pin tied to trigger pin on the ultrasonic sensor
#define ECHO_PIN     11            // Arduino pin tied to echo pin on the ultrasonic sensor
#define DRIVE_PIN    12            // Arduino pin tied to drive pin on the servo

const int servoStep = 5;           // Servo degrees per step (use factors of 120: 2, 3, 5, 6, 8, 10, 12, 15, 20, 24, 40, 60)
const int maxDistance = 100;       // Maximum distance we want to ping for (in centimeters)
const int numPings = 1;            // Number of pings per data triplet (fixed at 1 for now)
const int upsideDown = 0;          // Set to 180 degrees if the servo is upside down, 0 otherwise
int beam = 0;
int jam = 0;

const long speedOfSound = 34000;   // Speed of sound in centimeters/second
int pingTarget();                  // Function that pings the target and returns distance in centimeters

int maxPings = (speedOfSound / (maxDistance * 2)); // Given distance, how many pings are possible

NewPing ultrasonic(TRIGGER_PIN, ECHO_PIN, maxDistance); // Set up HC-SR04 Ultrasonic sensor
Servo myServo;                                            // Set up SG90 Servo

void setup() {
  Serial.begin(9600);                // Set Serial Port to 9600 baud to send ping results.
  myServo.attach(DRIVE_PIN);         // Attach the servo to the specified pin
  myServo.write(abs(90 - upsideDown)); // Test and position Servo to 90 degrees on startup.
  delay(500);                        // Delay to allow finish of movement
  myServo.write(abs(30 - upsideDown)); // Test and position Servo to 30 degrees on startup.
  delay(500);                     
  myServo.write(abs(150 - upsideDown)); // Test and position Servo to 150 degrees on startup.
  delay(500);                     
  myServo.write(90);                 // Position servo back to 90 degrees
  delay(500);
}

/**************************************/
/* CONTROL WHICH OPERATION TO RUN HERE */
/**************************************/

void loop() {
  int select = 4;   // Set select = 1 for "straight ahead", 2 for "Beam Width", 3 for "Scan-Side-to-Side", 4 for "Jammer", 5 for "Jammer display"
  switch (select) {
    case 1:
      straightAhead();
      break;
    case 2:
      beamWidth();
      break;
    case 3:
      scanSideToSide();
      break;
    case 4:
      jammer();
      break;
    case 5: 
      jammerDisplay(); 
      break;
    default:
      // scanSideToSide();
      break;
  }
}

/********************************************************************************/
/*  The Radar_Display program expects the serial data triplets to be separated  */
/*  with chars ": , ; _ /." as follows:  "angle,distance;beam_Jammer/numPings."            */  

void straightAhead() {
  myServo.write(abs(90 - upsideDown));  // Set servo to 90 degrees
  delay(200);                         // Delay to allow servo to move
  int distance = pingTarget();         // Calculate the distance to target using the time of echo
  Serial.print(":");
  Serial.print(90);                    // Send data out of Serial Port
  Serial.print(",");
  Serial.print(distance);
  Serial.print(";");
  Serial.print(0);  
  Serial.println("_");
  Serial.print(0);
  Serial.print("/");
  Serial.print(numPings);  
  Serial.println(".");
}

void beamWidth() {
  myServo.write(abs(90 - upsideDown));  // Set servo to 90 degrees
  delay(200);                         // Delay to allow servo to move
  int distance = pingTarget();         // Calculate the distance to target using the time of echo
  Serial.print(":");
  Serial.print(90);                    // Send data out of Serial Port
  Serial.print(",");
  Serial.print(distance);
  Serial.print(";");
  Serial.print(1);  
  Serial.println("_");
  Serial.print(0);
  Serial.print("/");
  Serial.print(numPings);  
  Serial.println(".");
}

void scanSideToSide() {  // Sweep from 30 to 150 degrees
  for (int angle = 30; angle <= 150; angle += servoStep) {
    myServo.write(abs(angle - upsideDown)); // Send servo to angle
    delay(200);                             // Delay to allow servo to move
    int distance = pingTarget();            // Calculate the distance to target
    Serial.print(":");
    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(";");
    Serial.print(0);  
    Serial.println("_");
    Serial.print(0);
    Serial.print("/");
    Serial.print(numPings);  
    Serial.println(".");
  }

  for (int angle = 150; angle >= 30; angle -= servoStep) {  // Sweep from 150 to 30 degrees
    myServo.write(abs(angle - upsideDown));                  // Send servo to angle
    delay(200);                                              // Delay to allow servo to move
    int distance = pingTarget();                              // Calculate the distance to target
    Serial.print(":");
    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(";");
    Serial.print(0);  
    Serial.println("_");
    Serial.print(0);
    Serial.print("/");
    Serial.print(numPings);  
    Serial.println(".");
  }
}

void jammer() {  // Sweep from 30 to 150 degrees
  for (int angle = 30; angle <= 150; angle += servoStep) {
    myServo.write(abs(angle - upsideDown)); // Send servo to angle
    delay(100);                             // Delay to allow servo to move
    int distance = pingTarget();            // Calculate the distance to target
    Serial.print(":");
    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(";");
    Serial.print(0);  
    Serial.println("_");
    Serial.print(0);
    Serial.print("/");
    Serial.print(numPings);  
    Serial.println(".");
  }

  for (int angle = 150; angle >= 30; angle -= servoStep) {  // Sweep from 150 to 30 degrees
    myServo.write(abs(angle - upsideDown));                  // Send servo to angle
    delay(100);                                              // Delay to allow servo to move
    int distance = pingTarget();                              // Calculate the distance to target
    Serial.print(":");
    Serial.print(angle);
    Serial.print(",");
    Serial.print(distance);
    Serial.print(";");
    Serial.print(0);  
    Serial.println("_");
    Serial.print(0);
    Serial.print("/");
    Serial.print(numPings);  
    Serial.println(".");
  }
}

void jammerDisplay() {
  myServo.write(abs(90 - upsideDown));  // Set servo to 90 degrees
  delay(200);                           // Delay to allow servo to move
  int distance = pingTarget();           // Calculate the distance to target using the time of echo
  Serial.print(":");
  Serial.print(90);                      // Send data out of Serial Port
  Serial.print(",");
  Serial.print(distance);
  Serial.print(";");
  Serial.print(0);  
  Serial.println("_");
  Serial.print(1);
  Serial.print("/");
  Serial.print(numPings);  
  Serial.println(".");
}

int pingTarget() {  // Calculate the distance to the target in cm
  int measuredDistance = 0;
  unsigned long time = ultrasonic.ping();  // Returns time in microseconds
  if (time > 0) {  // Avoid dividing by zero
    // Line to change if needed (correct for round trip time)
    measuredDistance = (time * speedOfSound / (2 * 1000000));  // Echo time to distance in cm
  }
  return measuredDistance;
}
