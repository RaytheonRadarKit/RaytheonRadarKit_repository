// Revised by David Garcia 1/31/2025
// Fixed angle number display position for new format of serial input
// Restructered program to draw display before getting serial data
// Revised by Branden Levenson 7/13/2024
// Fixed the Serial Connection Process for boot 
// Revised by Michael Oravec 3/10/2023
// Changed 'target' color to yellow, added inches to Distance readout

int portNumber = 1;  // if the radar screen shows up but no lines or dots appear, change the value of portNumber to be 0, 1, or 2       
                     // if it's still broken, you may need to re-upload the Arduino script (open the Arduino file)

int correction = 0;  // correction for angle calibration based on ultrasonic sensor, off-angle setup

import processing.serial.*;        // imports library for serial communication
import java.awt.event.KeyEvent;    // imports library for reading the data from the serial port
import java.io.IOException; 

Serial myPort;                     // defines a Serial type object

String angle ="";                   // define variables
String distance ="";
String data ="";
String noObject ="";
String num_pings ="";
float pixsDistance;
int iAngle, iDistance, iNum_pings; 
int index0 =0;
int index1 =0;
int index2 =0;
int index3 =0;
int Tx, Ty;
int maxRange =100;            //  Range is currently limited to 100 cm  
                              //  Range rings, labels, and red/green lines need to be resized for each maximum range specified
float dispScale;

void setup() {                // Setup runs once on program start
  size (1366, 768);           // Defines the dimension of the display window width and height in units of pixels.
  dispScale = width/1920.0;   // This scales all graphics from 1920,1080 to max native width in 16:9 layout
  smooth();
  printArray(Serial.list());        
  try {                                            // Try function added to allow drawing of radar display without Arduino connected
    String portName = Serial.list()[portNumber];   // port should usually be [1], but if it doesn't work, try [0] and [2]
    myPort = new Serial(this, portName, 9600);     // starts the serial communication
    myPort.buffer(6);                              // reads 6 chars from the serial port then triggers serialEvent()
    System.out.println("Try done.");
     }
   catch(Exception e) {
   System.out.println("Serial Not Connected"); 
     }
 }

void draw() {                 // Draw runs forever until stopped
  fill(120, 45);              // First nunumber sets background color of PPI display.  The lower the number, the darker the background.  
                              // Second color sets the fading (with time) of the green strobes and red target dots.  
                              // The lower the value, the less the fading of the green strobes and red target dots.

  rect(0, 0, width, height);  // First two numbers set the size of the background rectangle whose color is controlled by fill command above.
                              // 0, 0 is full size; as these numbers increase the background rectangle becomes smaller.
                              // First number decreases width of background rectangle and the second number decreases height of the background rectangle.
  scale(dispScale);
  drawRadar();
  drawObject();
  drawLine();
  drawText();
 }                              
                                // The serial input format is variable length data triplets of angle, distance, num_pings
                                // The data is surrounded by punctuation as follows:  ":angle,distance;Num_Pings.[CR][LF]"
                                // [CR] and [LF] are invisible characters Carriage Return and Line Feed
                                
