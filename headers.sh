#!/bin/bash

# Base source directory
BASE_SOURCE_DIR="$HOME/headers/kernel-headers/"

# Source directories
SOURCE_DIRS=("arch/" "crypto/" "fs/" "include/" "lib/" "scripts/" "security/" "usr/")

# Destination directory
BASE_DEST_DIR="$HOME/yunluo/device/xiaomi/yunluo-kernel/kernel-headers/"
DEST_DIRS=("arch/" "crypto/" "fs/" "include/" "lib/" "scripts/" "security/" "usr/")

# Function to copy directory
copy_directory() {
  local SRC_DIR=$1
  local DEST_DIR=$2

  # Check if source directory exists
  if [ ! -d "$SRC_DIR" ]; then
    echo "Source directory $SRC_DIR does not exist."
    exit 1
  fi

  # Create destination directory if it doesn't exist
  if [ ! -d "$DEST_DIR" ]; then
    mkdir -p "$DEST_DIR"
  fi

  # Copy files from source to destination
  cp -r "$SRC_DIR"* "$DEST_DIR"

  # Verify success
  if [ $? -eq 0 ]; then
    echo "Files successfully copied from $SRC_DIR to $DEST_DIR."
  else
    echo "Error copying files from $SRC_DIR to $DEST_DIR."
    exit 1
  fi
}

# Copy each source directory to the destination
for ((i=0;i<${#SOURCE_DIRS[@]};++i)); do
  copy_directory "${BASE_SOURCE_DIR}${SOURCE_DIRS[i]}" "${BASE_DEST_DIR}${DEST_DIRS[i]}"
done
