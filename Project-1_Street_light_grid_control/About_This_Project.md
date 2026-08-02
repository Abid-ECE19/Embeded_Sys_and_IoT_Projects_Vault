# Smart City Lighting Control
**Objective**: To assist in efficient operation of street lights by automating street grids via localized light & motion tracking sensors.

**Project Type**: Embedded Systems.

**Components Used**: ESP32 controller, LDR sensor, PIR motion track sensor, lights control relay

## Program logic

The system is made to distinguish these two scenarios and operate in such:

1. When ambient light is very low (after sunset) and there is movement detected by pedestrian/vehicle near a light poll - in this case,
   The system activates the grid relay from NO (Normally Open) position to HIGH position, meaning the lights turn on when motion is detected.
   Lights are turned on for 10 seconds from a motion is detected. If There are no movement detected within this 10 sec. period, the lights are turned OFF
   until a new movement is detected via PIR sensor.

2. When the ambient light is bright enough (in daytime) - in this case, the system doesn't turn ON the lights, no matter there is motion or not.
   When ambient light starts to increase (close to dawn), the system makes the grid relay to set into NO (Normally Open) position).

 ## Algorithm

 **CASE 1**: 
 
 when ambientLight <= LDR_THRESHOLD (in darkness) {

 if motionDetected = TRUE, turn ON lights for 10 sec.

 else, turn OFF lights}

 **CASE 2**: 

 when ambientLight > LDR_THRESHOLD (in daytime) {

 keep the lights turned OFF}
 

 

 
