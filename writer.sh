# Launch a file with iaWriter from the command line
# Aliased to ia [filename]
if [[ -z $1 ]]; then
	echo "Usage: writer FILE"
else
# check if first character is a slash
	if [[ "$1" = /* ]]
	then
		# specified path is absolute
		open "${1}" -a"iA Writer"
	else
		# specified path is relative
		open "${PWD}/$1" -a"iA Writer"
	fi
fi
