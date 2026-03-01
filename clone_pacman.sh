#!/bin/bash
WORKSPACE="$HOME/pacman"
BASE_URL="https://github.com/Nothing-2A"
echo "Setting up workspace at $WORKSPACE..."
mkdir -p "$WORKSPACE"
cd "$WORKSPACE" || { echo "Error: Failed to navigate to $WORKSPACE"; exit 1; }
echo "Starting mapped cloning operations..."
REPOS="
android_device_nothing_Aerodactyl          device/nothing/Aerodactyl
android_device_nothing_Aerodactyl-kernel   device/nothing/Aerodactyl-kernel
proprietary_vendor_nothing_Aerodactyl      vendor/nothing/Aerodactyl
proprietary_vendor_nothing_Pacman          vendor/nothing/Pacman
proprietary_vendor_nothing_PacmanPro       vendor/nothing/PacmanPro
android_device_mediatek_sepolicy_vndr      device/mediatek/sepolicy_vndr
android_hardware_mediatek                  hardware/mediatek
android_packages_apps_ParanoidGlyph        packages/apps/ParanoidGlyph
android_packages_apps_GlyphAdapter         packages/apps/GlyphAdapter
"
echo "$REPOS" | while read -r REPO TARGET_PATH; do
    if [ -z "$REPO" ]; then continue; fi
    
    echo "--------------------------------------------------------"
    echo "Cloning $REPO"
    echo "Target: $TARGET_PATH"
    git clone "$BASE_URL/$REPO.git" "$TARGET_PATH"
    
    if [ $? -eq 0 ]; then
        echo "✅ Success!"
    else
        echo "❌ Failed to clone $REPO into $TARGET_PATH."
    fi
done

echo "--------------------------------------------------------"
echo "All clone operations finished. Your device trees are in place."
