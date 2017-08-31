#!/bin/bash

# this script save some config data usefull if the sd card crashes.

  cp /boot/cmdline.txt /root/TOOLS/recovery/cmdline.txt
  cp /boot/cmdline.txt.original /root/TOOLS/recovery/cmdline.txt.original
  cp /boot/cmdline.txt.partuuid /root/TOOLS/recovery/cmdline.txt.partuuid
  cp /boot/config.txt /root/TOOLS/recovery/config.txt
  cp /etc/fstab /root/TOOLS/recovery/fstab
