// File Name:   ICURadar.ino
// Description: Code used to control ICU Radar Class Demo
// Notes:       Modified from LibraryRadarDemo_arduino.ino
// Author:      Alan Wallingford
// Date:        July 8, 2021

// Include support for SR04
#include <NewPing.h>
// Include support for hobby servos
#include <Servo.h>

// Define the Sensor Echo Pin
const int echo_pin = 11;
// Define the Sensor Trigger Pin
const int trigger_pin = 10;

/***********************/
/* VARIABLES TO CHANGE */
/***********************/
// Define the max distance to sense in cm (SR04 has a max of 4m) 
const int max_distance = 100;
// Define the number of samples the sonar will take at each position
const int num_of_pings = 1;
// Define the degrees per step of the servo. Radarecommend 2, 5, 10, but any factor of 120 should work
const int resolution = 5;
// Define the speed of sound in m/s
const int speed_of_sound = 340;

// Variable to hold the return times for mean calculation
unsigned long buffer[num_of_pings];
// Variable to hold pulses per second
int prf = (speed_of_sound / (2 * max_distance / 100));
// Variable to hold number of nonzero readings
int nonzero = 0;

// Create a NewPing data type variable called sonar
NewPing sonar(trigger_pin, echo_pin, max_distance);

// Create a Servo type variable to control the sonor mounted servo
Servo myServo;

void setup() {
	// Begin serial communication at 9600 baud
	Serial.begin(9600);
	// Attach the servo to pin 12
	myServo.attach(12);
}

/*************************************/
/* CONTROL WHICH SECTION TO RUN HERE */
/*************************************/
void loop() {
	// Runs the function to be used in sections 1 and 2. Make sure the two functions below are commented
        section1and2();
	// Runs the function to be used in sections 3. Make sure the functions above and below are commented
        //section3();
	// Runs the function to be used in sections 4. Make sure the two functions above are commented
//    section4();
}

// Calculate the distance to the target in cm
int calcDistance() {
	// Variable to hold the sum of time measurements
	unsigned long time = 0;
	// Variable to hold the number of nonzero returns
	int count = 0;
	// Variable to hold the range in cm
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
	
		/******************************************/
		/* LINE TO CHANGE IF NEEDED (Return Trip) */
		/******************************************/	
		// Convert from average response time to average range in cm
		range_cm = (mean_time * speed_of_sound  / (1 * 10000));
	}
	// Define number of nonzero readings
	nonzero = count;
	// Return the range
	return range_cm;
}

void section1and2() {
	// Keep servo at 90 degrees
    myServo.write(90);
    
	/****************************/
	/* LINE TO CHANGE IF NEEDED */
	/****************************/
	// Delay in milliseconds so it doesn't run constantly
	delay(300);

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

void section3() {
	// Sweep from 30 degrees to 150 degrees in set steps
	for (int angle = 30; angle <= 150; angle += resolution) {
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
	for (int angle = 150; angle >= 30; angle -= resolution) {
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

void section4() {
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
