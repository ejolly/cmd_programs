#!/bin/bash

# Pretty display a csv file in the terminal
# Relies on visidata https://jsvine.github.io/intro-to-visidata/the-big-picture/installation/
# pip install visidata
# Aliased to csv [filename]
if [ "$1" == "-h" ]; then
    filename=$(basename -- $2)
    extension="${filename##*.}"
    head -n 10 $2 | vd -f $extension
 elif [ "$1" == "-s" ]; then
 	# Get the shape of the csv file
    filename=$(basename -- $2)
    extension="${filename##*.}"
    if [ "$extension" == "csv" ]; then
        awk -F, 'END {printf "NRows: %s\nNCols: %s\nColNames: ", NR, NF}' "$2" && awk -F, 'NR==1 {print; exit}' "$2"
    else
        awk -F\t 'END {printf "NRows: %s\nNCols: %s\nColNames: ", NR, NF}' "$2" && awk -F\t 'NR==1 {print; exit}' "$2"
    fi
elif [ "$1" == "--help" ] || [ $# -eq 0 ]; then
    printf "Display a csv file in the terminal nicely with interactive pagination.\n\nUsage csv file.csv\n\nOptional flags:\n-h print the Head of the file (first 10 rows)\n-s print the Shape and column names\n-t prepend to other flags (e.g. -th) to force Tab-separated file reading; try it if output looks wonky\n"
else 
    vd $1
fi

# Code below has no deps but is clunkier
# if [ "$1" == "-t" ]; then
# 	# Force reading filing as tab-separated (usually not needed)
# 	perl -pe 's/((?<=\t)|(?<=^))\t/ \t/g;' "$2" | column -t -s $'\t' | exec less  -F -S -X -K
# elif [ "$1" == "-th" ]; then
# 	# -t but print first 10 lines only
# 	perl -pe 's/((?<=\t)|(?<=^))\t/ \t/g;' "$2" | column -t -s $'\t' | exec head -n 10
# elif [ "$1" == "-ts" ]; then
# 	# -t but get the shape of the csv file
# 	awk -F\t 'END {printf "NRows: %s\nNCols: %s\nColNames: ", NR, NF}' "$2" && awk -F\t 'NR==1 {print; exit}' "$2"
# elif [ "$1" == "-h" ]; then
# 	# Assume reading as comma-separated and print first 10 lines only
# 	perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$2" | column -t -s, | exec head -n 10
# elif [ "$1" == "-s" ]; then
# 	# Get the shape of the csv file
# 	awk -F, 'END {printf "NRows: %s\nNCols: %s\nColNames: ", NR, NF}' "$2" && awk -F, 'NR==1 {print; exit}' "$2"
# elif [ "$1" == "--help" ] || [ $# -eq 0 ]; then
# 	# help
# 	printf "Display a csv file in the terminal nicely with interactive pagination.\n\nUsage csv file.csv\n\nOptional flags:\n-h print the Head of the file (first 10 rows)\n-s print the Shape and column names\n-t prepend to other flags (e.g. -th) to force Tab-separated file reading; try it if output looks wonky\n"
# else	
# 	perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$1" | column -t -s, | exec less  -F -S -X -K -N
# fi
