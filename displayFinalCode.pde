// Edited 3/18/2025
// Revised by David Garcia 1/31/2025
// Fixed angle number display position for new format of serial input
// Restructered program to draw display before getting serial data
// Revised by Branden Levenson 7/13/2024
// Fixed the Serial Connection Process for boot 
// Revised by Michael Oravec 3/10/2023
// Changed 'target' color to yellow, added inches to Distance readout

int portNumber;  

int correction = 0;                                             // correction for angle calibration based on ultrasonic sensor, off-angle setup

import processing.serial.*;                                     // imports library for serial communication
import java.awt.event.KeyEvent;                                 // imports library for reading the data from the serial port
import java.io.IOException; 

Serial myPort;                                                 // defines a Serial type object

String angle ="";                                             // define variables
String distance ="";
String data ="";
String noObject ="";
String num_pings ="";
String Beam = "";
String Jam = ""; 
float pixsDistance;
int iAngle, iDistance, iNum_pings, iBeam, iJam; 
int index0 =0;                                                
int index1 =0;
int index2 =0;
int index3 =0;
int index4 =0;
int index5 =0;
int Tx, Ty;
int maxRange =100;                                           //  Range is currently limited to 100 cm  
//  Range rings, labels, and red/green lines need to be resized for each maximum range specified
float dispScale;

void setup() {                                              // Setup runs once on program start
  size (1366, 768);                                         // Defines the dimension of the display window width and height in units of pixels.
  dispScale = width/1920.0;                                 // This scales all graphics from 1920,1080 to max native width in 16:9 layout
  smooth();
  String[] check= Serial.list();
  for (portNumber=0; portNumber<check.length; portNumber++) {
    if (check[portNumber].contains("ttyUSB")|| check[portNumber].contains("ttyACM")|| check[portNumber].contains("Serial")){
      String portName = Serial.list()[portNumber];           // port tries
      myPort = new Serial(this, portName, 9600);             // starts the serial communication
      myPort.buffer('.');                                    // reads chars until '.' from the serial port then triggers serialEvent()
      System.out.println("Connected ->"+portName);
      break; 
    }
  }
}

void draw() {                                             // Draw runs forever until stopped
  fill(15, 45);                                           // First nunumber sets background color of PPI display.  The lower the number, the darker the background.  
  // Second color sets the fading (with time) of the green strobes and red target dots.  
  // The lower the value, the less the fading of the green strobes and red target dots.

  rect(0, 0, width, height);                              // First two numbers set the size of the background rectangle whose color is controlled by fill command above.
  // 0, 0 is full size; as these numbers increase the background rectangle becomes smaller.
  // First number decreases width of background rectangle and the second number decreases height of the background rectangle.
  scale(dispScale);
  drawRadar();
  drawObject();
  drawLine();
  drawText();
}                              
// The serial input format is variable length data triplets of angle, distance, num_pings
// The data is surrounded by punctuation as follows:  ":angle,distance;beam_Jammer/Num_Pings.[CR][LF]"
// [CR] and [LF] are invisible characters Carriage Return and Line Feed

void serialEvent (Serial myPort) {                        // Triggered by "buffer" function                      
  data = myPort.readStringUntil('.');                     // Reads the data from the Serial Port buffer up to the character '.'                             
  index0 = data.indexOf(":");                             // find first intance of the character ':' and puts it into the variable "index0"
  index1 = data.indexOf(",");                             // find first intance of the character ',' and puts it into the variable "index1"
  index2 = data.indexOf(";");                             // find first intance of the character ';' and puts it into the variable "index2"
  index3 = data.indexOf("_");                             // find first intance of the character '_' and puts it into the variable "index3"
  index4 = data.indexOf("/");                             // find first intance of the character '/' and puts it into the variable "index4"
  index5 = data.indexOf(".");                             // find first intance of the character '.' and puts it into the variable "index5"

  // [CR] and [LF] will usually be characters in positions 0 and 1
  angle = data.substring(index0+1, index1);            // Get "angle" by reading data from char index0+1 to before index2
  distance = data.substring(index1+1, index2);          // Get "distance"
  Beam = data.substring(index2+1, index3);              // Get beam
  Jam = data.substring(index3+1, index4);               // Get Jammer
  num_pings = data.substring(index4+1, index5);         // Get "num_pings"
  iAngle = abs(int(angle)-180) + correction;             // Converts the String variables into Integer, add a correction if needed,
                                                        // Reverses angle to plot increasing angle clockwise
  iDistance =int(distance);
  iNum_pings =int(num_pings);
  iBeam= int(Beam);                                     //beam width
  Jam=trim(Jam); 
  iJam= int(Jam);                                        //jammer
} 

