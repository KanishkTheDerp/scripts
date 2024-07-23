#!/bin/bash

# Source directory
SOURCE_DIR="$HOME/5.10/out/android12-5.10/dist"

# Source files
SOURCE_IMAGE="$SOURCE_DIR/Image.gz"
SOURCE_MODULES="$SOURCE_DIR/*.ko"
SOURCE_DTB="$SOURCE_DIR/mt6789.dtb"

# Destination directories
DEST_IMAGE_DIR="$HOME/yunluo/device/xiaomi/yunluo-kernel/"
DEST_MODULES_DIR="$HOME/yunluo/device/xiaomi/yunluo-kernel/modules/"
DEST_DTB_DIR="$HOME/yunluo/device/xiaomi/yunluo-kernel/dtb/"

# Function to check if a directory exists and create it if it doesn't
check_and_create_dir() {
  local DIR=$1
  if [ ! -d "$DIR" ]; then
    echo "Destination directory $DIR does not exist. Creating it..."
    mkdir -p "$DIR"
  fi
}

# Copy the Image.gz file
if [ -f "$SOURCE_IMAGE" ]; then
  check_and_create_dir "$DEST_IMAGE_DIR"
  cp "$SOURCE_IMAGE" "$DEST_IMAGE_DIR"
  if [ $? -eq 0 ]; then
    echo "File successfully copied from $SOURCE_IMAGE to $DEST_IMAGE_DIR."
  else
    echo "Error copying file $SOURCE_IMAGE."
    exit 1
  fi
else
  echo "Source file $SOURCE_IMAGE does not exist."
  exit 1
fi

# Copy all .ko files
check_and_create_dir "$DEST_MODULES_DIR"
for MODULE in $SOURCE_MODULES; do
  if [ -f "$MODULE" ]; then
    cp "$MODULE" "$DEST_MODULES_DIR"
    if [ $? -eq 0 ]; then
      echo "File successfully copied from $MODULE to $DEST_MODULES_DIR."
    else
      echo "Error copying file $MODULE."
      exit 1
    fi
  else
    echo "No .ko files found in $SOURCE_DIR."
  fi
done

# Copy the mt6789.dtb file
if [ -f "$SOURCE_DTB" ]; then
  check_and_create_dir "$DEST_DTB_DIR"
  cp "$SOURCE_DTB" "$DEST_DTB_DIR"
  if [ $? -eq 0 ]; then
    echo "File successfully copied from $SOURCE_DTB to $DEST_DTB_DIR."
  else
    echo "Error copying file $SOURCE_DTB."
    exit 1
  fi
else
  echo "Source file $SOURCE_DTB does not exist."
  exit 1
fi
