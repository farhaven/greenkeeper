Greenkeeper
===========

What you need
-------------

* An ESP8266 based device, such as a NodeMCU board
* A plant
* An MQTT-broker

Hardware setup
--------------

* Connect a probe to the analog input and one to the 3.3V output of the device
* Push the probes into the plant's soil, about 5 to 7 centimeters apart

Installation
------------

* Flash [Micropython](https://micropython.org/download/#esp8266) onto your device
* Copy all `.py` files to the devices flash memory, except for `config.def.py`
* Copy `config.def.py` to `config.py` and modify it to suit your environment. This includes:
	* Your WIFI configuration (SSID and password)
	* Your MQTT configuration
	* Your time zones offset from UTC in seconds
* Copy your `config.py` to your device

Operation
---------

Once the device boots, it will connect to your wireless network and to the MQTT broker. It will
publish a message with the content `hi there` to the `nodes` topic. It will then estimate the
soil moisture by measuring the resistance between the two probes. A moisture of 100% means
a resistance of almost 0 Ohms and should never happen unless you bathe your plants in salt
water (Don't do that!). The moisture values are sent to the `moisture` topic as retained
messages. They also contain a time stamp.
