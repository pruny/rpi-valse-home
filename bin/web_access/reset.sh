#!/bin/bash

# this script change (for short time) status of a speciffic gpio

gpio write 29 1
sleep 20
gpio write 29 0
