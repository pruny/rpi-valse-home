#!/bin/bash

# this script save some data: my projects , network config, motd, cron jobs, etc.

DIR=/media/usb.drive/files@rPi

  rsync -rpt /root/bin ${DIR}/my.root.bin
  rsync -rpt --exclude=".*" /var/www ${DIR}/my.var.www 
  cp /etc/network/interfaces ${DIR}/my.etc.network.interfaces
  cp /etc/resolv.conf ${DIR}/my.etc.resolv.conf
  cp /etc/dhcpcd.conf ${DIR}/my.etc.dhcpcd.conf  # begin with PI2
  cp /etc/fstab ${DIR}/my.etc.fstab
  cp /etc/init.d/motd ${DIR}/my.etc.init.d.motd
  crontab -l > ${DIR}/my.root.crontab

  cp /boot/cmdline.txt /root/bin/TOOLS/recovery/cmdline.txt
  cp /boot/cmdline.txt.original /root/bin/TOOLS/recovery/cmdline.txt.original
  cp /boot/cmdline.txt.partuuid /root/bin/TOOLS/recovery/cmdline.txt.partuuid
  cp /boot/config.txt /root/bin/TOOLS/recovery/config.txt
  cp /etc/fstab /root/bin/TOOLS/recovery/fstab