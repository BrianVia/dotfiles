#!/bin/bash

include_json=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
  --include-json)
    include_json=true
    shift
    ;;
  *)
    input_paths="$input_paths $1"
    shift
    ;;
  esac
done

# Remove leading whitespace
input_paths="${input_paths# }"

# Check if paths are provided
if [ -z "$input_paths" ]; then
  echo "Please provide a space-separated list of directory/file paths as an argument."
  echo "Example: ./script.sh path1/ path2/ file.js"
  exit 1
fi

# Detect shell and split paths accordingly
if [ -n "$ZSH_VERSION" ]; then
  # ZSH: Split on spaces
  set -A paths $(echo $input_paths) 2>/dev/null
else
  # Bash: Split on spaces
  read -r -a paths <<<"$input_paths" 2>/dev/null
fi

# Initialize an empty variable to store the file contents
file_contents=""

# Function to check if a file is in the explicit paths list
is_explicit_path() {
  local check_file="$1"
  for path in "${paths[@]}"; do
    path=$(echo "$path" | xargs)
    if [ "$path" = "$check_file" ]; then
      return 0 # True
    fi
  done
  return 1 # False
}

# Function to find project name based on .git or package.json
get_project_name() {
  local current_path="$1"
  local repo_name=""

  # If input is a file, start from its directory
  if [ -f "$current_path" ]; then
    current_path="$(dirname "$current_path")"
  fi

  # Ensure we have an absolute path to avoid issues with cd and relative paths
  # Check if the path exists before trying to cd
  if [ ! -e "$current_path" ]; then
    echo ""
    return 1
  fi
  # Suppress cd errors, check command success
  current_path_abs="$(cd "$current_path" 2>/dev/null && pwd)"
  if [ $? -ne 0 ] || [ -z "$current_path_abs" ]; then # cd failed or returned empty
    # echo "Warning: Could not resolve absolute path for $current_path" >&2
    echo ""
    return 1
  fi
  current_path="$current_path_abs"

  while [ "$current_path" != "/" ] && [ -n "$current_path" ]; do
    # Check for .git directory
    if [ -d "$current_path/.git" ]; then
      repo_name=$(git -C "$current_path" config --get remote.origin.url 2>/dev/null)
      if [ -n "$repo_name" ]; then
        # Extract name from URL (handles ssh and https)
        repo_name=$(basename "$repo_name" .git)
        # Handle potential user@host:path format for SSH
        if [[ "$repo_name" == *:* ]]; then
          repo_name="${repo_name##*:}"
        fi
        echo "$repo_name"
        return 0
      fi
      # If .git found but no remote, break and check package.json in same dir
      break
    fi

    # Check for package.json file
    if [ -f "$current_path/package.json" ]; then
      # Try jq first, then fallback to grep/sed
      if command -v jq &>/dev/null; then
        repo_name=$(jq -r '.name // empty' "$current_path/package.json" 2>/dev/null)
      else
        # More robust grep/sed fallback
        repo_name=$(grep -m 1 -o '"name": *"[^"]*"' "$current_path/package.json" | sed -n 's/.*"name": *"\([^"]*\)".*/\1/p')
      fi

      if [ -n "$repo_name" ]; then
        echo "$repo_name"
        return 0
      fi
      # If package.json found but no name, break
      break
    fi

    # Move up one directory
    parent_path="$(dirname "$current_path")"
    # Check if we reached the top or dirname returned the same path
    if [ "$parent_path" = "$current_path" ]; then
      break # Avoid infinite loop if dirname fails
    fi
    current_path="$parent_path"

    # If we've reached root, exit loop
    if [ "$current_path" = "/" ]; then
      break
    fi
  done

  # Check root ('/') last for package.json if loop finished without finding anything
  if [ -f "/package.json" ]; then
    if command -v jq &>/dev/null; then
      repo_name=$(jq -r '.name // empty' "/package.json" 2>/dev/null)
    else
      repo_name=$(grep -m 1 -o '"name": *"[^"]*"' "/package.json" | sed -n 's/.*"name": *"\([^"]*\)".*/\1/p')
    fi
    if [ -n "$repo_name" ]; then
      echo "$repo_name"
      return 0
    fi
  fi

  # Return empty if not found
  echo ""
  return 1
}

