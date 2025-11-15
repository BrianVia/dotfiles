#!/bin/bash

# Get all files changed on the current git branch
changed_files=$(git diff --name-only HEAD)

# Initialize an empty variable to store the file contents
file_contents=""

# Iterate over each changed file
while IFS= read -r file; do
  # Check if the file exists
  if [ -f "$file" ]; then
    # Add the relative file name as a comment at the top
    file_contents+="// $file\n"
    
    # Append the file contents
    file_contents+="$(cat "$file")\n\n"
  fi
done <<< "$changed_files"

# Copy the file contents to the clipboard
echo -n "$file_contents" | pbcopy
