#!/usr/bin/env bash

set -ex

mkdir build
cd build

# configuration
cmake_config_args=(
    -DCMAKE_BUILD_TYPE=Release
    -DCMAKE_INSTALL_LIBDIR=lib
    -DCMAKE_INSTALL_PREFIX=$PREFIX
    -DINSTALL_UDEV_RULES=OFF
)

# librtlsdr's DETACH_KERNEL_DRIVER option exists for Linux, where the
# dvb_usb_rtl28xxu kernel module may have claimed the device. On macOS libusb
# implements detach as whole-device capture, which fails with
# LIBUSB_ERROR_ACCESS unless the process is root or carries the
# com.apple.vm.device-access entitlement (and re-enumerates the device when it
# does succeed). rtlsdr_open() treats any failed detach as fatal (`goto err`),
# so with this option enabled an unprivileged process cannot open a device
# whenever libusb_kernel_driver_active() reports the interface as claimed.
# With it off, the same condition is only an advisory and the open proceeds.
if [[ $target_platform == linux-* ]] ; then
    cmake_config_args+=(
        -DDETACH_KERNEL_DRIVER=ON
    )
else
    cmake_config_args+=(
        -DDETACH_KERNEL_DRIVER=OFF
    )
fi

if [[ $target_platform == linux-64 || $target_platform == linux-ppc64le ]] ; then
    cmake_config_args+=(
        -DENABLE_ZEROCOPY=ON
    )
else
    cmake_config_args+=(
        -DENABLE_ZEROCOPY=OFF
    )
fi

cmake ${CMAKE_ARGS} .. "${cmake_config_args[@]}"
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install

# make link at librtlsdr.so.2 soname which 2.0.0 and 2.0.1 provided
cmake -E create_symlink $PREFIX/lib/librtlsdr.so.0 $PREFIX/lib/librtlsdr.so.2

# delete static library per conda-forge policy
rm $PREFIX/lib/librtlsdr.a

# copy udev rule and kernel blacklist so they are accessible by users
if [[ $target_platform == linux* ]] ; then
    mkdir -p $PREFIX/lib/udev/rules.d/
    cp ../rtl-sdr.rules $PREFIX/lib/udev/rules.d/
    mkdir -p $PREFIX/etc/modprobe.d/
    cp ../debian/rtl-sdr-blacklist.conf $PREFIX/etc/modprobe.d/
fi
