#!/bin/bash

# clear out screen
clear

# banner(){
# echo "#####################################"
# echo "#                                   #"
# echo "# Made By: CYKEEK & Kanishk         #"
# echo "# Build Script                      #"
# echo "# For msm-4.9 kernels               #"
# echo "#                                   #"
# echo "#####################################"
# echo
# }

export base='/home/kanishkthederp'
echo "Base directory has been set to $base."

clean() {
  # Clean out residuals
  echo "Cleaning residuals."
  sleep 1s
  rm -rf $base/$folder/out
  rm -rf $base/AnyKernel3
  rm -rf $base/kernel_zips
  echo "Finished cleaning up."
}

# Input branch name and folder name
branch='ksu/master'
folder='msm-4.9'
repo_link='https://github.com/KanishkTheDerp/msm-4.9'
echo "File will be saved in $base/$folder"

sleep 1s

# Check if the folder already exists
if [ -d "$base/$folder" ]; then
        echo "$base/$folder is already present, nothing to clone."
        cd $base/$folder
        clean
else
        echo "Downloading your files from $repo_link on branch $branch."
        git clone --recurse-submodules $repo_link -b "$branch" $base/$folder
        cd $base/$folder
        echo "Your files have been successfully saved in $base/$folder."
        sleep 1s
fi

# Configure build information
DEVICE="Google Pixel 3/3XL"
CODENAME="bluecross"
KERNEL_NAME="Streamline"
KERNEL_VER="4.9"
echo "Your device name is $DEVICE ($CODENAME), kernel name is $KERNEL_NAME."
sleep 1s

# Define Your DEFCONFIG
DEFCONFIG="b1c1_defconfig"
echo "Selected default configuration file is $DEFCONFIG."
sleep 1s

# Define Your AnyKernel Links
AnyKernel="https://github.com/Cykeek-Labs/AnyKernel3"
AnyKernelbranch="blueline"
echo "AnyKernel3 is set to $AnyKernel on branch $AnyKernelbranch."
sleep 1s

# Define KBUILD Information
HOST="DerpGang"
USER="Kanishk"
echo "KBuild host is set to $HOST and user to $USER."
sleep 1s

# Define Toolchain
# 1.clang
# 2.GCC
# Define according tou your Kernel Source
TOOLCHAIN="clang"
CLANG_NAME="Clang"
TOOLCHAIN_SOURCE="https://bitbucket.org/shuttercat/clang"

GCC_Source_32="https://github.com/mvaisakh/gcc-arm"
GCC_Source_64="https://github.com/mvaisakh/gcc-arm64"

# Automation for toolchain and gcc builds
if [ "$TOOLCHAIN" == "gcc" ]; then
    if [ ! -d "$base/gcc64" ] && [ ! -d "$base/gcc32" ]; then
      echo "Defualt toolchain is set to $TOOLCHAIN."
      sleep 1s
      green_message "<< Cloning GCC from arter >>"
      git clone --depth=1 "$GCC_Source_64" "$base/gcc64"
      git clone --depth=1 "$GCC_Source_32" "$base/gcc32"
    fi
    export PATH="$base/gcc64/bin:$base/gcc32/bin:$PATH"
    export STRIP="$base/gcc64/aarch64-elf/bin/strip"
    export KBUILD_COMPILER_STRING=$("$base/gcc64/bin/aarch64-elf-gcc" --version | head -n 1)
elif [ "$TOOLCHAIN" == "clang" ]; then
    if [ ! -d "$base/Clang" ]; then
      echo "Default toolchain is set to $TOOLCHAIN."
      sleep 1s
      echo "Cloning Clang 19 from BitBucket.org."
      git clone -b 14 "$TOOLCHAIN_SOURCE" "$base/Clang"
    fi
    export PATH="$base/Clang/bin:$PATH"
    export STRIP="$base/Clang/aarch64-linux-gnu/bin/strip"
fi

# Function to build the kernel
build_kernel() {
        echo "Executing kernel build."
        sleep 1s
        echo "Kernel Version is $KERNEL_VER."
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
echo "Creating workspace for kernel. Please Wait."
sleep 1s
mkdir -p out/
echo "Copying DTS files."
sleep 1s
mkdir -p out/arch/arm64/
cp -r arch/arm64/boot out/arch/arm64/
rm -rf out/arch/arm64/boot/dts/google
mkdir -p out/arch/arm64/boot/dts/google/
mkdir -p out/arch/arm64/boot/dts/qcom
cp arch/arm64/boot/dts/google/*.dts* out/arch/arm64/boot/dts/google/
cp arch/arm64/boot/dts/qcom/*.dts* out/arch/arm64/boot/dts/qcom/
echo "DTS copied successfully."
sleep 1s

make O=out clean && make O=out mrproper
make "$DEFCONFIG" O=out

# Execute kernel Building Action
echo "Compiling $KERNEL_NAME ($folder)."
sleep 1s
build_kernel || error=true
DATE=$(date +"%Y%m%d-%H%M%S")
KERVER=$(make kernelversion)
        echo "Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds."
        sleep 2s

# Now Clone AnyKernel
        sleep 2s
        echo "Cloning AnyKernel3."
        git clone "$AnyKernel" --single-branch -b "$AnyKernelbranch" $base/AnyKernel3
        echo "AnyKernel3 has been cloned successfully."

# Create Zip
echo "Creating $KERNEL_NAME ($folder) zip."
kernel_name="Streamline"
device_name="bluecross"
zip_name="$kernel_name-14-$device_name-$(date +"%Y%m%d-%H%M").zip"
export anykernel="$base/AnyKernel3"

delete_zip(){
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}

build_package(){
  cp -rf $base/$folder/out/arch/arm64/boot/Image.lz4-dtb $anykernel/
  cp -rf $base/$folder/out/arch/arm64/boot/dtbo.img $anykernel/
  zip -r9 UPDATE-AnyKernel3.zip * -x README UPDATE-AnyKernel3.zip
}

make_name(){
  mv UPDATE-AnyKernel3.zip $zip_name
  mkdir $base/kernel_zips
  mv $zip_name $base/kernel_zips/
  echo "Created $KERNEL_NAME ($folder) zip."
}

upload(){
   echo "Uploading to PixelDrain file hosting. (pixeldrain.com)"
   pdup $base/kernel_zips/$zip_name
   echo "Finished uploading."
}

delete_zip
build_package
make_name
upload
