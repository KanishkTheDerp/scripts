#!/bin/bash

# clear out screen
clear

# Define colors
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
green='\e[0;32m'

# Function to display a message in green
green_message() {
  echo -e "$green$1$white"
}

# Function to display a message in yellow
yellow_message() {
  echo -e "$yellow$1$white"
}

# Function to display a message in red
red_message() {
  echo -e "$red$1$white"
}

{
echo
green_message "Script to test kernel compilation for OnePlus SM8150 devices."
sleep 1s
}

clean() {
  echo
  # Clean out residuals
  red_message "<< Clean out residuals!! >>"
  sleep 1s
  echo
  rm -rf out/
  green_message "<< Residuals Cleaned!! >>"
}

# Input branch name and folder name
branch='master'
folder='msm-4.14'
repo_link='https://github.com/oneplus-sm8150/kernel_oneplus_sm8150'
green_message "File will be saved in $HOME/$folder"

sleep 1s

# Check if the folder already exists
if [ -d "$HOME/$folder" ]; then
        echo
        yellow_message "This $HOME/$folder is already saved, nothing to clone!"
        cd $HOME/$folder
        clean
        echo
else
        yellow_message "Downloading your files from $repo_link from branch $branch....."
        echo
        git clone --recurse-submodules $repo_link -b "$branch" $HOME/$folder
        cd $HOME/$folder
        yellow_message "Your files have been successfully saved in $HOME/$folder"
        echo
        sleep 1s
fi

# Configure build information
DEVICE="OnePlus 7"
CODENAME="guacamoleb"
KERNEL_NAME="Perseverance"
KERNEL_VER="4.14"
echo
yellow_message "Device Name is $DEVICE and Kernel Name is $KERNEL_NAME"
sleep 1s
echo

# Define Your DEFCONFIG
DEFCONFIG="sm8150_defconfig"
yellow_message "Your DEFCONFIG is $DEFCONFIG"
sleep 1s
echo

# Define KBUILD Information
HOST="DerpGang"
USER="Kanishk"
yellow_message "Host Build Set to \nHOST=$HOST and USER=$USER"
sleep 1s
echo

# Define Toolchain
# 1.clang
# 2.GCC
# Define according tou your Kernel Source
TOOLCHAIN="clang"
CLANG_NAME="Clang_19"
TOOLCHAIN_SOURCE="https://bitbucket.org/shuttercat/clang"

GCC_Source_32="https://github.com/mvaisakh/gcc-arm"
GCC_Source_64="https://github.com/mvaisakh/gcc-arm64"

# Automation for toolchain and gcc builds
if [ "$TOOLCHAIN" == "gcc" ]; then
    if [ ! -d "$HOME/gcc64" ] && [ ! -d "$HOME/gcc32" ]; then
      yellow_message "Your Choose $TOOLCHAIN"
      echo
      sleep 1s
      green_message "<< Cloning GCC from arter >>"
      git clone --depth=1 "$GCC_Source_64" "$HOME/gcc64"
      git clone --depth=1 "$GCC_Source_32" "$HOME/gcc32"
    fi
    export PATH="$HOME/gcc64/bin:$HOME/gcc32/bin:$PATH"
    export STRIP="$HOME/gcc64/aarch64-elf/bin/strip"
    export KBUILD_COMPILER_STRING=$("$HOME/gcc64/bin/aarch64-elf-gcc" --version | head -n 1)
elif [ "$TOOLCHAIN" == "clang" ]; then
    if [ ! -d "$HOME/Clang_19" ]; then
      yellow_message "Your Chosen Toolchain is $TOOLCHAIN"
      echo
      sleep 1s
      green_message "<< Cloning Clang 19 >>"
      git clone -b 14 "$TOOLCHAIN_SOURCE" "$HOME/Clang_19"
    fi
    export PATH="$HOME/Clang_19/bin:$PATH"
    export STRIP="$HOME/Clang_19/aarch64-linux-gnu/bin/strip"
    export KBUILD_COMPILER_STRING=$("$HOME/Clang_19/bin/clang" --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:>]//g')
fi

# Function to build the kernel
build_kernel() {
        green_message "Executing kernel Build..."
        sleep 1s
        echo
        echo "Your Kernel Version is $KERNEL_VER"
        echo
        sleep 1s
        Start=$(date +"%s")

        if [ "$TOOLCHAIN" == "clang" ]; then
                make -j$(nproc --all) O=out \
                ARCH=arm64 \
                CC=clang \
                AR=llvm-ar \
                NM=llvm-nm \
                LD=ld.lld \
                STRIP=llvm-strip \
                OBJCOPY=llvm-objcopy \
                OBJDUMP=llvm-objdump \
                OBJSIZE=llvm-size \
                READELF=llvm-readelf \
                HOSTCC=clang \
                HOSTCXX=clang++ \
                HOSTAR=llvm-ar \
                CROSS_COMPILE=aarch64-linux-gnu- \
                CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
                CONFIG_DEBUG_SECTION_MISMATCH=y \
                CONFIG_NO_ERROR_ON_MISMATCH=y 2>&1 | tee out/error.log
        elif [ "$TOOLCHAIN" == "gcc" ]; then
                make -j$(nproc --all) O=out \
                ARCH=arm64 \
                CROSS_COMPILE=aarch64-elf- \
                CROSS_COMPILE_ARM32=arm-eabi- 2>&1 | tee out/error.log
        fi

        End=$(date +"%s")
        Diff=$(($End - $Start))
}

# Define kernel Image location
export IMG="out/arch/arm64/boot/Image.lz4-dtb"

# Define Arch
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

# Define KBUILD HOST and USER
export KBUILD_BUILD_HOST="$HOST"
export KBUILD_BUILD_USER="$USER"

# Pre-configured Actions
green_message "Creating workspace for Kernel. Please Wait!"
echo
sleep 1s
mkdir -p out/
yellow_message "<< Copying DTS Files!! >>"
echo
sleep 1s
mkdir -p out/arch/arm64/
cp -r arch/arm64/boot out/arch/arm64/
mkdir -p out/arch/arm64/boot/dts/qcom
cp arch/arm64/boot/dts/qcom/*.dts* out/arch/arm64/boot/dts/qcom/
green_message "<< DTS copied successfully!! >>"
echo
sleep 1s

make O=out clean && make O=out mrproper
make "$DEFCONFIG" O=out -j$(nproc --all)

# Execute kernel Building Action
yellow_message "<< Compiling the kernel >>"
echo
sleep 1s
build_kernel || error=true
DATE=$(date +"%Y%m%d-%H%M%S")
KERVER=$(make kernelversion)
        green_message "<< Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >>"
        sleep 2s
        echo
