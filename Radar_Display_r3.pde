// Revised by David Garcia 1/27/2025
// Fixed angle number display position
// Revised by Michael Oravec 3/10/2023
// Changed 'target' color to yellow, added inches to Distance readout
// Revised by Branden Levenson 7/13/2024
// Fixed the Serial Connection Process for boot 

// if the radar screen shows up but no lines or dots appear, change the value of portNumber to be 0, 1, or 2
int portNumber = 1;

//if it's still broken, you may need to reupload the Arduino script (open the Arduino file)

// correction for angle calibration based on bistatic sonar, off-angle setup
int correction = 0;

import processing.serial.*; // imports library for serial communication
import java.awt.event.KeyEvent; // imports library for reading the data from the serial port
import java.io.IOException; 

Serial myPort; // defines Object Serial

// define variables
String angle="";
String distance="";
String data="";
String noObject;
String num_of_pings="";
float pixsDistance;
int iAngle, iDistance, iNum_of_pings; 
int index1=0;
int index2=0;
int Tx, Ty;

int maxRange=100;  //  range is currently limited to 100 cm,  Range rings, labels, and red/green lines need to be resized for each maximum range specified.

float dispScale;
void setup() {
   size (1366, 768); //   Defines the dimension of the display window width and height in units of pixels.
   dispScale = width/1920.0;  //  This scales all graphics from 1920,1080 to max native width in 16:9 layout
   smooth();
   
   // System.out.println("angle= " + angle);
   // System.out.println("distance= " + distance); 
   // System.out.println("num_of_pings= " + num_of_pings); 
   
  //Serial Connection Processing
  try {
   //myPort = new Serial(this, "/dev/ttyACM0", 9600); // starts the serial communication
   String portName = Serial.list()[portNumber]; // change the 0 to a 1 or 2 etc. to match your port
   // port should usually be [1], but if it doesn't work, try [0] and [2]
   myPort = new Serial(this, portName, 9600);
   myPort.bufferUntil('.'); // reads the data from the serial port up to the character '.'. So actually it reads this: angle, distance, countmax.
   System.out.println("myPort.buffer= ");
   }
  catch(Exception e) {
   System.out.println("Serial Not Connected"); 
   }
}

void draw() {
  fill(120, 45); //First number sets background color of PPI display.  The lower the number, the darker the background.  
  //Second color sets the fading (with time) of the green strobes and red target dots.  The lower the value, the less the fading of the green strobes and red target dots.

  rect(0, 0, width, height); //First two numbers set the size of the background rectangle whose color is controlled by fill command above.  0, 0 is full size; as these numbers increase the background rectangle becomes smaller.
  // First number decreases width of background rectangle and the second number decreases height of the background rectangle.

  scale(dispScale);
  drawRadar();
  drawObject();
  drawLine();
  drawText();
}

void serialEvent (Serial myPort) { // starts reading data from the Serial Port
  // reads the data from the Serial Port up to the character '.' and puts it into the String variable "data".
  data = myPort.readStringUntil('.');
  if (data.length()>6) { // seems that increasing the min length makes freezing on startup less and less likely
  data = data.substring(0, data.length()-1);

  index1 = data.indexOf(","); // find the character ',' and puts it into the variable "index1"
  index2 = data.indexOf(";"); // find the character ';' and puts it into the variable "index2"
  System.out.println("index1= " + index1);
  System.out.println("index2= " + index2);
  angle = data.substring(3, index1); // (See next comment) read the data from position "0" to position of the variable index1; data is the value of the angle the Arduino Board sent into the Serial Port
                                     // change to read the data from position "2" to eliminate the "carriage/linefeed" characters
  distance = data.substring(index1+1, index2); // read the data from position "index1" to position of variable index2; data is the value of the average distance measured and calculated
  num_of_pings = data.substring(index2+1, data.length()); // read the data from position "index2" to the end of the data; data is the value of the variable countmax

   System.out.println("angle= " + angle);
   System.out.println("distance= " + distance); 
   System.out.println("num_of_pings= " + num_of_pings); 
    System.out.println("data= " + data);
   
  // converts the String variables into Integer

  iAngle = int(angle) + correction;
  iDistance =int(distance);
  //iDistance = (iDistance + 3); //correction for average range error from 10/15/20/25/30/35 cm measured target + 4/4/6/10/9/10 displayed 
  // It appears that there is a non-linear ranging (time) error in the Arduino.  This may clear up at greater ranges,  The code can be modified to obtain up to a 4M range.
  iNum_of_pings =int(num_of_pings);
  }
}

void mouseClicked() { // clears screen of dots when mouse is clicked
  myPort.stop();
  String portName = Serial.list()[portNumber]; // change the 0 to a 1 or 2 etc. to match your port
  // port should usually be [1], but if it doesn't work, try [0] and [2]
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('.'); // reads the data from the serial port up to the character '.'. So actually it reads this: angle, distance, countmax.
}

