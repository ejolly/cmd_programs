#!/bin/bash

# Search the current location using fzf and then pipe results for nicer printing through exa
if [ "$1" == "-e" ]; then
    fzf -e -f "$2" | xargs exa --header --group --long --created --modified --git
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    printf "Find files by name in current dir.\n\nUsage: ff string\n\nExamples:\nff .sh (find all files ending in .sh)\nff 'note .py' (find all files containing the strings 'note' and '.py'\n"
else
    fzf -f "$@" | xargs exa --header --group --long --created --modified --git
fi
