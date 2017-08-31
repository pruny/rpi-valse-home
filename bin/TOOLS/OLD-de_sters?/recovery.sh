#!/bin/bash

# this script save some config data usefull if the sd card crashes.

  cp /boot/cmdline.txt /root/bin/TOOLS/recovery/cmdline.txt
  cp /boot/cmdline.txt.original /root/bin/TOOLS/recovery/cmdline.txt.original
  cp /boot/cmdline.txt.partuuid /root/bin/TOOLS/recovery/cmdline.txt.partuuid
  cp /boot/config.txt /root/bin/TOOLS/recovery/config.txt
  cp /etc/fstab /root/bin/TOOLS/recovery/fstab
