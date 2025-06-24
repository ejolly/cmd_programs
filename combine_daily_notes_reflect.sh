#!/bin/bash

# Define the output file
output_file="📖 Log.md"

# Clear contents
> "$output_file"

# Function to format the date
format_date() {
  date -j -f "%Y-%m-%d" "$1" +"%a, %b %dth, %Y"
}

# Get sorted list of files
files=($(ls daily-notes/*.md | sort -r))

# Loop through each markdown file in the daily-notes directory
for i in "${!files[@]}"; do
  file="${files[$i]}"
  
  # Extract the filename without the extension
  filename=$(basename "$file" .md)
  
  # Convert the filename to the desired date format
  formatted_date=$(format_date "$filename") 

  # Add the H2 heading with the formatted date to the output file
  echo -e "## $formatted_date" >> "$output_file"
  
  # Add the contents of the file starting from the 3rd line to the output file
  tail -n +3 "$file" >> "$output_file"

  # Add a newline if it's not the last file
  if [[ $i -lt $((${#files[@]} - 1)) ]]; then
    echo >> "$output_file"
  fi
done

echo "Combined notes have been saved to $output_file"
