/*
Project: Smart City Lighting Control
Objective: To assist in efficient operation of street grid by automating street lights
            via localized light & motion tracking sensors.
*/


const int LDR_PIN = 34;      // Analog input pin for Light Sensor (AO)
const int PIR_PIN = 14;      // Digital input pin for Motion Sensor (D)
const int RELAY_PIN = 12;    // Digital output pin for driving the high-voltage light relay (IN)

const int NIGHT_THRESHOLD = 1500;   // Below this value is considered dark 
const unsigned long LIGHT_DELAY = 10000; // Keep light on for 10 seconds after motion stops

// State Tracking Variables
unsigned long lastMT = 0;     // Last Motion Time recorded, initially it's 'ZERO'
bool isLA = false;            // Light Array active status, initially it's 'FALSE'

void setup() {
 
  Serial.begin(115200);
  Serial.println("--- Smart City Project Initialized ---");


  pinMode(LDR_PIN, INPUT);
  pinMode(PIR_PIN, INPUT);
  pinMode(RELAY_PIN, OUTPUT);

  digitalWrite(RELAY_PIN, LOW);       // We want a safe start of HV light grid relay, so initial state 'LOW'
}

void loop() {
  
  int ambientLight = analogRead(LDR_PIN);
  int motionDetected = digitalRead(PIR_PIN);

  if (ambientLight > NIGHT_THRESHOLD) {
    // Phase A: It is dark out, scan for pedestrian/vehicle triggers
    if (motionDetected == HIGH) {
      lastMT = millis(); // Refreshs the active timer tracking frame
      
      if (!isLA) {
        Serial.println("[ALERT] Motion detected at night. Activating Grid Relay.");
        digitalWrite(RELAY_PIN, HIGH);
        isLA = true;
      }
    }

    // Phase B: Handle systematic grid turn OFF if area clears out
    if (isLA && (millis() - lastMT > LIGHT_DELAY)) {
      Serial.println("[INFO] Motion cleared. Deactivating Grid Relay to conserve power.");
      digitalWrite(RELAY_PIN, LOW);
      isLA = false;
    }
  } else {
    
    // Phase C: Daytime protection mechanism to prevent accidental drainage
    if (isLA) {
      Serial.println("[SYSTEM] Ambient light detected. Overriding grid safety to LOW state.");
      digitalWrite(RELAY_PIN, LOW);
      isLA = false;
    }
  }
  
  delay(200); 
}
