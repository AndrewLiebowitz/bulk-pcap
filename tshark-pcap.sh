#!/bin/bash

# --- Configuration ---

# Set the base directory where the SMB share is mounted.
# IMPORTANT: Replace this path if it differs slightly on your system.
#            Use 'df -h' or 'mount' to verify the exact mount point.

BASE_DIR="/run/user/$(id -u)/gvfs/smb-share:server=nas1,share=bravoshare/pcaps/"

# Alternatively, if the path structure is slightly different:
# BASE_DIR="/run/media/$(whoami)/smb-share:server=nas1,share=bravoshare/pcaps/"
# Or just the direct path if known and stable:
# BASE_DIR="/path/to/your/mount/point/pcaps/"


# Define the subdirectories to process (named "1" through "7").
# Bash brace expansion {1..7} creates the sequence 1 2 3 4 5 6 7.

SUBDIRS_TO_PROCESS=({1..7})

# --- Script Logic ---

echo "--- Starting tshark processing script ---"
echo "Base Directory: $BASE_DIR"

# Check if the base directory exists
if [ ! -d "$BASE_DIR" ]; then
  echo "ERROR: Base directory '$BASE_DIR' not found or is not a directory."
  echo "Please verify the mount point and update the BASE_DIR variable in the script."
  exit 1 # Exit with an error status
fi

# Check if tshark command exists
if ! command -v tshark &> /dev/null; then
    echo "ERROR: 'tshark' command not found. Please install tshark (usually part of the Wireshark package)."
    exit 1 # Exit with an error status
fi

# Loop through each specified subdirectory number
for dir_num in "${SUBDIRS_TO_PROCESS[@]}"; do
  # Construct the full path to the subdirectory
  current_subdir="$BASE_DIR/$dir_num"
  echo # Add a blank line for readability
  echo "--- Processing Subdirectory: $current_subdir ---"

  # Check if the subdirectory actually exists and is a directory
  if [ -d "$current_subdir" ]; then

    # Find all files within the current subdirectory.
    # Using 'find' is generally safer than a simple glob (*) if there are
    # many files or files with unusual names, but a glob is simpler here.
    # We use '-maxdepth 1' to only get files directly within this folder,
    # not in further subfolders. '-type f' ensures we only process files.
    find "$current_subdir" -maxdepth 1 -type f | while IFS= read -r file_path; do
      # Check if the found item is actually a file (redundant with find -type f, but safe)
      if [ -f "$file_path" ]; then
        # Extract the filename from the full path
        filename=$(basename "$file_path")

        # Construct the output filename by appending .txt
        # The output file will be placed in the *same* directory as the input file.
        output_file="$current_subdir/${filename}.txt"

        echo "Processing file: $filename"

        # --- The Core Command ---
        # Run tshark:
        # -r "$file_path" : Read from the specified input file path. Using full path.
        # -q              : Quiet mode - suppresses packet summary output during capture.
        # -z io,phs       : Collect Protocol Hierarchy Statistics ('phs') under the 'io' statistics menu.
        # > "$output_file": Redirect the standard output (the statistics table) to the output file.
        #                   This will OVERWRITE the output file if it already exists.
        tshark -r "$file_path" -q -z io,phs > "$output_file"

        # Optional: Check the exit status of tshark
        if [ $? -ne 0 ]; then
          echo "WARNING: tshark command failed for file: $filename (Exit status: $?)"
          # You might want to remove the potentially incomplete output file
          # rm -f "$output_file"
        else
          echo " -> Output saved to: ${filename}.txt"
        fi

      fi # end check if it's a file
    done # end loop through files in subdirectory

  else
    # Print a warning if a specific subdirectory doesn't exist
    echo "WARNING: Subdirectory '$current_subdir' not found. Skipping."
  fi # end check if subdirectory exists

done # end loop through specified subdirectory numbers

echo # Add a blank line for readability
echo "--- Script finished ---"

exit 0 # Exit successfully
