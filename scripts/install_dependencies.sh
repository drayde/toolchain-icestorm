# Install dependencies script

if [ $ARCH == "linux_x86_64" ]; then
    sudo apt-get install -y build-essential bison flex libreadline-dev libusb-1.0-0-dev zlib1g-dev \
                            gawk tcl-dev libffi-dev git graphviz \
                            xdot pkg-config python3 \
    gcc --version
    g++ --version
fi

if [ $ARCH == "linux_i686" ]; then
    sudo apt-get install -y build-essential bison flex libreadline-dev libusb-1.0-0-dev \
                            gawk tcl-dev libffi-dev git graphviz \
                            xdot pkg-config python3 \
                            gcc-multilib g++-multilib
    gcc --version
    g++ --version
fi

if [ $ARCH == "linux_armv7l" ]; then
    sudo apt-get install -y build-essential bison flex libreadline-dev libusb-1.0-0-dev \
                            gawk tcl-dev libffi-dev git graphviz \
                            xdot pkg-config python3 \
                            gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf \
                            binfmt-support qemu-user-static
    arm-linux-gnueabihf-gcc --version
    arm-linux-gnueabihf-g++ --version
fi

if [ $ARCH == "linux_aarch64" ]; then
    sudo apt-get install -y build-essential bison flex libreadline-dev libusb-1.0-0-dev \
                            gawk tcl-dev libffi-dev git graphviz \
                            xdot pkg-config python3 \
                            gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
                            binfmt-support qemu-user-static
    sudo apt-get autoremove -y
    aarch64-linux-gnu-gcc --version
    aarch64-linux-gnu-g++ --version
fi

if [ $ARCH == "windows_x86" ]; then
    sudo apt-get install -y build-essential bison flex libreadline-dev libusb-1.0-0-dev zlib1g-dev \
                            gawk tcl-dev libffi-dev git graphviz \
                            xdot pkg-config python3 \
                            mingw-w64 mingw-w64-tools mingw-w64-i686-dev \
                            zip rsync
    i686-w64-mingw32-gcc --version
    i686-w64-mingw32-g++ --version
fi

if [ $ARCH == "windows_amd64" ]; then
    sudo apt-get install -y build-essential bison flex libreadline-dev libusb-1.0-0-dev zlib1g-dev \
                            gawk tcl-dev libffi-dev git graphviz \
                            xdot pkg-config python3 \
                            mingw-w64 mingw-w64-tools mingw-w64-x86-64-dev \
                            zip rsync
    x86_64-w64-mingw32-gcc --version
    x86_64-w64-mingw32-g++ --version
fi

if [ $ARCH == "darwin" ]; then
    export PATH=/tmp/conda/bin:$PATH
    for dep in $(ls -1 $WORK_DIR/build-data/darwin/*.bz2)
    do
        mkdir -p /tmp/conda
        pushd /tmp/conda
        echo "Extracting $dep..."
        tar xjf $dep
        if [ -e info/has_prefix ]
        then
            python3 $WORK_DIR/build-data/darwin/convert.py /tmp/conda
            rm -f info/has_prefix
        fi
        popd
    done
fi
