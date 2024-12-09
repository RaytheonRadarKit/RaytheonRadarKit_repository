// File Name:   ICURadar.ino
// Description: Code used to control ICU Radar Class Demo
// Notes:       Modified from LibraryRadarDemo_arduino.ino
// Author:      Alan Wallingford
// Date:        July 8, 2021

// Ultrasonic SR04
#include <NewPing.h>
//Servo 
#include <Servo.h>

//Sensor Echo Pin
const int echo_pin = 11;
//Sensor Trigger Pin
const int trigger_pin = 10;

/**************************************************************/
/* VARIABLES TO CHANGE */
//Max sensing distance (cm) (SR04 has a max of 4m) 
const int max_distance = 100;
//# of samples the sonar will take at each position
const int num_of_pings = 1;
//Degrees per step of the servo. Recommended 2, 5, 10, but any factor of 120
const int steps = 5;
/**************************************************************/


//Speed of sound (m/s)
const int speed_of_sound = 340;
//Holder for return times for mean calculation
unsigned long buffer[num_of_pings];
// Holder for pulses per second
int prf = (speed_of_sound / (2 * max_distance / 100));
// Holder for number of nonzero readings
int nonzero = 0;

// Create a NewPing data type variable called sonar
NewPing sonar(trigger_pin, echo_pin, max_distance);

// Create a Servo type variable to control the sonar mounted servo
Servo myServo;

void setup() {
	// Begin serial communication at 9600 baud
	Serial.begin(9600);
	// Attach the servo to pin 12
	myServo.attach(12);
}

/*******************************************************************************************************/
/* CONTROL WHICH SECTION TO RUN HERE */
//Uncomment the section you want to run in loop and comment out the others // (Section1, Section2, or Section3)

void loop() {
	// Runs the function to be used in section1
        Section1();
	// Runs the function to be used in section2
        //Section2();
	// Runs the function to be used in section3
	//    Section3();
}
/*******************************************************************************************************/
// Calculate the distance to the target (cm)
int calcDistance() {
	//Holder for the sum of time measurements
	unsigned long time = 0;
	//Holder for the number of nonzero returns
	int count = 0;
	//Range (cm)
	int range_cm = 0;
    // Ping and retrieve response time, collect number of pings requested
	for (int i = 0; i < num_of_pings; i++) {
		buffer[i] = sonar.ping();
		time = time + buffer[i];
		if (buffer[i] > 0) {
			count++;
		}
	}
	// Make sure we aren't dividing by zero
	if (count > 0 ){
		// Calculate mean response time
		unsigned long mean_time = time / count; 
	
		/***********************************************************/
		/* LINE TO CHANGE IF NEEDED (Return Trip) */
		//If distance is incorrect
			
		// Convert from average response time to average range in cm
		range_cm = (mean_time * speed_of_sound  / (1 * 10000));
	}
	    /***********************************************************/
	// Define number of nonzero readings
	nonzero = count;
	// Return the range
	return range_cm;
}

void Section1() {
	// Keep servo at 90 degrees
    myServo.write(90);
    
	/****************************/
	/* LINE TO CHANGE IF NEEDED */
	// Delay in milliseconds so it doesn't run constantly
	delay(300);
	/****************************/
	
	// Retrieve the range to target
	int range = calcDistance();
	// Send data to Processing
	Serial.print(90);
	Serial.print(",");
	Serial.print(range);
	Serial.print(";");
	Serial.print(nonzero);
	// 	Serial.print(":");
	//	Serial.print(prf);
	Serial.print(".");
}

void Section2() {
	// Sweep from 30 degrees to 150 degrees in set steps
	for (int angle = 30; angle <= 150; angle += steps) {
		// Send servo to angle
		myServo.write(angle);
		// Delay to allow servo to get into position
		delay(150);
		// Delay to slow down the sensor noticibly with more pings
		delay(150*num_of_pings);
		// Retrieve the range to target
		int range = calcDistance();
		// Send data to Processing
		Serial.print(angle);
		Serial.print(",");
		Serial.print(range);
		Serial.print(";");
		Serial.print(nonzero);
		// 	Serial.print(":");
		//	Serial.print(prf);
		Serial.print(".");
	}
	// Sweep from 150 degrees to 30 degrees in set steps
	for (int angle = 150; angle >= 30; angle -= steps) {
		// Send servo to angle
		myServo.write(angle);
		// Delay to allow servo to get into position
		delay(150);
		// Delay to slow down the sensor noticibly with more pings
		delay(150*num_of_pings);
		// Retrieve the range to target
		int range = calcDistance();
		// Send data to Processing
		Serial.print(angle);
		Serial.print(",");
		Serial.print(range);
		Serial.print(";");
		Serial.print(nonzero);
		// 	Serial.print(":");
		//	Serial.print(prf);
		Serial.print(".");
	}
}

void Section3() {
	// Keep servo at 90 degrees
    myServo.write(90);
	// Delay in milliseconds so it doesn't run constantly
	delay(100);
	// Retrieve the range to target
	int range = calcDistance();
	// Send data to Processing
	Serial.print(90);
	Serial.print(",");
	Serial.print(range);
	Serial.print(";");
	Serial.print(nonzero);
//	Serial.print(":");
//	Serial.print(prf);
 	Serial.print(".");
}