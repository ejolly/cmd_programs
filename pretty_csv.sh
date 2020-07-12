#!/bin/bash

# Pretty display a csv file in the terminal
# Relies on visidata https://jsvine.github.io/intro-to-visidata/the-big-picture/installation/
# And csvkit https://csvkit.readthedocs.io/en/latest/index.html
# pip install visidata csvkit
# Aliased to csv [filename]
if [ "$1" == "--help" ] || [ $# -eq 0 ]; then
    echo "
    Get basic stats or interactively display a csv file in the terminal

    Usage: csv filename

    Options:
        -h      print the first 10 rows of the file
        -s      print the number of rows, columns, and column names
        -n      check for null values in any column
        -i      fuzzy searchable file contents 
        -d      describe all columns; pass in colname,colname2... to describe specific columns
        -u      [column] searchable unique values in column

    Also checkout csvkit:
        csvcut      extract specific info from csv file
        csvlook     pretty print file contents (non-interactive)
        csvstat     column-wise statistics

    And visidata:
       It's used for the interactive display when no flags are passed.
       It can do basic data aggregation and plotting.
    Docs:
        https://www.visidata.org/docs/
    "
elif [ $# -eq 1 ]; then
    if [[ "$1" == "-"* ]]; then
        echo "file name required"
        exit 1
    else
        vd $1
    fi
elif [ $# -eq 2 ]; then
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
    elif [ "$1" == "-n" ]; then
        csvstat $filename --null
    elif [ "$1" == "-i" ]; then
        csvlook $filename | fzf --reverse
    elif [ "$1" == "-d" ]; then
        csvstat $filename
    elif [ "$1" == "-u" ]; then
        echo "
        column name required
        Usage:
            csv -u [column] [file]
        "
    else
        echo 'Unknown args requested'
        exit 1
    fi
elif [ $# -eq 3 ]; then
    filename=$(basename -- $3)
    extension="${filename##*.}"
    colname=$2
    if [ "$1" == "-u" ]; then
        csvcut $filename -c $colname | tail -n +2 | sort | uniq | fzf --reverse
    elif [ "$1" == "-d" ]; then
        csvstat -c $colname $filename
    else
        echo 'Unknown args requested'
        exit 1
    fi
else
    echo 'Too many arguments passed!'
    exit 1
fi