void serialEvent (Serial myPort) {                        // Triggered by "buffer" function                      
  data = myPort.readStringUntil('.');                     // Reads the data from the Serial Port buffer up to the character '.'
  System.out.println("data.length()= " + data.length());
  if (data.length()>10) {                                 
    System.out.println("data= " + data);
    index0 = data.indexOf(":");                           // find first intance of the character ':' and puts it into the variable "index0"
    index1 = data.indexOf(",");                           // find first intance of the character ',' and puts it into the variable "index1"
    index2 = data.indexOf(";");                           // find first intance of the character ';' and puts it into the variable "index2"
    index3 = data.indexOf(".");                           // find first intance of the character '.' and puts it into the variable "index3"
      System.out.println("index0= " + index0);
      System.out.println("index1= " + index1);
      System.out.println("index2= " + index2);
      System.out.println("index3= " + index3);
                                                         // [CR] and [LF] will usually be characters in positions 0 and 1
   angle = data.substring(index0+1 , index1);            // Get "angle" by reading data from char index0+1 to before index2
   distance = data.substring(index1+1, index2);          // Get "distance"
   num_pings = data.substring(index2+1, index3);         // Get "num_pings"
   System.out.println("angle= " + angle);
   System.out.println("distance= " + distance); 
   System.out.println("num_pings= " + num_pings); 
   System.out.println("data= " + data);
   
  iAngle = abs(int(angle)-180) + correction;             // Converts the String variables into Integer, adda correction if needed,
                                                         // Reverses angle to plot increasing angle clockwise
  iDistance =int(distance);
  iNum_pings =int(num_pings);
  }
}
void drawRadar() {

  pushMatrix();
  translate(960, 1000);          // moves the starting coordinats to new location
  noFill();
  strokeWeight(2);               //Controls thickness of arc lines and angle lines; higher number results in thicker lines
  stroke(98, 245, 31);           //Controls color of arc lines and angle lines

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
void keyPressed() {                                // clears screen of dots when mouse is clicked
    if (key == 'p' || key == 'P') {
  myPort.stop();
  }
  if (key == 's' || key == 'S') {
  myPort.stop();
  String portName = Serial.list()[portNumber];       // change the 0 to a 1 or 2 etc. to match your port                                                 // port should usually be [1], but if it doesn't work, try [0] and [2]
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('.');                           // reads the data from the serial port up to the character '.' then calls serialEvent()
}
 if (key == 'b'|| key =='B') {
  translate(960, 1000); 
  beginShape();
  vertex(0, 0); 
  
  for (int angle = 30; angle <= 150; angle += 1) {
    float x = -960 * cos(radians(angle));
    float y = -960 * sin(radians(angle)); 
    vertex(x, y); 
  }
  
  noFill();                                     // draws the arc lines
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
}
  endShape(); 
}

void drawObject() {
  pushMatrix();
  translate(960, 1000);           // moves the starting coordinats to new location
  strokeWeight(3);
  stroke(255, 255, 0);            // yellow color dots on strobe lines specifying distance of target or object
  fill(255, 255, 0);

  pixsDistance = iDistance*9;                    // 100 cm = 900 pixels

  if (iDistance<=maxRange && iDistance > 0) {         // limiting the range to maxRange
    Tx = int(pixsDistance*cos(radians(iAngle)));
    Ty = int(-pixsDistance*sin(radians(iAngle)));                     
    ellipse(Tx, Ty, 15, 15);                          // draws the target dot object according to the angle and the distance
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

void drawText() {          // Draws the serial input text information on the screen
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
  
  fill(0,0,180); //blue 
  text("To display beamwidth",1500, 155); 
  text("arc hold b",1510, 185); 

  fill(0, 500);
  rect(0, 0, 445, 220);
  fill(98, 245, 31);

  textSize(40);
  text("Object: ", 15, 50);
  text("        " + noObject, 65, 50);
  text("Angle: ", 15, 100);
  text("        " + angle +" °", 65, 100);
  text("Distance: ", 15, 150);
  text("Dist Avging: ", 15, 200);
  if ((iDistance > 0) & (iDistance<=maxRange)) {
    text("        " + iDistance +" cm/"+ int(iDistance/2.54)+" in", 100, 150);
    text("        " + iNum_pings +" pts", 242, 200);
      }

       // Label angle markers on display
       // Individual push and pop matrix's used instead of resetMatrix to allow rescale relative to 0,0 position

  fill(98, 245, 31);
  textSize(25);
  
  fill(0, 255, 0);
  rect(1500, 20, 350, 50);
  fill(0); 
  textSize(30);
  text("Click S twice to start", 1527, 55);
  
  fill(255, 0,0); 
  rect(1500, 80, 350, 50); 
  fill(0); 
  textSize(30); 
  text("Click P to pause", 1560, 115); 
  
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

}
