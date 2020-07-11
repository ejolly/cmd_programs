#!/bin/bash

if [[ "$1" == '-w' ]]; then
    gcalcli calw --no-military
elif [[ "$1" == '-m' ]]; then
    gcalcli calm --no-military
elif [[ "$#" -eq 0 ]]; then
    gcalcli agenda --no-military
fi
