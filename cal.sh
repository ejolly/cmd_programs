#!/bin/bash

if [[ "$1" == '-w' ]]; then
    gcalcli calw
elif [[ "$1" == '-m' ]]; then
    gcalcli calm
elif [[ "$#" -eq 0 ]]; then
    gcalcli agenda
fi
