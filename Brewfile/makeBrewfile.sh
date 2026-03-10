#!/bin/zsh

# Get the directory where this script is located
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
BREWFILE_PATH="$SCRIPT_DIR/Brewfile"

# Remove existing Brewfile
rm -f "$BREWFILE_PATH"

# Generate new Brewfile
brew bundle dump --file="$BREWFILE_PATH"

# Sort the Brewfile
sort -u "$BREWFILE_PATH" -o "$BREWFILE_PATH" -r
