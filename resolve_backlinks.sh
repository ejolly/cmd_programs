#!/bin/bash

# Bash script that should be run on a markdown export of all notes from Craft
# will go through and resolve backlinks by editing each note and adding a backlinks section
# should be safe to run more than once on the same folder without duplicating backlinks
# see this chatgpt convo for more: https://chatgpt.com/share/67142d69-6c1c-8013-974a-b58511a97586

# Ensure the script exits on any error
set -e

# Folder containing the markdown notes (passed as the first argument)
NOTES_DIR=$1

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
            # Extract the wiki-link using match and substr
            link = substr($0, match($0, /\[\[[^]]+\]\]/) + 2, RLENGTH - 4)
            print link
            # Remove the first occurrence of the link to find more on the same line
            sub(/\[\[[^]]+\]\]/, "", $0)
        }
    }' "$1"
}

# Loop through all markdown files in the given directory recursively
find "$NOTES_DIR" -name "*.md" | while read -r note_file; do
    # Extract the filename (without path) to use as a link reference
    note_name=$(basename "$note_file" .md)

    # Extract all wiki-links from the note, ignoring any inside "## Backlinks"
    extract_links "$note_file" | while read -r linked_note; do
        # Replace slashes to match filenames (if nested directories are used)
        linked_note_file="$NOTES_DIR/${linked_note}.md"

        # Skip if the linked note doesn't exist
        if [[ ! -f "$linked_note_file" ]]; then
            echo "Warning: Linked note '$linked_note_file' not found. Skipping."
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
