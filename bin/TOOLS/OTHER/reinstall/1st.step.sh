#!/bin/bash

cp /boot/reinstall/interfaces /etc/networkink/interfaces
cp /boot/reinstall/resolv.conf /etc/resolv.conf
cp /boot/reinstall/fstab /etc/fstab
rm - rf /boot/reinstall
