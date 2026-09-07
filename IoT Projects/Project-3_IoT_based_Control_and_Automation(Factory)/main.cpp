# Project: Factory facilities (storage/production) General Automation and Control
# Objective: To have control over central appliances of a facility (central AC, lights, parking lot lamp, garage door, water pump) via
#           phone or web browser using Wi-Fi connectivity, reducing physical interaction.

import time
import network
from machine import Pin, ADC, PWM, I2C
from i2c_lcd import I2cLcd
from umqtt_simple import MQTTClient
import dht

# MQTT Cloud Broker config
USER = "SkID_2__6"     # Use your own username and key from 'io.adafruit.com' 
KEY = "aio_GUGTQIWz2knBhSFEU" 

# Sensor Pins
sensor_dht = dht.DHT22(Pin(15))
pir_room = Pin(18, Pin.IN)
pir_door = Pin(17, Pin.IN)
ldr_out = ADC(Pin(27))
relay_ac = Pin(10, Pin.OUT)
relay_lamps = Pin(11, Pin.OUT)
relay_light = Pin(13, Pin.OUT)
pump = Pin(12, Pin.OUT)
servo = PWM(Pin(16))
servo.freq(50) 

# For I2C LCD display
i2c = I2C(0, sda=Pin(0), scl=Pin(1), freq=400000) 

# Variables (initial stage)
ac_on = False
night_mode = False
last_motion = time.time()
last_pub = 0
last_screen_toggle = 0
show_screen_one = True
temp = 0
garage_status = "CLOSED"
pump_status = "OFF"
door_status = "CLEAR" 

# State-tracking variables to prevent duplicate cloud spamming
last_door_status = ""
last_ac_on = False 

# Slow-Motion Garage door operation
current_duty = 1638

def move_garage(target_duty):
    global current_duty
    step = 32 if target_duty > current_duty else -32 
                # 1638 to 4915 is a difference of ~3277 steps. 
                # Moving 32 steps every 0.04 seconds takes ~100 iterations.
                # 100 loops * 0.04s delay = ~4.0 seconds total movement profile.
    while abs(current_duty - target_duty) > 32:
        current_duty += step
        servo.duty_u16(current_duty)
        time.sleep(0.04) # Smooth mechanical damping delay
    current_duty = target_duty
    servo.duty_u16(current_duty) 

# LCD Text line Controls
def lcd_cmd(cmd):
    i2c.writeto(0x27, bytes([0x00, cmd])) # bytes(0x00, cmd) means command to execute codes, not to print

def lcd_write(text):
    i2c.writeto(0x27, bytes([0x40]) + text.encode()) # bytes(0x40, text.encode) means command to display/print texts

lcd = I2cLcd(i2c, 0x27, 2, 16)

def init_lcd():
    pass

def update_display():
    lcd.clear()
    if show_screen_one:
        lcd.putstr(f"Pump: {pump_status}\nTemp: {temp}C")
    else:
        lcd.putstr(f"Garage: {garage_status}\nFront: {door_status}")

# WiFi connectivity
def connect_wifi():
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    time.sleep(1.0)
    if not wlan.isconnected():
        print("Connecting to Wokwi-GUEST...")
        wlan.connect("Wokwi-GUEST", "")
        # Force code to wait here until Wokwi assigns a virtual IP
        while not wlan.isconnected():
            print(".", end="")
            time.sleep(0.5)
    print("\nConnected! IP:", wlan.ifconfig())


# Controller Logics (Receiving phone commands)
def on_message(topic, msg):
    global ac_on, last_motion, night_mode, garage_status, pump_status, last_ac_on
    cmd = msg.decode()
    feed = topic.decode()
    if "room-ac" in feed:
        if cmd == "ON":
            relay_ac.on()
            ac_on = True
            last_ac_on = True
            last_motion = time.time()
            client.publish(f"{USER}/feeds/ac-status", "ON")
        else:
            relay_ac.off()
            ac_on = False
            last_ac_on = False
            client.publish(f"{USER}/feeds/ac-status", "OFF")
    elif "nighttime-mode" in feed:
        night_mode = (cmd == "ON")
        if not night_mode:
            last_motion = time.time()
    elif "interior-light" in feed:
        relay_light.value(1 if cmd == "ON" else 0)
    elif "water-pump" in feed:
        pump.value(1 if cmd == "ON" else 0)
        pump_status = cmd 
        # REAL-TIME UPDATE: Sends pump state instantly when toggled
        client.publish(f"{USER}/feeds/pump-status", pump_status)
    elif "garage-door" in feed:
        if cmd == "OPEN":
            garage_status = "OPENING..."
            update_display()
            move_garage(4915)
            garage_status = "OPEN"
        else:
            garage_status = "CLOSING..."
            update_display()
            move_garage(1638)
            garage_status = "CLOSED"
            update_display() 
            # REAL-TIME UPDATE: Sends garage state instantly when moved
            client.publish(f"{USER}/feeds/garage-status", garage_status) 

# Initialization (display & server)
lcd.clear()
lcd.putstr("Connecting...")
servo.duty_u16(current_duty)
connect_wifi()

client = MQTTClient("pico_home", "io.adafruit.com", user=USER, password=KEY)
client.set_callback(on_message)
# Force the system to stop running if the key/username fails authentication
if client.connect() != 0:
    print("\n[CRITICAL] Stopping simulation. Please provide a valid active Adafruit IO Key.")
    import sys
    sys.exit()

feeds = ["interior-light", "water-pump", "garage-door", "room-ac", "nighttime-mode"]
for f in feeds:
    client.subscribe(f"{USER}/feeds/{f}")
lcd.clear()
lcd.putstr("System Online")

# Main Loop
while True:
    client.check_msg()
    now = time.time() # Check Front Door Sensor
    
    # Check Front Door Sensor
    if pir_door.value() == 1:
        door_status = "INTRUDER"
    else:
        door_status = "CLEAR"
    if door_status != last_door_status:
        try: 
            client.publish(f"{USER}/feeds/front-door-status", door_status)
            last_door_status = door_status
        except:
            pass 
            
    # Auto Outdoor Lights
    raw_ldr = ldr_out.read_u16()
    
    # High-sensitivity mapping to catch the tight analog voltage swing from the module
    if raw_ldr > 10000: 
        relay_lamps.on()
    else:
        relay_lamps.off()
        
    # Room Motion Tracking
    if pir_room.value() == 1:
        last_motion = now
    if ac_on:
        if night_mode:
            last_motion = now
        elif (now - last_motion) >= 180:
            relay_ac.off()
            ac_on = False 
            # ONLY publish if the AC state shifted
            if ac_on != last_ac_on:
                client.publish(f"{USER}/feeds/ac-status", "OFF")
                last_ac_on = False 
                
    # Flip LCD Screen views
    if now - last_screen_toggle >= 3:
        show_screen_one = not show_screen_one
        update_display()
        last_screen_toggle = now 
        
    # Transmits status reports every 10 seconds to save cloud bandwidth
    if now - last_pub >= 10:
        try:
            sensor_dht.measure()
            temp = sensor_dht.temperature() 
            client.publish(f"{USER}/feeds/temperature", str(temp))
        except Exception as e:
            pass
        last_pub = now
    time.sleep(0.05)

