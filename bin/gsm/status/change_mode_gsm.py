#!/usr/bin/python

import os
import sys
import socket
import time
import re
import subprocess


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

def is_running(process):
    s = subprocess.Popen(["ps", "axw"],stdout=subprocess.PIPE)
    for x in s.stdout:
        if re.search(process, x):
            return True
    return False        

#====================
class gsm_mode:
#====================

    #==================
    def __init__(self):
    #==================

        base_path = "/var/www/TMPFS/GSM/"

        # create base_path if not exist and chown to www-data
        if(not os.path.isdir(base_path)):
            os.makedirs(base_path)
            os.chown(base_path, 33, 33)

        self.file = base_path + "PPP"


    #======================
    def file_manager(self):
    #======================
        # INTERNET (GPRS link), LED blink @ 300 msec
        if (os.path.isfile(self.file) and is_running("gammu-smsd")):
            os.system("/usr/local/bin/gprs")
            #os.system("nohup sleep 20 && /usr/local/bin/gprs & >/dev/null 2>&1")
            print "GPRS"
        # SMS (CSD link), LED blink @ 3000 msec
        elif (not os.path.isfile(self.file) and not is_running("gammu-smsd") ):
            os.system("/usr/local/bin/csd")
            #os.system("nohup sleep 20 && /usr/local/bin/csd & >/dev/null 2>&1")
            print "SMS"


#=========================
if __name__ == "__main__":
#=========================

    get_lock('gsm-mode_daemon')
    gsm = gsm_mode()
    try:
        while True:
            gsm.file_manager()
            time.sleep(1)
    except: pass

