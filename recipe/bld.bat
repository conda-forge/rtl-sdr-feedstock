setlocal EnableDelayedExpansion
@echo on

:: Make a build folder and change to it
mkdir build
if errorlevel 1 exit 1
cd build
if errorlevel 1 exit 1

:: configure
cmake -G "Ninja" ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DCMAKE_INSTALL_LIBDIR=lib ^
    -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
    -DCMAKE_PREFIX_PATH="%LIBRARY_PREFIX%" ^
    -DTHREADS_PTHREADS_LIBRARY="%LIBRARY_LIB%\pthread.lib" ^
    -DDETACH_KERNEL_DRIVER=OFF ^
    -DENABLE_ZEROCOPY=OFF ^
    -DINSTALL_UDEV_RULES=OFF ^
    ..
if errorlevel 1 exit 1

:: build
cmake --build . --config Release -- -j%CPU_COUNT%
if errorlevel 1 exit 1

:: install
cmake --build . --config Release --target install
if errorlevel 1 exit 1

:: delete static library per conda-forge policy
del %LIBRARY_LIB%\rtlsdr_static.lib
