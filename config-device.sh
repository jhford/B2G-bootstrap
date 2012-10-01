#!/bin/bash

# This script understands how to take  a device name and configure a
# source tree to be ready to build for the device.

case `uname` in
"Darwin")
	CORE_COUNT=`system_profiler SPHardwareDataType | grep "Cores:" | sed -e 's/[ a-zA-Z:]*\([0-9]*\)/\1/'`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo GECKO_OBJDIR=$PWD/objdir-gecko >> .tmp-config
echo DEVICE_NAME=$1 >> .tmp-config

case "$1" in
"galaxy-s2")
	echo DEVICE=galaxys2 >> .tmp-config &&
	(cd device/samsung/galaxys2 && ./extract-files.sh)
	;;

"galaxy-nexus")
	echo DEVICE=maguro >> .tmp-config &&
	(cd device/samsung/maguro && ./download-blobs.sh)
	;;

"optimus-l5")
	echo DEVICE=m4 >> .tmp-config &&
	(cd device/lge/m4 && ./extract-files.sh)
	;;

"nexus-s")
	echo DEVICE=crespo >> .tmp-config &&
	(cd device/samsung/crespo && ./download-blobs.sh)
	;;

"nexus-s-4g")
	echo DEVICE=crespo4g >> .tmp-config &&
	(cd device/samsung/crespo4g && ./download-blobs.sh)
	;;

"otoro"|"unagi")
	echo DEVICE=$1 >> .tmp-config &&
	(cd device/qcom/$1 && ./extract-files.sh)
	;;

"pandaboard")
	echo DEVICE=panda >> .tmp-config &&
	(cd device/ti/panda && ./download-blobs.sh)
	;;

"emulator")
	echo DEVICE=generic >> .tmp-config &&
	echo LUNCH=full-eng >> .tmp-config
	;;

"emulator-x86")
	echo DEVICE=generic_x86 >> .tmp-config &&
	echo LUNCH=full_x86-eng >> .tmp-config
	;;

*)
	echo Usage: $0 \(device name\)
	echo
	echo Valid devices to configure are:
	echo - galaxy-s2
	echo - galaxy-nexus
	echo - nexus-s
	echo - nexus-s-4g
	echo - otoro
	echo - unagi
	echo - pandaboard
	echo - emulator
	echo - emulator-x86
	exit -1
	;;
esac


if [ $? -ne 0 ]; then
	echo Device configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
