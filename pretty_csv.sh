#!/bin/bash

# Pretty display a csv file in the terminal. Use -c if comma seperated
# Aliased to csv [filename]
if [ "$1" == "-c" ]; then
	# If we get the -c flag, assume comma separted
	perl -pe 's/((?<=,)|(?<=^)),/ ,/g;' "$2" | column -t -s, | exec less  -F -S -X -K
elif [ "$1" == "-h" ]; then
	# help
	echo "Display a csv file in the terminal. Use the -c flag if the file is comma seperated, otherwise assumes tab separated."
else
	# Otherwise assume tab separated
	perl -pe 's/((?<=\t)|(?<=^))\t/ \t/g;' "$1" | column -t -s $'\t' | exec less  -F -S -X -K
fi
