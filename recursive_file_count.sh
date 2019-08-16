#!/bin/bash

# Recusrively count files in the current directory
# Aliased to lsd 
if [ "$1" == "-h" ]; then
    echo "Recursively count files in each subdirectory of the current folder"
else
    find . -type d -print0 | while read -d '' -r dir; do
        files=("$dir"/*)
        printf "%5d files in directory %s\n" "${#files[@]}" "$dir"
    done
fi
