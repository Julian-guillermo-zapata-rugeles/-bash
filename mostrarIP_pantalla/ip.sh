#!/bin/bash

ip=$(/usr/sbin/ifconfig | grep 192.168 | awk '{print $2}')
export DISPLAY=:0 && notify-send "IP local  $ip"
