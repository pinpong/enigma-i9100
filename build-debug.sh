#!/bin/bash


TOP_DIR=$PWD
KERNEL_PATH=/home/pinpong/enigma/enigma-miui-kernel

rm compile.log

TOOLCHAIN="/home/pinpong/android/toolchains/gcc-linaro-arm-linux-gnueabi-2012.01-20120125_linux/bin/arm-linux-gnueabi-"
INITRAMFS_PATH="/home/pinpong/enigma/enigma-miui-initramfs"

export LOCALVERSION="-ENIGMA-1.34"

echo "cleaning latest build"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN -j`grep 'processor' /proc/cpuinfo | wc -l` clean

echo "set kernel config"
cp -f $KERNEL_PATH/arch/arm/configs/enigma-debug-defconfig $KERNEL_PATH/.config
make -j4 -C $KERNEL_PATH xconfig || exit -1

echo "make modules"
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN modules_prepare
make ARCH=arm CROSS_COMPILE=$TOOLCHAIN modules
find -name '*.ko' -exec cp -av {} $INITRAMFS_PATH/lib/modules/ \;

echo "make kernel"
make -j4 -C $KERNEL_PATH ARCH=arm CROSS_COMPILE=$TOOLCHAIN >> compile.log 2>&1 || exit -1 

echo "prepare kernel to be flashed by Odin and CWM "
rm -f $KERNEL_PATH/releases/zip/enigma.zip
cp -f $KERNEL_PATH/arch/arm/boot/zImage .
cp -f $KERNEL_PATH/arch/arm/boot/zImage $KERNEL_PATH/releases/zip
cd arch/arm/boot
tar cf $KERNEL_PATH/arch/arm/boot/$LOCALVERSION.tar ../../../zImage && ls -lh $LOCALVERSION.tar
cd ../../..
cd releases/zip
zip -r $LOCALVERSION.zip *
cp $KERNEL_PATH/arch/arm/boot/$LOCALVERSION.tar $KERNEL_PATH/releases/tar/$LOCALVERSION.tar
rm $KERNEL_PATH/arch/arm/boot/$LOCALVERSION.tar
rm $KERNEL_PATH/releases/zip/zImage

echo "flash kernel via heimdall"
cd /home/pinpong/enigma/enigma-miui-kernel/arch/arm/boot
adb reboot download
sleep 15
sudo heimdall flash --kernel zImage
cd ../../..

