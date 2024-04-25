#!/bin/bash

# Define target directory
target_dir="$HOME/yunluo"

# Make sure the target directory exists
mkdir -p "$target_dir"

# Define array of repositories and target paths
repos=(
  "https://github.com/KanishkTheDerp/device_xiaomi_yunluo device/xiaomi/yunluo"
  "https://github.com/xiaomi-mt6789-devs/android_device_xiaomi_yunluo-kernel device/xiaomi/yunluo-kernel"
  "https://github.com/KanishkTheDerp/device_mediatek_sepolicy_vndr device/mediatek/sepolicy_vndr"
  "https://github.com/LineageOS/android_hardware_xiaomi hardware/xiaomi"
  "https://github.com/KanishkTheDerp/hardware_mediatek hardware/mediatek"
  "https://github.com/xiaomi-mt6789-devs/android_vendor_xiaomi_yunluo vendor/xiaomi/yunluo"
)

# Clone each repository into the target directory
for repo in "${repos[@]}"; do
  url=$(echo "$repo" | cut -d' ' -f1)
  target=$(echo "$repo" | cut -d' ' -f2-)
  destination="$target_dir/$target"
  echo "Cloning $url into $destination..."
  if [[ "$repo" == *"-b "* ]]; then
    branch=$(echo "$repo" | grep -oP '(?<=-b\s).*' | awk '{print $1}')
    git clone --branch "$branch" "$url" "$destination"
  else
    git clone "$url" "$destination"
  fi
done
