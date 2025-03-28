 This is a fun, beginner-friendly project that turns an Arduino into a mini radar system! 
 It uses a servo and an ultrasonic sensor to detect objects and displays them in real-time using a custom Processing interface.

**WHAT IT DOES**

- Sweeps side-to-side like a radar.
- Detects objects with an ultrasonic sensor (HC-SR04).
- Sends data to your computer.
- Shows distance and angle as dots on a radar screen (made in Processing).
- Includes cool effects like "beam width" and "jamming".

**WHAT IS NEEDED**

- Arduino Uno R3  
- HC-SR04 Ultrasonic Sensor  
- SG90 Servo Motor  
- Computer with [Processing IDE](https://processing.org/)  
- USB cable + jumper wires  

**WIRING**

**HC-SR04:** (Ultrasonic Sensor)
- VCC → 5V  
- GND → GND  
- Trig → Pin 10  
- Echo → Pin 11  

**Servo Motor** 
- VCC → 5V  
- GND → GND  
- Signal → Pin 12  

**HOW TO RUN IT** 

1. **Upload the Arduino Code**  
   - Use `Ultrasonic_Signal_Processing.ino`
   - Set `select = 3` in the loop for sweeping mode.

2. **Run the Processing Radar Display**  
   - Open `Radar_Display.pde` in Processing.
   - Press **S** to start and **P** to pause.
   - Watch your mini radar in action!

**MODES** 

Set the `select` variable in the Arduino sketch to choose a mode:

- `1` = Straight Ahead  
- `2` = Beam Width  
- `3` = Sweep Side-to-Side 
- `4` = Jammer Effect  
- `5` = Jammer Display


**FOR FURTHER INSTRUCTIONS AND EXPLANATIONS, SEE THE USER GUIDE**
