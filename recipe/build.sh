#!/usr/bin/env bash

set -ex

mkdir build
cd build

# configuration
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DDETACH_KERNEL_DRIVER=OFF
    -DENABLE_ZEROCOPY=OFF
    -DINSTALL_UDEV_RULES=OFF
)

cmake ${CMAKE_ARGS} .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

# delete static library per conda-forge policy
rm $PREFIX/lib/librtlsdr.a

# copy udev rule and kernel blacklist so they are accessible by users
if [[ $target_platform == linux* ]] ; then
    mkdir -p $PREFIX/lib/udev/rules.d/
    cp ../rtl-sdr.rules $PREFIX/lib/udev/rules.d/
    mkdir -p $PREFIX/etc/modprobe.d/
    cp ../debian/rtl-sdr-blacklist.conf $PREFIX/etc/modprobe.d/
fi
