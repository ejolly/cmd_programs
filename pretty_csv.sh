#!/bin/bash

# Pretty display a csv file in the terminal
# Relies on visidata https://jsvine.github.io/intro-to-visidata/the-big-picture/installation/
# And csvkit https://csvkit.readthedocs.io/en/latest/index.html
# pip install visidata csvkit
# Aliased to csv [filename]
if [ "$1" == "--help" ] || [ $# -eq 0 ]; then
    printf "Display a csv file in the terminal nicely with interactive pagination.\n\nUsage csv file.csv\n\nOptional flags:\n-h print the head of the file (first 10 rows)\n-s print the shape and column names\n-u file colname, searchable unique values in colname\n-n check for null values in any column\n\nAlso checkout csvkit with the commands\ncsvcut\ncsvlook\ncsvlook file | fzf --reverse (searchable contents)\ncsvstat\ncsvstat file -c colname (stats for colname, e.g. --unique or omit for all stats)\n\nAs well as docs for visidata for aggregation and basic plotting:\nhttps://www.visidata.org/docs/\n"
elif [ $# -eq 1 ]; then
    vd $1
else
    filename=$(basename -- $2)
    extension="${filename##*.}"
    if [ "$1" == "-h" ]; then
        csvlook $filename --max-rows 10
    # head -n 10 $2 | vd -f $extension
     elif [ "$1" == "-s" ]; then
        # Get the shape of the csv file
        if [ "$extension" == "csv" ]; then
            awk -F, 'END {printf "Shape: (%s, %s)\nColumns:\n", NR, NF}' $filename && csvcut -n $filename
        else
            awk -F\t 'END {printf "Shape: (%s, %s)\nColumns:\n", NR, NF}' $filename && csvcut -n $filename
        fi
    # search able unique vals in col
    elif [ "$1" == "-u" ]; then
        csvcut $filename -c $3 | tail -n +2 | sort | uniq | fzf --reverse
    elif [ "$1" == "-n" ]; then
        csvstat $filename --null
    else
        echo 'Unknown args requested'
        exit 1
    fi
fi
