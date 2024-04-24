#!/bin/bash

# Define target directory
target_dir="$HOME/blueline"

# Make sure the target directory exists
mkdir -p "$target_dir"

# Define array of repositories and target paths
repos=(
  "https://github.com/KanishkTheDerp/device_google_crosshatch device/google/crosshatch"
  "https://github.com/LineageOS/android_device_google_gs-common device/google/gs-common"
  "https://android.googlesource.com/device/sample device/sample"
  "https://github.com/LineageOS/android_hardware_qcom_sdm845_display hardware/qcom/sdm845/display"
  "https://github.com/LineageOS/android_hardware_qcom_sdm845_gps hardware/qcom/sdm845/gps"
  "https://github.com/LineageOS/android_hardware_qcom_sdm845_media hardware/qcom/sdm845/media"
  "https://github.com/LineageOS/android_packages_apps_ElmyraService packages/apps/ElmyraService"
  "https://github.com/LineageOS/android_kernel_google_msm-4.9 kernel/google/msm-4.9"
  "https://github.com/TheMuppets/proprietary_vendor_google_blueline vendor/google/blueline"
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
