# Sustainable Smart Agriculture Network
**Objective**: Upload Micro-climate data (environment temp., humidity, soil moisture) & Irrigation data (pump session, water usage)
To Adafruit cloud via MQTT to control localized irrigation overrides.

**Project Type**: IoT & Embedded Systems.

**Components Used**: ESP32 controller, DHT22 sensor, Hygrometer (Potentiometer in simulation), Water pump control relay

**Network Infrastructure**: ESP32 in-built Wi-Fi, MQTT protocol, Adafruit IO Cloud server

## Program logic

The system is designed to automate irrigation system in an efficient manner, taking decisions based on environmental factors, to reduce water wastage.
The ESP module reads data from DHT22 & Hygrometer, sends these data to Cloud server for tracking & visualisation & makes decision to control pump relay.
Even if the server connection fails, the system can work offline as the evaluation process is localized. This is how the systems functionality can be generalized:

1. When the system is booting, it initiates Wi-Fi connection and matches user credentials with Adafruit IO Cloud server. In the mean time, it starts reading data from the sensors.
   If server connection is estabilished, the controller will start to send real time micro-climate data, pump sessions to private IO feed. Data bundles are sent at 5 sec. intervals.
   If connection fails, the program retries to connect at every 5 seconds while background data processing continues.

2. Though different kinds of data are collected continuously (temp., humidity, pump session, water usage, soil-moisture), only the soil moisture data from Hygrometer is taken into
   account for decision making (turn the pump ON/OFF). All other data along with soil-moisture is sent to Cloud to keep track. When Hygrometer reading is above 1500 index (roughly 36%
   of soil dryness or above) the pump starts feeding water to the field.

3. While the pump is running, pump session time is uninterruptly being counted by millis( ) function, as well as water used (in Liter) where the rate of water flow I set in this code is 
   20 LPM. This data is constantly provided in the serial monitor (5 sec. interval). When pump goes OFF, total session time and total water usage data gets sent to the Adafruit IO Cloud.
   When the soil gets hydrated enough, the pump goes OFF.

 ## Algorithm

1. INITIATE WIFI CONNECTION (when successful, go to step 2)

2. INITIATE MQTT SERVER CONNECTION (if successful, go to step 3. else go to step 3 & then step 4)

3. VOID MAIN LOOP ( ) {

    Starts reading data from sensors and calculates time to send data in server in given telemetry interval

    **CASE 1**: 
 
    WHEN soilMoistureRaw > DRY_SOIL_THRESHOLD (means dehydrated) 

    {pump turns ON. Pump session and water usage calculation begins}

    **CASE 2**: 

    WHEN soilMoistureRaw < DRY_SOIL_THRESHOLD (means hydrated) 

    {pump turns OFF. Pump session & total water usage is calculated and sent to cloud feed}

4. RETRY MQTT SERVER CONNECTION (activates only when step 2 fails. Return to step 3)