void drawRadar() {

  pushMatrix();
  translate(960, 1000); // moves the starting coordinats to new location
  noFill();
  strokeWeight(2); //Controls thickness of arc lines and angle lines; higher number results in thicker lines
  stroke(98, 245, 31); //Controls color of arc lines and angle lines

  // draws the arc lines
  arc(0, 0, 1800, 1800, PI, TWO_PI);
  arc(0, 0, 1350, 1350, PI, TWO_PI); 
  arc(0, 0, 900, 900, PI, TWO_PI);
  arc(0, 0, 450, 450, PI, TWO_PI);

  // draws the angle lines

  line(-960, 0, 960, 0);
  line(0, 0, -960*cos(radians(30)), -960*sin(radians(30)));
  line(0, 0, -960*cos(radians(60)), -960*sin(radians(60)));
  line(0, 0, -960*cos(radians(90)), -960*sin(radians(90)));
  line(0, 0, -960*cos(radians(120)), -960*sin(radians(120)));
  line(0, 0, -960*cos(radians(150)), -960*sin(radians(150)));
  line(-960*cos(radians(30)), 0, 960, 0);
  popMatrix();
}

void drawObject() {

  pushMatrix();
  translate(960, 1000); // moves the starting coordinats to new location
  strokeWeight(3);
  stroke(255, 255, 0); // red color dots on strobe lines specifying distance of target or object
  fill(255, 255, 0);

  pixsDistance = iDistance*9; // 100 cm = 900 pixels

  // limiting the range to maxRange
  if (iDistance<=maxRange && iDistance > 0) {
    Tx = int(pixsDistance*cos(radians(iAngle)));
    Ty = int(-pixsDistance*sin(radians(iAngle)));

    // draws the object according to the angle and the distance
    ellipse(Tx, Ty, 15, 15);
  }
  popMatrix();
}

void drawLine() {
  pushMatrix();
  strokeWeight(2);
  stroke(30, 250, 60);
  translate(960, 1000); // moves the starting coordinats to new location
  line(0, 0, 950*cos(radians(iAngle)), -950*sin(radians(iAngle))); // draws the line according to the angle
  popMatrix();
}

void drawText() { // draws the texts on the screen
  pushMatrix();

  if (iDistance <= maxRange && iDistance > 0) {
    noObject = "In Range";
  } else {
    noObject = "Out of Range";
  }

  //fill(0,0,0);
  //fill(200,100);
  //noStroke();
  //rect(0, 1010, width, 1080);
  //rect(0, 0, 1920, 1080);

  fill(98, 245, 31);
  textSize(25);
  text("25cm", 1105, 990);
  text("50cm", 1330, 990);
  text("75cm", 1555, 990);
  text("100cm", 1750, 990);

  fill(0, 500);
  rect(0, 0, 445, 220);
  fill(98, 245, 31);

  textSize(40);
  //text("Object: " + noObject, 15, 50); //Original command
  text("Object: ", 15, 50);
  text("        " + noObject, 65, 50);
  //text("Angle: " + iAngle +" °", 15, 100); //Original command
  text("Angle: ", 15, 100);
  text("        " + angle +" °", 65, 100);
  //fill(98,245,31);
  //fill(0,500);
  //fill(98,245,31);
  text("Distance: ", 15, 150);
  //text("Distancetotal: ", 15, 200);
  text("Dist Avging: ", 15, 200);
  //fill(98,245,31);
  //fill(90,245,31,100);
  if ((iDistance > 0) & (iDistance<=maxRange)) {
    //noStroke();
    //fill(98,245,31);
    //fill(0,100);
    //fill(98,245,31);
    text("        " + iDistance +" cm/"+ int(iDistance/2.54)+" in", 100, 150);
    //text("        " + iDistancetotal +" cm", 190, 200);
    text("        " + iNum_of_pings +" pts", 242, 200);
  }

  // add angle text to display, individual push and pop matrix's used instead of resetMatrix to allow rescale relative to 0,0 position

  fill(98, 245, 31);
  textSize(25);
  //fill(98,245,60);

  pushMatrix();
  translate(961+960*cos(radians(30)), 982-960*sin(radians(30)));
  rotate(-radians(-60));
  text("150°", 0, 0);
  popMatrix();  // e.g. was resetMatrix(); here

  pushMatrix();
  translate(954+960*cos(radians(60)), 984-960*sin(radians(60)));
  rotate(-radians(-30));
  text("120°", 0, 0);
  popMatrix();

  pushMatrix();
  translate(945+960*cos(radians(90)), 990-960*sin(radians(90)));
  rotate(radians(0));
  text("90°", 0, 0);
  popMatrix();

  pushMatrix();
  translate(935+960*cos(radians(120)), 1003-960*sin(radians(120)));
  rotate(radians(-30));
  text("60°", 0, 0);
  popMatrix();

  pushMatrix();
  translate(940+960*cos(radians(150)), 1018-960*sin(radians(150)));
  rotate(radians(-60));
  text("30°", 0, 0);
  popMatrix();

  popMatrix();
}
