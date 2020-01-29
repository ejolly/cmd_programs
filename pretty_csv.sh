#!/bin/bash

# Pretty display a csv file in the terminal
# Can definitely be refactored cause it's messy and we don't infer comma or tab separated
# Aliased to csv [filename]
if [ "$1" == "-t" ]; then
	# Force reading filing as tab-separated (usually not needed)
	perl -pe 's/((?<=\t)|(?<=^))\t/ \t/g;' "$2" | column -t -s $'\t' | exec less  -F -S -X -K
elif [ "$1" == "-th" ]; then
	# -t but print first 10 lines only
	perl -pe 's/((?<=\t)|(?<=^))\t/ \t/g;' "$2" | column -t -s $'\t' | exec head -n 10
elif [ "$1" == "-ts" ]; then
	# -t but get the shape of the csv file
	awk -F\t 'END {printf "NRows: %s\nNCols: %s\nColNames: ", NR, NF}' "$2" && awk -F\t 'NR==1 {print; exit}' "$2"
elif [ "$1" == "-h" ]; then
	# Assume reading as comma-separated and print first 10 lines only
	perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$2" | column -t -s, | exec head -n 10
elif [ "$1" == "-s" ]; then
	# Get the shape of the csv file
	awk -F, 'END {printf "NRows: %s\nNCols: %s\nColNames: ", NR, NF}' "$2" && awk -F, 'NR==1 {print; exit}' "$2"
elif [ "$1" == "--help" ] || [ $# -eq 0 ]; then
	# help
	printf "Display a csv file in the terminal nicely with interactive pagination.\n\nUsage csv file.csv\n\nOptional flags:\n-h print the Head of the file (first 10 rows)\n-s print the Shape and column names\n-t prepend to other flags (e.g. -th) to force Tab-separated file reading; try it if output looks wonky\n"
else	
	perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$1" | column -t -s, | exec less  -F -S -X -K
fi
