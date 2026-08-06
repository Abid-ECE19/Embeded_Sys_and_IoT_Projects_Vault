# Factory facilities (storage/production) General Automation and Control (in Development)
**Objective**: Control central appliances (AC, lights, outdoor lamp, water pump, garage door etc.) from your phone/web browser via Wi-Fi connectivity, reducing physical interaction.

**Project Type**: IoT based 

**Components Used**: Raspberry Pi Pico W, DHT22 sensor, LDR sensor, I2C 16x2 LCD display, 2 PIR sensor 

(for front door &amp; interior), servo motor (for garage door) and 4 relays (AC, lights, outdoor lamp, water pump)

**Network Infrastructure**: Raspberry Pico W in-built Wi-Fi, MQTT protocol, Adafruit IO Cloud server

**IO feeds in Cloud server**: 5 incoming feeds (temperature, front-door-status, garage-status, ac-status, pump-status)

&amp; 5 outgoing feeds (interior-light, garage-door, water-pump, room-ac, nighttime-mode)

## Program Functionality

The system is designed to control general appliances through Wi-Fi network, so you don't need to be physically present to control such. Also outdoor lamps turn ON/OFF automatically based on ambient brightness, along with showing important states via LCD monitor. 
The Raspberry module reads data from different sensors, sends these data to Cloud server for tracking & visualization & receives command from end device to control relay modules.
There is a huge amount of technical terms and calculations required to know for this program to work. This is how the systems functionality can be generalized:

1. Initialize: When the system is booting, it initiates Wi-Fi connection and matches user credentials with Adafruit IO Cloud server. In the mean time, it starts reading data from the sensors. The LCD display also starts working immediately.
If server connection is established, the controller will start to send real time outgoing feeds data (only when state is changed).

2. Outdoor lamp: The LDR sensor tracks the change of outdoor brightness in real-time. Technically, when outside is bright enough, the internal resistance lowers down and rises up when its dark  (resistance threshold < 10k means daytime, above that means sunset and night). In terms of Lux slider in the LDR, that means a swinging point at around 15-20 lux. Above this point, lamp turns ON.

3. Garage door: Works in a combination of servo motor (angular movement) and a pulley system (converting that angular movement into linear). Say we want to calibrate the servo movement such as - (0 - 90 degree) for door OPENING and (90 - 0 degree) for door CLOSING. Servo motor can do such in less then 1 sec. We don't want a heavy door slammed open/close this fast! as it would damage the mechanical parts. So we need to introduce damping delay in servo operation for smooth opening/closing.

   In 50Hz PWM frequency, there are 50 pulses with 20ms duration for each pulse. Now, to stay at 0 degree (CLOSED), the servo needs duty value of 1638 for 0.5ms from each 20ms window. And to stay at 90 degree (OPEN), the servo needs duty value of 4915 for 1.5ms from each 20ms window (for 16-bit operation, PWM duty value varies from 0 to 65535 for each 20ms window, which gives us 65535/20 = 3277 ticks/ms. So, a 0.5ms operation leads to duty value 0f 0.5 x 3277 = 1638)

   Now, from 0 degree (1638) to 90 degree (4915), there are total 4915-1638 = 3276 steps. Moving 32 steps at ~100 iteration will cover all steps. If there is a damping delay of 0.04s for each iteration, total time delay will be ~4sec, enough for a smooth closing/opening of such heavy door. Now the only thing required is to connect this shaft to an appropriate gear-ratio pulley system.

4. Interior light, Pump and Front-door checking: Lights and Pump relay are controlled from app dashboard directly. The outgoing feeds from Cloud broker to Raspberry executes the relay commands given from the end device, And their status is also send via MQTT cloud to end device. As for the Front-door checking (someone is there or clear), it it done by PIR sensor. The status of it is both showed to LCD display and on your phone as real-time alert.

5. Central AC: It can be turned ON\OFF from the dashboard. However, there is an auto turn OFF sequence in the code available for power saving (decided by interior PIR sensor, if there is no movement detected within 180 sec.). But it the facility requires to keep the AC ON during night (when no one is present- storage), the controller can initiate 'Nighttime mode', which bypasses the PIR auto turn OFF sequence after 3 mins. of inactivity.