void drawRadar() {

  pushMatrix();
  translate(960, 1000);                                 // moves the starting coordinats to new location
  noFill();
  strokeWeight(2);                                     //Controls thickness of arc lines and angle lines; higher number results in thicker lines
  stroke(98, 245, 31);                                 //Controls color of arc lines and angle lines

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

void keyPressed() {                                
    if (key == 'p' || key == 'P') {
      myPort.stop();  
      System.out.println("Paused");
    }  
    if (key == 's' || key == 'S') {
      for (int i=0; i<3; i++){
        myPort.stop();
        String portName = Serial.list()[portNumber]; 
        myPort = new Serial(this, portName, 9600);
        myPort.bufferUntil('.');                           // reads the data from the serial port up to the character '.' then calls serialEvent()
      }
      System.out.println("Started");
    }
}

void drawObject() {
  pushMatrix();
  translate(960, 1000);                             // moves the starting coordinats to new location
  strokeWeight(3);
  stroke(255, 255, 0);                             // yellow color dots on strobe lines specifying distance of target or object
  fill(255, 255, 0);

  pixsDistance = iDistance*9;                     // 100 cm = 900 pixels

  if (iDistance<=maxRange && iDistance > 0) {     // limiting the range to maxRange
    Tx = int(pixsDistance*cos(radians(iAngle)));
    Ty = int(-pixsDistance*sin(radians(iAngle)));                     
    ellipse(Tx, Ty, 15, 15);                     // draws the target dot object according to the angle and the distance
  }

  popMatrix();
}


void drawLine() {
  pushMatrix();
  strokeWeight(2);
  stroke(30, 250, 60);
  translate(960, 1000);                                               // moves the starting coordinats to new location
  line(0, 0, 950*cos(radians(iAngle)), -950*sin(radians(iAngle)));    // draws the line according to the angle
  popMatrix();
}

void drawText() {                                                    // Draws the serial input text information on the screen
  pushMatrix();

  if (iDistance <= maxRange && iDistance > 0) {
    noObject = "In Range";
  } else {
    noObject = "Out of Range";
  }
  fill(98, 245, 31);
  textSize(25);
  text("25cm", 1105, 990);
  text("50cm", 1330, 990);
  text("75cm", 1555, 990);
  text("100cm", 1750, 990);

  fill(0, 500);
  rect(0, 0, 438, 170);
  fill(98, 245, 31);

  textSize(35);
  text("Object: ", 15, 50);
  text("        " + noObject, 65, 50);
  text("Angle: ", 15, 100);
  text("        " + angle +" °", 65, 100);
  text("Distance: ", 15, 150);

  if ((iDistance > 0) & (iDistance<=maxRange)) {
    text("        " + iDistance +" cm/"+ int(iDistance/2.54)+" in", 100, 150);
  }

  // Label angle markers on display
  // Individual push and pop matrix's used instead of resetMatrix to allow rescale relative to 0,0 position

  fill(98, 245, 31);
  textSize(25);
  popMatrix(); 

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

  pushMatrix(); 
  fill(0, 255, 0);
  rect(1566, 0, 350, 50);                                         //green rectangle
  fill(0); 
  textSize(30);
  text("Click S to start", 1641, 35);

  fill(255, 0, 0); 
  rect(1566, 60, 350, 50);                                        //red rectangle
  fill(0); 
  textSize(30); 
  text("Click P to pause", 1638, 95); 
  popMatrix(); 


  //beam width drawing 
  if (iBeam > 0) {                                                
    translate(960, 1000); 
    beginShape();
    vertex(0, 0); 

    for (int angle = 75; angle <= 105; angle += 1) {
      stroke(180, 180, 180);
      float x = -960 * cos(radians(angle));
      float y = -960 * sin(radians(angle)); 
      line(0, 0, -960*cos(radians(105)), -960*sin(radians(105)));
      vertex(x, y);
    }
  }
  noFill();                               
  endShape();
  //Jamming Display
  if (iJam > 0) { 
    beginShape();
    translate(75, 0);
    size (1366, 768);
    for (int i = 0; i < 1800; i++) {  
      float x = random(width*10);  
      float y = random(height*10); 
      stroke(255, 255, 0, 1000000);                               //yellow
      strokeWeight(20);                                            //size
      point(x, y);                                                  //dots
    }
    // additional noise for display
    /*for (int z = 0; z < 100; z++) { 
      float x1 = random(width*10);  
      float y1 = random(height*10); 
      stroke(255, 255, 0, 1000000); 
      strokeWeight(10);                                              //size
      vertex(x1, y1);                                                //Lines
    } */
    noFill();
    endShape();
  }
}
