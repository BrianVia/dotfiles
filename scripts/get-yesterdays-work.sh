#!/bin/bash

# Change to the specified directory
cd ~/Development/Dfinitiv/

# Get the date 24 hours ago in ISO 8601 format
date_24h_ago=$(date -v-1d +"%Y-%m-%dT%H:%M:%S")

# Initialize an empty string to store the output
output=""

# Loop through all directories
for dir in */; do
    # Check if the directory contains a .git folder
    if [ -d "${dir}.git" ]; then
        # Change to the directory
        cd "$dir"
        
        # Run git log command for commits in the last 24 hours and append the output
        commits=$(git log --author="Brian Via" --since="$date_24h_ago" --oneline)
        
        # If there are commits, add them to the output
        if [ ! -z "$commits" ]; then
            output+="Commits in ${dir%/} in the last 24 hours:\n"
            output+="$commits"
            output+="\n\n"
        fi
        
        # Change back to the parent directory
        cd ..
    fi
done

# Print the final output
echo -e "$output"

# If there's no output, print a message
if [ -z "$output" ]; then
    echo "No commits by Brian Via in the last 24 hours in any project."
fi