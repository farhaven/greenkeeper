import config
import json
import machine
import time
import gc
from umqtt.robust import MQTTClient

class MoistureMonitor():
    def __init__(self, led=None):
        self.led = led
        self.t = machine.Timer(0)
        self.a = machine.ADC(0)

        gc.collect()
        loops = 0
        self.m = MQTTClient(config.mqtt.id, config.mqtt.host, **config.mqtt["auth"])
        while True:
            try:
                self.m.connect()
            except (IndexError, OSError) as err:
                print("Retrying connect because of a {}...".format(str(err)))
                if loops > 10:
                    print("Resetting the board")
                    machine.reset()
            except MemoryError:
                print("Got a memory error. Resetting the board in 2 seconds")
                time.sleep(2)
                machine.reset()
            except:
                raise
            else:
                break
            loops += 1
            time.sleep(1)

    def start(self):
        self.m.publish(b'nodes', 'hi there')
        self.t.init(period=5000, mode=machine.Timer.PERIODIC, callback=lambda t: self.update())

    def stop(self):
        self.t.deinit()

    def update(self):
        now = time.localtime()
        tstamp = "{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}".format(*now[0:6])

        val = { "m": self.a.read() / 1024, "t": tstamp }
        print("Updating moisture, new value is {}".format(val))

        self.m.publish(b"moisture", json.dumps(val).encode('utf-8'), retain=True)

        if self.led is not None:
            self.led(0)
            time.sleep(0.1)
            self.led(1)
