# IoT-Projects-Vault
Before we start using microcontrollers like ESP32, Raspberry Pi Pico, Arduino etc., we need to know about their safe usage margins. Almost all of them operates on 5V DC power, so anything higher then that can fry up these delicate controllers. And in terms of data I/O (or GPIO pins), all controllers strictly requires 3.3V on board. so while connecting LEDs, switches from GPIO pins to GND, must use a resistor in series, otherwise; the board will be short-circuited.

## For ESP32 module
**Safe pins (GPIO)**: 12 to 31
**Analog Input pins**: 32 to 39
**Analog Output pins**: 25 &amp; 26
**Pins to avoid (memory flash)**: 6 to 11
**PWM pins**: 1 &amp; 3
**Wi-Fi friendly pins**: 32 to 39

## For ESP8266 module
**Safe pins (GPIO)**: 12 to 16
**Analog Input pins**: A0 (17)
**Pins to avoid (memory flash)**: 6 to 11
**PWM pins**: 1 &amp; 3

## For Raspberry Pi Pico module
**Safe pins (GPIO)**: 0 to 25
**Analog Input pins**: 26, 27, 28

## List of some commonly used sensors
**DHT11/DHT22**: Temperature &amp; Humidity sensor {Type: Digital}
**LDR**: Light Dependent Resistor (measures light intensity) {Type: Analog}
**PIR (HC-SR501)**: Passive IR sensor (detects motion based on IR) {Type: Digital}
**Ultrasonic (HC-SR04)**: Distance measurement sensor (via ultrasound) {Type: Digital}
**Bluetooth Module (HC-06)**: Bluetooth module for Arduino (uses PWM RX, TX terminals)

