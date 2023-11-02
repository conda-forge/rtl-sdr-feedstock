echo "To enable udev device setup of rtl-sdr hardware, you must manually install"    >> $PREFIX/.messages.txt
echo "the udev rules provided by the 'rtl-sdr' package by copying or linking"        >> $PREFIX/.messages.txt
echo "them into your system directory, e.g.:"                                        >> $PREFIX/.messages.txt
echo "    sudo ln -s $PREFIX/lib/udev/rules.d/rtl-sdr.rules /etc/udev/rules.d/"      >> $PREFIX/.messages.txt
echo "After doing this, reload your udev rules:"                                     >> $PREFIX/.messages.txt
echo "    sudo udevadm control --reload && sudo udevadm trigger"                     >> $PREFIX/.messages.txt