# Function to process a single path
process_path() {
  local path="$1"
  # local base_path="$path" # base_path seems unused now

  # Check if path exists
  if [ ! -e "$path" ]; then
    echo "Warning: Path '$path' does not exist." >&2
    return
  fi

  # Get the project name based on the input path
  local project_name=$(get_project_name "$path")
  local comment_prefix="//"
  if [ -n "$project_name" ]; then
    # Sanitize project_name slightly (replace spaces with underscores, etc.) - optional
    # project_name=$(echo "$project_name" | tr ' ' '_')
    comment_prefix+="$project_name/"
  fi

  if [ -d "$path" ]; then
    # Process directory
    # Use find starting from the absolute path to ensure consistency
    local abs_path
    abs_path="$(cd "$path" 2>/dev/null && pwd)"
    if [ $? -ne 0 ] || [ -z "$abs_path" ]; then
      echo "Warning: Could not process directory '$path'" >&2
      return
    fi

    while IFS= read -r -d '' file; do
      # Get path relative to the original input path for clarity if needed, but absolute path is less ambiguous
      # local relative_to_input="${file#"$abs_path/"}"
      # if [ "$abs_path" = "$file" ]; then relative_to_input=$(basename "$file"); fi # Handle case where path is file in root

      # Skip node_modules, .git, and binary files
      if [[ "$file" != *"/node_modules/"* ]] && [[ "$file" != *".git/"* ]] &&
        ! [[ "$file" =~ \.(png|jpg|jpeg|gif|svg|ico|webp|mp4|webm|mov|mp3|wav|ogg|woff|woff2|ttf|eot|pdf)$ ]]; then
        # Include JSON if explicitly specified or --include-json is set
        # Need to check original paths array for explicit specification
        local is_explicit=false
        if is_explicit_path "$file"; then is_explicit=true; fi

        if [[ "$file" != *.json ]] || $is_explicit || $include_json; then
          # Use the determined project name in the comment, followed by the absolute file path
          file_contents+="$comment_prefix$file\n"
          file_contents+="$(cat "$file")\n\n"
        fi
      fi
      # Use absolute path in find and exclude .git and node_modules there
    done < <(find "$abs_path" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -print0)
  elif [ -f "$path" ]; then
    # Process single file - get absolute path
    local abs_file_path
    local file_dir
    file_dir=$(dirname "$path")
    local base_name
    base_name=$(basename "$path")
    abs_file_path="$(cd "$file_dir" 2>/dev/null && pwd)/$base_name"
    if [ $? -ne 0 ] || [ ! -f "$abs_file_path" ]; then
      echo "Warning: Could not resolve absolute path for file '$path'" >&2
      abs_file_path="$path" # fallback to original path if absolute fails
    fi

    # Skip binary files, unless it's an explicitly passed JSON
    local is_explicit=false
    if is_explicit_path "$path"; then is_explicit=true; fi

    if ! [[ "$path" =~ \.(png|jpg|jpeg|gif|svg|ico|webp|mp4|webm|mov|mp3|wav|ogg|woff|woff2|ttf|eot|pdf)$ ]] ||
      ([[ "$path" == *.json ]] && ($is_explicit || $include_json)); then
      # Use the determined project name in the comment
      file_contents+="$comment_prefix$abs_file_path\n" # Use absolute path
      file_contents+="$(cat "$path")\n\n"              # Cat original path specified by user
    fi
  fi
}

# Process each path
for path in "${paths[@]}"; do
  # Remove leading/trailing whitespace
  path=$(echo "$path" | xargs)
  # Attempt to make path absolute early on? Might complicate relative paths user intended. Stick with processing as is.
  process_path "$path"
done

# Calculate estimated tokens (length divided by 4)
content_length=${#file_contents}
estimated_tokens=$((content_length / 4))

# Copy to clipboard
echo -n "$file_contents" | pbcopy 2>/dev/null || echo -n "$file_contents" | xclip -selection clipboard 2>/dev/null

# Output results
echo "Contents copied to clipboard - $content_length characters, $estimated_tokens tokens"
