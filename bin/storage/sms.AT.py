#!/usr/bin/python

import serial
import time

class sms:
  def __init__(self):
    self.ser = serial.Serial('/dev/ttyAMA0', 115200, timeout=1)
    #self.desc_cmd = ["\nverificare port serial:", "cerinta PIN:", "nivel semnal:", "setez mesaj text:", "setez centrul de mesagerie:"]
    #self.init_cmd = ["AT", "AT+CPIN?", "AT+CSQ", "AT+CMGF=1", "AT+CSCA=\"+40766000510\""]
    self.desc_cmd = ["\nverificare port serial:", "setez mesaj text:", "setez centrul de mesagerie:"]
    self.init_cmd = ["AT", "AT+CMGF=1", "AT+CSCA=\"+40722004000\""]    


	#+40744946000	pentru ORANGE;
	#+40722004000	pentru VODAFONE;
	#+40766000510	pentru TELEKOM

  def __del__(self):
    self.ser.close()

  def init_connection(self):
    self.send_cmd(chr(26))
    for index, cmd in enumerate(self.init_cmd):
      print self.desc_cmd[index]
      print self.send_cmd(cmd)
    
  def send_cmd(self, cmd):
    self.ser.write((cmd+"\r").encode())
    msg = self.ser.read(64)
    return msg

  def send_sms(self, number, message):
    print "setez numarul destinatarului:"
    self.ser.write("AT+CMGS=\"+4"+number+"\"\r")
    time.sleep(1)
    set_nr = self.ser.read(64)
    print set_nr
    last_str = set_nr[-16:]
    phone = last_str[:10]
    print "\nNUMAR-ul destinatarului este:",phone
    print "\ntrimit textul mesajului:\n"
    self.ser.write(message+"\r"+chr(26))
    time.sleep(3)
    msg = self.ser.read(256)
    #if msg lengt >= 160 characters
    print msg
    message = msg[:-22]
    print "TEXT-ul mesajului trimis este:",message,"\n"
    if "OK" in msg:
      #print "Mesaj \"",message,"\" trimis la destinatarul:",phone,"\n"
      print "...mesajul a fost trimis la destinatar:",phone,"\n"
    else:
      print "...mesajul NU a fost trimis!\n"
    
if __name__ == "__main__":
  import sys
  if len(sys.argv) != 3 or len(sys.argv[1]) != 10:
    print "ERROR: Usage >>> [cmd] [phone number(07xxxxxxxx)] \"[message]\"" 
    exit()
  if len(sys.argv[2]) > 160:
    #print "Message not sent!"
    #print "Message character limit is 160 (your message: "+str(len(sys.argv[2]))+" characters)"
    print "\nMesaj netrimis!"
    print "Marimea mesajului nu poate depasi 160 caractere."
    print "Mesajul tau contine: "+str(len(sys.argv[2]))+" characters!\n" 
    exit()
  s = sms()
  s.init_connection()
  s.send_sms(sys.argv[1].strip(), sys.argv[2].strip())

