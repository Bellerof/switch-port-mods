#!/bin/bash

# Script to compress parent folders of directories named "exefs" or "romfs"
# Usage: ./script.sh /path/to/search/directory

# Check if root directory is provided
ROOT_DIR="$1"
if [[ -z "$ROOT_DIR" ]]; then
  echo "Usage: $0 /path/to/root/directory"
  echo "This script will find all folders named 'exefs' or 'romfs' and compress their parent directories."
  exit 1
fi

# Check if root directory exists
if [[ ! -d "$ROOT_DIR" ]]; then
  echo "Error: Directory '$ROOT_DIR' does not exist."
  exit 1
fi

# Find all directories named "exefs" or "romfs" and process their parents
find "$ROOT_DIR" -type d \( -name "exefs" -o -name "romfs" -o -name "cheats" \) -print0 | while IFS= read -r -d '' target_dir; do
  # Get the parent directory
  parent_dir=$(dirname "$target_dir")
  parent_name=$(basename "$parent_dir")
  
  # Skip if parent is the root directory itself
  if [[ "$parent_dir" == "$ROOT_DIR" ]]; then
    echo "Skipping: $target_dir (parent is root directory)"
    continue
  fi
  
  # Get the directory where the parent folder is located
  parent_parent_dir=$(dirname "$parent_dir")
  
  # Create archive path in the same directory as the parent folder
  archive_path="$parent_parent_dir/$parent_name.7z"
  
  # Skip if archive already exists
  if [[ -f "$archive_path" ]]; then
    echo "Skipping: $parent_name (archive already exists: $archive_path)"
    continue
  fi
  
  echo "Found: $target_dir"
  echo "Compressing parent: $parent_dir -> $archive_path"
  
  # Create 7z archive with specified compression settings
  if (cd "$parent_parent_dir" && 7z a -t7z -mx=9 -m0=lzma2 -mmt=on -md=64m -mfb=273 -ms=on "$parent_name.7z" "$parent_name" >/dev/null 2>&1); then
    echo "✓ Successfully compressed: $parent_name.7z"
    
    # Optional: Remove original folder after successful compression
    # Uncomment the next two lines if you want to delete the original folders
    rm -rf "$parent_dir"
    echo "✓ Removed original folder: $parent_dir"
    
  else
    echo "✗ Error: Failed to compress $parent_dir"
  fi
  
  echo "----------------------------------------"
done

echo "Compression complete!"