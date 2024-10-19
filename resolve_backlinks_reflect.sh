#!/bin/bash

# Ensure the script exits on any error
set -e

# Folder containing the daily notes
DAILY_NOTES_DIR="notes/daily-notes"
NOTES_DIR="notes"  # Root directory containing all notes with random IDs

# Function to extract wiki-links while ignoring the "## Backlinks" section
extract_links() {
    awk '
    BEGIN { in_backlinks = 0 }
    # Detect start of "## Backlinks" section
    /^## Backlinks/ { in_backlinks = 1; next }
    # Detect the end of the Backlinks section or any other section
    /^## / && in_backlinks { in_backlinks = 0; next }
    # Process lines only if not inside the Backlinks section
    !in_backlinks {
        # Loop to extract multiple [[wiki-links]] on the same line
        while ($0 ~ /\[\[[^]]+\]\]/) {
            # Extract the wiki-link name
            link = substr($0, match($0, /\[\[[^]]+\]\]/) + 2, RLENGTH - 4)
            print link
            # Remove the first occurrence of the link to find more on the same line
            sub(/\[\[[^]]+\]\]/, "", $0)
        }
    }' "$1"
}

# Function to find a note file by name, ignoring the random ID
find_note_file() {
    local base_name="$1"
    
    # Normalize the base_name by removing leading/trailing whitespace
    base_name=$(echo "$base_name" | xargs)

    # Search for a file with a matching base name (before the random ID)
    # Use 'printf' to handle filenames with special characters and emojis correctly
    find "$NOTES_DIR" -type f -name "*${base_name}*.md" | head -n 1
}

# Get a list of all markdown files in the daily notes directory, sorted by date
daily_notes=($(ls "$DAILY_NOTES_DIR"/*.md | sort -r))

# Loop through all daily notes in sorted order (most recent first)
for note_file in "${daily_notes[@]}"; do
    # Extract the filename (without path) to use as a backlink reference
    note_name=$(basename "$note_file" .md)

    # Extract all wiki-links from the note, ignoring any inside "## Backlinks"
    extract_links "$note_file" | while read -r linked_note; do
        # Find the corresponding file, ignoring the random ID in its name
        linked_note_file=$(find_note_file "$linked_note")

        # Skip if the linked note doesn't exist
        if [[ -z "$linked_note_file" ]]; then
            echo "Warning: Linked note matching '$linked_note' not found. Skipping."
            continue
        fi

        # Find the first occurrence of the wiki-link for context extraction
        line_num=$(grep -n "\[\[${linked_note}\]\]" "$note_file" | head -n 1 | cut -d: -f1)

        # Extract only 3 lines of context after the line with the backlink
        start_line=$((line_num))
        end_line=$((line_num + 3))

        # Extract the context lines from the original note
        context=$(sed -n "${start_line},${end_line}p" "$note_file")

        # Prepare the backlink text to be appended
        backlink_heading="## Backlinks"
        backlink_entry="### [[${note_name}]]"
        backlink_blockquote=$(echo "$context" | sed 's/^/> /')

        # Construct the full backlink content to search for and append
        full_backlink_content="${backlink_entry}\n${backlink_blockquote}"

        # Check if the Backlinks section already exists in the linked note
        if ! grep -q "^${backlink_heading}" "$linked_note_file"; then
            echo -e "\n${backlink_heading}" >> "$linked_note_file"
        fi

        # Check if the exact backlink entry already exists to avoid duplicates
        if ! grep -Fq "${full_backlink_content}" "$linked_note_file"; then
            # Append the backlink entry and the relevant context in a blockquote
            echo -e "\n${full_backlink_content}" >> "$linked_note_file"
        fi
    done
done

echo "Backlinks resolved successfully."
