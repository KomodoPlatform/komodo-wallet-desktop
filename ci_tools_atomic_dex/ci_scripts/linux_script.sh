#!/bin/bash

sudo apt-get update  # prevents repo404 errors on apt-remove below
sudo apt-get remove php* msodbcsql17 mysql*
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get upgrade -y
# base deps
sudo apt-get install build-essential \
                    libgl1-mesa-dev \
                    ninja-build \
                    curl \
                    wget \
                    software-properties-common \
                    lsb-release \
                    libpulse-dev \
                    libtool \
                    autoconf \
                    unzip \
                    libssl-dev \
                    libxkbcommon-x11-0 \
                    libxcb-icccm4 \
                    libxcb-image0 \
                    libxcb1-dev \
                    libxcb-keysyms1-dev \
                    libxcb-render-util0-dev \
                    libxcb-xinerama0 \
                    libgstreamer-plugins-base1.0-dev \
                    git -y
                    
# get llvm
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 10
# set clang version
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-10 777
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-10 777
# set gnu compilers version
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 777
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 777
sudo apt-get update
sudo apt-get install libc++abi-10-dev libc++-10-dev -y
export CXXFLAGS=-stdlib=libc++
export LDFLAGS=-stdlib=libc++
export CXX=clang++-10
export CC=clang-10
# get right cmake version
wget https://github.com/Kitware/CMake/releases/download/v3.17.3/cmake-3.17.3-Linux-x86_64.tar.gz
tar xvf cmake-3.17.3-Linux-x86_64.tar.gz
cd cmake-3.17.3-Linux-x86_64
sudo cp -r * /usr/
sudo cp -r * /usr/local/
cmake --version
# get libwally
git clone https://github.com/KomodoPlatform/libwally-core.git
cd libwally-core
./tools/autogen.sh
./configure --disable-shared
sudo make -j3 install
cd ..
