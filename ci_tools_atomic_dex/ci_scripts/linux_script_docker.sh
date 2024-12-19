#!/bin/bash


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
