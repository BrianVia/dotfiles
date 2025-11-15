#!/bin/bash

# Set the base directory containing your projects
base_directory="/Users/via/Development/Dfinitiv"

# Set your name or email for filtering commits
author_name="Your Name"

# Set the time range for commits (e.g., "1 day ago", "2 days ago", "3 hours ago")
time_range="1 day ago"

# Loop through each directory in the base directory
for directory in "$base_directory"/*; do
    # Check if the current item is a directory
    if [ -d "$directory" ]; then
        # Extract the directory name
        project_name=$(basename "$directory")
        
        # Check if the directory is a Git repository
        if [ -d "$directory/.git" ]; then
            # Navigate to the directory
            cd "$directory"
            
            # Run the git log command and concatenate the results
            echo "Commits for $project_name:"
            git log --author="$author_name" --since="$time_range" 
            
            echo "------------------------"
            
            # Navigate back to the base directory
            cd "$base_directory"
        fi
    fi
done