#!/bin/bash
# Quick program to render .ipynb files to markdown and then html and view in terminal using lynx browser
set -eu

readonly EX_USAGE=64
readonly EX_NOINPUT=66

usage() {
    echo "Render the contents of a jupyter notebook in the terminal"
    echo "Usage: $(basename "$0") <notebook>"
}

if [ $# -ne 1 ]; then
    usage
    exit $EX_USAGE
fi

if [ "$1" = -h ] || [ "$1" = --help ]; then
    usage
    exit
fi

if [ ! -f "$1" ]; then
    echo "$(basename "$0"): $1: No such file"
    exit $EX_NOINPUT
fi

jupyter nbconvert --stdout --to markdown "$1" 2>/dev/null | bat -l markdown --theme=TwoDark
# jupyter nbconvert --stdout --to markdown "$1" 2>/dev/null | pandoc -f markdown_mmd -t html | lynx -stdin -vikeys
