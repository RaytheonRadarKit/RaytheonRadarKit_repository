//  File Name:    Ultrasonic_Signal_Processing.ino
//  Author:       David L. Garcia
//  Created:      1-Jan-2025
//
//  Revision:     1
//  Date:         30-Jan-2025
//  By:           David L. Garcia
//  Change:       Fixed Arduino-Uno-R3 pin-outs     
//
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
//  The serial data can be recieved by a RaspberryPi microprocessor board.
//  The RaspberryPi can generate a radar display on a HDMI monitor and display the data as dots on 
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
                                   //
#include <Servo.h>                 // library software for SG90 / MG995 / MG996R Servo Motors
#include <NewPing.h>               // library software for HC-SR04 Ultrasonic Sensor
                                   //
#define TRIGGER_PIN  10            // Arduino pin tied to trigger pin on the ultrasonic sensor
#define ECHO_PIN     11            // Arduino pin tied to echo pin on the ultrasonic sensor
#define DRIVE_PIN    12            // Arduino pin tied to drive pin on the servo
                                   //
const int Servo_Step = 10;         // Servo degrees per step, use factors of 120: 
                                   //  (2, 3, 5, 6, 8, 10, 12, 15, 20, 24, 40, 60)
const int Max_Distance = 100;      // Maximum distance we want to ping for (in centimeters)
                                   // The Radar_Display program is set for 100 cm max distance  
                                   // Maximum sensor distance of SR-04 is rated at 400-500cm
const int Num_Pings = 1;           // Number of pings per data triplet - fixed at 1 for now
const int UpsideDown = 0;          // Set to 180 degrees if servo is upside down, 0 otherwise
const long Speed_of_Sound = 34000; // Speed of sound in centimeters/second
int ping_target();                 // Fuction that pings target and returns distance in centimeters
                                                           // 
int Max_Pings = (Speed_of_Sound / (Max_Distance*2));       // Given distance how many pings possible                                 
                                                           //
NewPing ultrasonic(TRIGGER_PIN, ECHO_PIN, Max_Distance);   // Set up HC-SR04 Ultrasonic sensor
                                                           //
Servo myservo;                                             // Set up SG90 Servo 
                                                           //                    
                                         
void setup() {
  Serial.begin(9800);                  // Set Serial Port to 9800 baud to send ping results.
  myservo.attach(DRIVE_PIN);
  myservo.write(abs(90-UpsideDown));   // Test and position Servo to 90 degrees on startup.
  delay(500);                          // Delay in milliseconds to allow finish of movement
  myservo.write(abs(30-UpsideDown));   // Test and position Servo to 30 degrees on startup.
  delay(500);                     
  myservo.write(abs(150-UpsideDown));  // Test and position Servo to 150 degrees on startup.
  delay(500);                     
  myservo.write(90);
  delay(500); }
                                  //
    /***************************************/
    /* CONTROL WHICH OPERATION TO RUN HERE */
    /***************************************/
                                           //
void loop() {
  int select = 2;               // Set select = 1 for "straight ahead", "2" for scanning side to side
  switch (select) {
        case 1:
          straight_ahead();
          break;
        case 2:
          scan_side_to_side();
          break;
        case 3:
          straight_ahead();
          break;
        default:
          // scan_side_to_side();
          break; }
}   
                                         //
/********************************************************************************/
/*  The Radar_Display program expects the serial data triplets to be separated  */
/*  with chars ": , ; ." as follows:  ":angle ,distance ;Num_Pings."            */  

void straight_ahead() {
  myservo.write(abs(90-UpsideDown));  // Set servo to 90 degrees
  delay(200);                         // Delay in milliseconds to allow servo to move
  int distance = ping_target();       // Calculate the distance to target using the time of echo
  Serial.print(":");
  Serial.print(90);                   // Send data out of Serial Port
  Serial.print(",");
  Serial.print(distance);
  Serial.print(";");
  Serial.print(Num_Pings);  
  Serial.println(".");
}

void scan_side_to_side() {            		
  for (int angle=30; angle<=150; angle += Servo_Step) {  // Sweep from 30 to 150 degrees in steps		
  myservo.write(abs(angle-UpsideDown));                  // Send servo to angle
  delay(200);                                            // Delay to allow servo to move	
  int distance = ping_target();                          // Calculate the distance to target
  Serial.print(":");                                     // Send data out of Serial Port
  Serial.print(angle);                                   
  Serial.print(",");
  Serial.print(distance);
  Serial.print(";");
  Serial.print(Num_Pings);                               // Note that "println" adds 2 characters to
  Serial.println(".");	                                 // to the data output called: "CR" and "LF"        
  }
  for (int angle=150; angle>=30; angle -= Servo_Step) {  // Sweep from 150 to 30 degrees in steps		
  myservo.write(abs(angle-UpsideDown));                  // Send servo to angle
  delay(200);                                            // Delay to allow servo to move	
  int distance = ping_target();                          // Calculate the distance to target
  Serial.print(":");                                     // Send data out of Serial Port
  Serial.print(angle);                                   
  Serial.print(",");
  Serial.print(distance);
  Serial.print(";");
  Serial.print(Num_Pings);                               // Note that "println" adds 2 characters to
  Serial.println(".");	                                 // to the data output called: "CR" and "LF"  
  }		
}
                                                     //
int ping_target() {               
  int measured_distance = 0;                         // Calculate the distance to the target in cm
  unsigned long time = 0;    
  time = ultrasonic.ping();                          // Returns time in microseconds
  if (time > 0 ){                                    // Avoid dividing by zero
	
      /**********************************************************/
      /* LINE TO CHANGE IF NEEDED (Correct for Round Trip Time) */
      /**********************************************************/	
		                                                  //
    measured_distance = (time * Speed_of_Sound / (1 * 1000000));  // Echo time to distance in cm
  }                       
  return measured_distance;
}
