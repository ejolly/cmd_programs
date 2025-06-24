#!/usr/bin/env python3
"""
Convert WorkFlowy bulleted notes to separated YYYY-MM-DD.md Obsidian style daily notes
for back up. This script has been tested exporting 1 month's worth of bullets into a single markdown file and then converting that single file. You can export a single
bullet and its nested contents by clicks the hamburger menu next to a bullet in 
Workflowy.

This script converts workflowy backlinks [link](workflowyURL) -> obsidian [[link]]
And removes the backlinks section that workflow adds to a bullet.
"""

import re
import os
from datetime import datetime
from pathlib import Path


def parse_date(date_str):
    """Convert date string like 'Thu, Jun 19' to '2025-06-19' format."""
    # Clean up the date string
    date_str = date_str.strip("﻿").strip()

    # Dictionary for month abbreviations
    months = {
        "Jan": 1,
        "Feb": 2,
        "Mar": 3,
        "Apr": 4,
        "May": 5,
        "Jun": 6,
        "Jul": 7,
        "Aug": 8,
        "Sep": 9,
        "Oct": 10,
        "Nov": 11,
        "Dec": 12,
    }

    # Parse the date
    match = re.match(r"(\w+),\s+(\w+)\s+(\d+)", date_str)
    if match:
        day_name, month_str, day = match.groups()
        month_num = months.get(month_str, 0)
        if month_num:
            # Assume 2025 for all dates
            return f"2025-{month_num:02d}-{int(day):02d}"
    return None


def format_date_header(date_str):
    """Convert date string to H1 header format."""
    # Clean up the date string
    date_str = date_str.strip("﻿").strip()

    # Add ordinal suffix to day
    match = re.match(r"(\w+),\s+(\w+)\s+(\d+)", date_str)
    if match:
        day_name, month_str, day = match.groups()
        day_int = int(day)

        # Add ordinal suffix
        if day_int in [1, 21, 31]:
            suffix = "st"
        elif day_int in [2, 22]:
            suffix = "nd"
        elif day_int in [3, 23]:
            suffix = "rd"
        else:
            suffix = "th"

        return f"{day_name}, {month_str} {day_int}{suffix}, 2025"
    return date_str


def convert_links(text):
    """Convert markdown links [text](url) to [[text]] format."""
    # Pattern to match markdown links
    pattern = r"\[([^\]]+)\]\([^)]+\)"

    def replace_link(match):
        link_text = match.group(1)
        return f"[[{link_text}]]"

    return re.sub(pattern, replace_link, text)


def process_file(input_file, output_dir):
    """Process the input file and create daily note files."""
    # Create output directory
    output_path = Path(output_dir)
    output_path.mkdir(exist_ok=True)

    with open(input_file, "r", encoding="utf-8") as f:
        lines = f.readlines()

    current_date = None
    current_date_filename = None
    current_content = []
    in_backlink_section = False

    for i, line in enumerate(lines):
        # Skip the title line
        if i == 0 and line.strip() == "June":
            continue

        # Check if this is a top-level date bullet
        if line.startswith("- ﻿﻿") and re.match(r"- ﻿﻿\w+,\s+\w+\s+\d+", line):
            # Save previous date's content if any
            if current_date and current_content:
                save_daily_note(
                    output_path, current_date_filename, current_date, current_content
                )

            # Extract new date
            date_str = line[4:].strip()  # Remove '- ﻿﻿' prefix
            current_date = date_str
            current_date_filename = parse_date(date_str)
            current_content = []
            in_backlink_section = False

        elif current_date:
            # Check if this is a backlink section
            if re.match(r"\s*- \d+ Backlink", line):
                in_backlink_section = True
            elif line.strip() and not line.startswith(" "):
                # Reset backlink flag if we're back to top level
                in_backlink_section = False

            # Add content if not in backlink section
            if not in_backlink_section and line.strip():
                # Remove the first level of indentation (2 spaces)
                if line.startswith("  "):
                    processed_line = line[2:]
                else:
                    processed_line = line

                # Convert links
                processed_line = convert_links(processed_line)

                current_content.append(processed_line.rstrip())

    # Save the last date's content
    if current_date and current_content:
        save_daily_note(
            output_path, current_date_filename, current_date, current_content
        )


def save_daily_note(output_path, filename, date_str, content):
    """Save content to a daily note file."""
    if not filename:
        return

    filepath = output_path / f"{filename}.md"

    # Format the header
    header = f"# {format_date_header(date_str)}\n"

    # Write the file
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(header)
        for line in content:
            f.write(line + "\n")

    print(f"Created: {filepath}")


if __name__ == "__main__":
    input_file = "june.md"
    output_dir = "daily-notes"

    process_file(input_file, output_dir)
    print("\nConversion complete!")
