/**
  Project: Sustainable Smart Agro Irrigation system
  Objective: Upload climate & soil data via Telemetry node to Adafruit IO Cloud
              and control remote irrigation overrides.
 */

// Libraries required
#include <WiFi.h>
#include <Adafruit_MQTT.h>
#include <Adafruit_MQTT_Client.h>
#include <DHT.h>

// Pin Declarations
const int DHT_PIN = 4;                  // Digital input from DHT22 sensor (climate temp. & humidity)
const int SOIL_MOISTURE_PIN = 32;       // Analog input from Hygrometer (soil moisture sensor)
const int VALVE_RELAY_PIN = 13;         // Digital output to Relay Module (water valve actuator)
#define DHTTYPE DHT22 
DHT dht(DHT_PIN, DHTTYPE);

// Wokwi Simulation Wi-Fi Credentials
const char* WLAN_SSID = "Wokwi-GUEST"; // Wokwi's default virtual network
const char* WLAN_PASS = "";            // No password required in Wokwi

// Cloud Platform Credentials (Adafruit IO)
#define AIO_SERVER      "io.adafruit.com"
#define AIO_SERVERPORT  1883
#define AIO_USERNAME    "SkxxID_26$39*5"        // Obtained from my personal account in adafruit.com/io/feed, but this is not my real username. you should use yours
#define AIO_KEY         "aio_5eWGjWPRXf1fHkJPpyHGYO"      

// MQTT Client & Feed Setup
WiFiClient client;
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT,"Wokwi_ESP32_AgriNode", AIO_USERNAME, AIO_KEY);

// Publishing data to cloud
Adafruit_MQTT_Publish temp_feed = Adafruit_MQTT_Publish(&mqtt, "SkxxID_26$39*5/feeds/temperature");
Adafruit_MQTT_Publish hum_feed = Adafruit_MQTT_Publish(&mqtt,  "SkxxID_26$39*5/feeds/humidity");
Adafruit_MQTT_Publish soil_feed = Adafruit_MQTT_Publish(&mqtt, "SkxxID_26$39*5/feeds/soil-moisture");

// Thresholds & Timing
const int DRY_SOIL_THRESHOLD = 1500;            // Higher than 1500 means soil is dry
const unsigned long TELEMETRY_INTERVAL = 5000; // Increased to 5s for stable cloud uploads
unsigned long lastTelemetryTime = 0;

// Function to estabilish MQTT connection
void MQTT_connect();

void setup() {
  Serial.begin(115200);
  delay(10);
  Serial.println("\n--- IoT Smart Agriculture Node Initialized ---");

  dht.begin();
  pinMode(SOIL_MOISTURE_PIN, INPUT);
  pinMode(VALVE_RELAY_PIN, OUTPUT);
  digitalWrite(VALVE_RELAY_PIN, LOW); 

  // Connect to Wokwi Virtual Wi-Fi
  Serial.print("Connecting to Wi-Fi Network: ");
  Serial.println(WLAN_SSID);
  WiFi.begin(WLAN_SSID, WLAN_PASS);
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWi-Fi Connected successfully!");
  Serial.print("IP Address allocated: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  // Ensures that we are connected to MQTT broker before running loop logic
  MQTT_connect();

  unsigned long currentMillis = millis();
  if (currentMillis - lastTelemetryTime >= TELEMETRY_INTERVAL) {
    lastTelemetryTime = currentMillis; 

    // Read localized environmental variables
    float humidity = dht.readHumidity();
    float temperature = dht.readTemperature();
    int soilMoistureRaw = analogRead(SOIL_MOISTURE_PIN); 

    if (isnan(humidity) || isnan(temperature)) {
      Serial.println("[ERROR] Failed to read from DHT22 array.");
      return; 
    }

    // Local Automation Logic
    bool valveActive = false;
    if (soilMoistureRaw > DRY_SOIL_THRESHOLD) {
      digitalWrite(VALVE_RELAY_PIN, HIGH); 
      valveActive = true;
    } else {
      digitalWrite(VALVE_RELAY_PIN, LOW); 
      valveActive = false;
    }

    // Local Data Printing
    Serial.println("\n>>> PUSHING DATA TO CLOUD <<<");
    Serial.print("Temp: "); Serial.print(temperature); Serial.println("C");
    Serial.print("Humidity: "); Serial.print(humidity); Serial.println("%");
    Serial.print("Soil Index: "); Serial.println(soilMoistureRaw);

    // IoT Transmission: Push data live over the internet to your cloud feeds
    if (!temp_feed.publish(temperature)) Serial.println("Failed to upload Temperature");
    if (!hum_feed.publish(humidity)) Serial.println("Failed to upload Humidity");
    if (!soil_feed.publish((int32_t)soilMoistureRaw)) Serial.println("Failed to upload Soil Moisture");
  }
}

void MQTT_connect() {
  int8_t ret;
  if (mqtt.connected()) return; // Already connected, skip

  Serial.print("Connecting to Cloud MQTT Broker... ");
  uint8_t retries = 3;
  
  while ((ret = mqtt.connect()) != 0) { 
       Serial.println(mqtt.connectErrorString(ret));
       Serial.println("Retrying connection in 5 seconds...");
       mqtt.disconnect();
       delay(5000);  
       retries--;
       if (retries == 0) {
         Serial.println("Could not connect to cloud. Running offline mode.");
         return;
       }
  }
  Serial.println("MQTT Cloud Connected!");
}
