// File Name:   Jammer.ino
// Description: Code used to control the Jammer
// Notes:       Modified from jammer.ino
// Author:      Alan Wallingford
// Date:        May 20, 2021

// Include support for SR04
#include <NewPing.h>

// Define the sensor trigger pin
const int trigger_pin = 10;
// Define the sensor echo pin
const int echo_pin = 11;
// Define the max distance the sensor is checking for to 1cm
// unsure if setting to 0cm would be problematic
const int max_distance = 1;

// Create a NewPing data type variable called sonar to control SR04
NewPing sonar(trigger_pin, echo_pin, max_distance);

void setup() {

}

void loop() {
    sonar.ping();
}
