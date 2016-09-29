# Little hack because the WDT's .feed doesn't really work on ESP8266 yet
# This is required because sometimes, importing the 'moisture' module
# fails with a MemoryError
import machine
irq = machine.disable_irq()

from moisture import MoistureMonitor
import network
import time
import ntptime

import config

machine.enable_irq(irq)

sta = network.WLAN(network.STA_IF)
sta.active(True)

for ap in sta.scan():
    if ap[0] not in config.aps:
        continue

    print("Found AP {}".format(ap))

    ap = ap[0]

    sta.connect(ap, config.aps[ap])

    while sta.status() != network.STAT_GOT_IP:
        print("Waiting for connection to come up")
        time.sleep(1)
    break

print("Connected to AP {}:\n\t{}".format(ap, sta.ifconfig()))

def adjtime(offset):
    t = time.time() + offset
    tm = time.localtime(t)
    tm = tm[0:3] + (0,) + tm[3:6] + (0,)
    machine.RTC().datetime(tm)
    print(time.localtime())

try:
    ntptime.settime()
except Exception as err:
    print("Can't set the time: {}".format(err))

adjtime(config.timezone_offset)

led = machine.Pin(2, machine.Pin.OUT)
led(1)

m = MoistureMonitor(led)
m.start()
