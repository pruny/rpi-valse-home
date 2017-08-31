#!/usr/bin/python
#-*- coding: utf-8 -*-

### get lines of text read on serial port & save them to a file, db...

from __future__ import unicode_literals
import serial
import io
import os
from datetime import datetime
import rrdtool

### configure port
_PORT  = "/dev/rs232b"							# symlink - read data from usb to serial converter
_BAUD  = 9600								# baud rate for serial port

### archive location
_PATH_MAIN = "/var/www/TMPFS/LHT"					# se recreaza daca path este sters #
_ARCHIVE_FOLDER_PATH = _PATH_MAIN + "/ARCHIVE"				# NU se recreaza daca path este sters
_TODAY_LOG_PATH = _PATH_MAIN + "/log.today"				# NU se recreaza daca path este sters
_LAST_VALUES_LOG_PATH = "/var/www/TMPFS/lht.val" 			# se recreaza daca path este sters #

today_log_file = None
last_values_log_file = None
last_values_array = []

### db location
_RRD_DB_PATH = "/home/pi/data/shared/lht/LHT.rrd"

### write mode: archive & db or db only
_WRITE_TO_RRD_ONLY = True  						# if True only write to RRD database and LAST_VALUES_LOG

### input signal description
_VALUES_GROUP_SIZE = 6							# each block transmission contain 6 lines of text
_VALUES_GROUP_WORD = "Vapor"						# key word to detect each block

rrd_array = [[] for x in range(_VALUES_GROUP_SIZE)]
_RRD_ARRAY_UPDATE_ELEMENTS = 1						# rrd update mode: make average calculation or not (6 for minut-average >> if block of text received every 10 sec; 1 for every individual value on block)

today_date = None

def NOW(frmt): return datetime.now().strftime(frmt)


def log_archive():
    global today_date, _ARCHIVE_FOLDER_PATH, _TODAY_LOG_PATH,today_log_file

    if(not os.path.isfile(_TODAY_LOG_PATH)): return None

    if(not today_date):
        today_log_file = None
        try:
            if(not os.path.isdir(_ARCHIVE_FOLDER_PATH + NOW("/%Y/%m/%d/"))):
                os.makedirs(_ARCHIVE_FOLDER_PATH + NOW("/%Y/%m/%d/"))
            os.rename(_TODAY_LOG_PATH, _ARCHIVE_FOLDER_PATH + NOW("/%Y/%m/%d/") + "_log")
        except Exception as e:
            print "Error moving daily log to archive [1]"
    elif(NOW("/%Y/%m/%d/") != today_date):
        today_log_file = None
        try:
            if(not os.path.isdir(_ARCHIVE_FOLDER_PATH + today_date)):
                os.makedirs(_ARCHIVE_FOLDER_PATH + today_date)
            os.rename(_TODAY_LOG_PATH, _ARCHIVE_FOLDER_PATH + today_date + "log")
        except Exception as e:
            print "Error moving daily log to archive [2]"

    today_date = NOW("/%Y/%m/%d/")


def log_last_values_write(line):
    global last_values_array, _LAST_VALUES_LOG_PATH, rrd_array, _RRD_DB_PATH

    last_values_array.append(line)

    if(len(last_values_array) > _VALUES_GROUP_SIZE):			# remove first element of log_array if it contains more than 6 elements
        last_values_array.pop()

    ### if the last element is _VALUES_GROUP_WORD and log_array has _VALUES_GROUP_SIZE items write to LAST_VALUES_LOG
    if(_VALUES_GROUP_WORD in line and len(last_values_array) == _VALUES_GROUP_SIZE):

        ### Write data to LAST VALUES LOG
        with io.open(_LAST_VALUES_LOG_PATH, 'w+', encoding='utf8') as f:
            for i, lht in enumerate(last_values_array):
                f.write(lht)

                ### Update rrd_array with value from serial port / 0.0 if error
                try:
                    lht_split = lht.split(";")[1].strip().split(".")
                    lht_value = float(lht_split[0] + "." + lht_split[1][:2])
                    rrd_array[i].append(float(lht_value))
                except Exception as e:
                    rrd_array[i].append(0.0)

        ### write data to RRD database
        if(len(rrd_array[0]) >= _RRD_ARRAY_UPDATE_ELEMENTS):
            rrd_val = [0 for x in range(_VALUES_GROUP_SIZE)]
            for i, elem in enumerate(rrd_array):
                rrd_val[i] = sum(rrd_array[i]) / float(len(rrd_array[i]))	# make average (or not)
                rrd_array[i] = []
            try:
                rrd_string = "N:" + ":".join([str(round(x,2)) for x in rrd_val])
                rrdtool.update( str(_RRD_DB_PATH), str(rrd_string) )
            except Exception as e:
                print "Unable to update RRD database - {0}".format(_RRD_DB_PATH)
            rrd_array = [[] for x in range(_VALUES_GROUP_SIZE)]

    if(_VALUES_GROUP_WORD in line):					# reset log_array if complete transmision
        last_values_array = []


def log_write(line):
    global _PATH_MAIN, _TODAY_LOG_PATH, today_log_file

    if(not os.path.isdir(_PATH_MAIN)): os.makedirs(_PATH_MAIN)

    log_archive()

    log_last_values_write(line)

    if _WRITE_TO_RRD_ONLY:
        return None

    if not today_log_file: today_log_file = io.open(_TODAY_LOG_PATH, 'a')

    ### write today log
    time_now = NOW('%H:%M:%S:%f')[:-3].strip()
    today_log_file.write(time_now + ' ; ' + line.strip() + '\n')	# write acquisition time & line of text to file
    today_log_file.flush()						# make sure it actually gets written out


### continuously read the serial port
ser = serial.Serial(_PORT, _BAUD)
spb = io.TextIOWrapper(io.BufferedRWPair(ser,ser,1),			# buffer size is 1 byte, so directly passed to TextIOWrapper
    encoding='windows-1252', errors='ignore',line_buffering=True)	# degree sygn is chr(176)

spb.readline()								# throw away first line; likely to start mid-sentence (incomplete)

while (1):
    log_write(spb.readline())
