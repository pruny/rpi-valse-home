#!/usr/bin/python

# this script uses ANSI control codes to constantly display the POWER LED status in the top right corner

import RPi.GPIO as GPIO , time
from subprocess import call
import shlex
import sys

import signal

def handler(signum, frame):
#   call(shlex.split("echo -ne '\e[u''\e[0m'"))
   sys.exit()

signal.signal(signal.SIGINT, handler)

redLED=35
GPIO.setmode(GPIO.BCM)
GPIO.setup(redLED, GPIO.IN)

powerlow=0
#call(shlex.split("echo -ne '\e[s'"))
while True:
   if(GPIO.input(redLED)==0):
      call(shlex.split("echo -ne '\e[s''\e[1;56H''\e[1;31m' POWER lower below 4.63 volts '\e[u''\e[0m'"))
      powerlow += 1
   else:
      powerlow = 0
      call(shlex.split("echo -ne '\e[s''\e[1;78H''\e[1;31m' POWER OK -> RED LED ON '\e[u''\e[0m'"))

   if (powerlow  > 3):
      break
    
   time.sleep(1)

#call(shlex.split("echo -ne '\e[u''\e[0m'"))
print "LOW power for " + str(powerlow) + " seconds"

# run script: /path/under_voltage.py &
