#!/usr/bin/python

import RPi.GPIO as GPIO
import datetime
import os
import time
import socket
import sys


#==========================
def get_lock(process_name):
#==========================

    global lock_socket
    lock_socket = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
    try:
        lock_socket.bind('\0' + process_name)
        return True
    except socket.error:
        print "Process already running!"
        sys.exit()

#====================
class gsm_status_led:
#====================

    #==================
    def __init__(self):
    #==================
        base_path = "/var/www/TMPFS/GSM/"

        if(not os.path.isdir(base_path)):
            os.makedirs(base_path)			# create directory if not exist
            os.chown(base_path, 33, 33)			# change uid/gid to www-data

        self.file_array = [
            {"low":  200, "high":  400, "file": base_path + "GPRS"},		# threshold = 300 msec
            {"low":  600, "high":  1000, "file": base_path + "NO-NETWORK"},	# threshold = 800 msec
            {"low": 2500, "high": 3500, "file": base_path + "REGISTERED"}	# threshold = 3000 msec
        ]

        for x in self.file_array:
            try: os.remove(x["file"])
            except: pass

        self.pin = 26								# input pin to read sygnal from GSM modem "NET" LED
        self.initial_ignore_count = 5;

        GPIO.setmode(GPIO.BOARD)
        GPIO.setup(self.pin, GPIO.IN, pull_up_down=GPIO.PUD_UP)
        GPIO.add_event_detect(self.pin, GPIO.BOTH, callback=self.rising_falling)

        self.time_rising = datetime.datetime.now()
        self.time_falling = datetime.datetime.now()
        self.time_diff = 0

    #=================================
    def rising_falling(self, channel):
    #=================================
        if self.initial_ignore_count > 0:
            self.initial_ignore_count -= 1
            return True

        if GPIO.input(self.pin):
            self.time_rising = datetime.datetime.now()
            return True
        self.time_falling = datetime.datetime.now()

        self.diff = self.time_falling - self.time_rising
        self.time_diff = (self.diff.days * 86400000) + (self.diff.seconds * 1000) + (self.diff.microseconds / 1000)

        self.file_manager()

        print self.time_rising
        print self.time_falling
        print self.time_diff

        return True

    #======================
    def file_manager(self):
    #======================
        now = datetime.datetime.now()
        diff_off = now - max(self.time_rising, self.time_falling)
        time_diff_off = (diff_off.days * 86400000) + (diff_off.seconds * 1000) + (diff_off.microseconds / 1000)
        for x in self.file_array:
            if self.time_diff > x["low"] and self.time_diff < x["high"] and time_diff_off < 7000:
                try: open(x["file"], 'a').close()
                except: pass
            else:
                try: os.remove(x["file"])
                except: pass

#=========================
if __name__ == "__main__":
#=========================

    get_lock('gsm_daemon')
    gsm = gsm_status_led()
    try:
        while True:
            gsm.file_manager()
            time.sleep(0.5)
    finally:
        GPIO.cleanup()
