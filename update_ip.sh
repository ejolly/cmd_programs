#!/bin/bash
# Write the current ip address to a text file in dropbox for easier remote access (e.g via mobile devices)
# Runs as a cronjob automatically
/usr/sbin/ipconfig getifaddr en0 > /Users/Esh/Dropbox/current_ip.txt
