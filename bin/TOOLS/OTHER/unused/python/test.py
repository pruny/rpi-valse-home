#!/usr/bin/python

import RPi.GPIO as GPIO
from time import sleep

GPIO.setmode(GPIO.BCM)
GPIO.setup(6, GPIO.IN)

try:
  while True:
    print GPIO.input(6)
    sleep(1)
finally:
  GPIO.cleanup()
