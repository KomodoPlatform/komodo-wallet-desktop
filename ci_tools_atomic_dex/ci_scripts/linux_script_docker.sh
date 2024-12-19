#!/bin/bash

# Update repositories and remove unnecessary packages
sudo apt-get update  # Prevents repository 404 errors
sudo apt-get remove -y php* msodbcsql17 mysql*

# Install essential build dependencies
sudo apt-get install -y build-essential \
                        libgl1-mesa-dev \
                        curl \
                        wget \
                        zstd \
                        software-properties-common \
                        lsb-release \
                        libpulse-dev \
                        libtool \
                        autoconf \
                        unzip \
                        libfuse2 \
                        libssl-dev \
                        libxkbcommon-x11-0 \
                        libxcb-icccm4 \
                        libxcb-image0 \
                        libxcb1-dev \
                        libxcb-keysyms1-dev \
                        libxcb-render-util0-dev \
                        libxcb-xinerama0 \
                        libgstreamer-plugins-base1.0-dev \
                        libxcb-shape0-dev \
                        libxcb-xfixes0-dev \
                        libx11-xcb-dev \
                        libxrender-dev \
                        libxcb-image0-dev \
                        libxcb-util1-dev \
                        libxcb-randr0-dev \
                        libxcb-xinerama0-dev \
                        libxcb-icccm4-dev \
                        libxcb-sync-dev \
                        libxcb-present-dev \
                        libxcb-dri3-dev \
                        libxcb-glx0-dev \
                        gtk2-engines-pixbuf \
                        libgtk2.0-0 \
                        libgtk2.0-dev \
                        git

# Deps for QT web engine view
sudo apt-get install libnss3-dev \
    libnspr4-dev \
    libxcomposite-dev \
    libxdamage-dev  \
    libxrandr-dev  \
    libxcursor-dev  \
    libxi-dev  \
    libxtst-dev  \
    libasound2-dev -y

# Update `ninja` to the latest compatible version (>= 1.10.2)
wget https://github.com/ninja-build/ninja/releases/download/v1.10.2/ninja-linux.zip
sudo unzip -o ninja-linux.zip -d /usr/bin/
sudo chmod +x /usr/bin/ninja

# Install LLVM/Clang
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 12

# Set Clang as the default compiler
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 777
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 777

# Set GCC/G++ 9 as the fallback compiler
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 777
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 777

# Install libc++ for C++20 support
sudo apt-get install -y libc++-11-dev libc++abi-11-dev

# Set environment variables for Clang
export CXX=clang++-12
export CC=clang-12

# Install CMake 3.27.1
wget https://github.com/Kitware/CMake/releases/download/v3.27.1/cmake-3.27.1-linux-x86_64.tar.gz
tar -xvzf cmake-3.27.1-linux-x86_64.tar.gz
sudo cp -r cmake-3.27.1-linux-x86_64/* /usr/local/
sudo cp -r cmake-3.27.1-linux-x86_64/* /usr/
cmake --version

## tar
wget --timeout=10 --tries=3 https://ftp.gnu.org/gnu/tar/tar-1.32.tar.gz || wget --timeout=10 --tries=3 https://mirrors.sjtug.sjtu.edu.cn/gnu/tar/tar-1.32.tar.gz
tar xvf tar-1.32.tar.gz
cd tar-1.32
export FORCE_UNSAFE_CONFIGURE=1
./configure
sudo make -j install
sudo ln -sf /bin/tar /usr/local/bin/tar
sudo update-alternatives --install /usr/bin/tar tar /usr/local/bin/tar 777

# get libwally
git clone https://github.com/KomodoPlatform/libwally-core.git --recurse-submodules
cd libwally-core
./tools/autogen.sh
./configure --disable-shared
sudo make -j3 install
cd ..
