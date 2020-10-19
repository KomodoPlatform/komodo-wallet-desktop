#!/bin/bash

brew install autoconf \
            automake \
            libtool \
            pkgconfig \
            wget \
            nim \
            cmake \
            ninja \
            git \
            boost \
            gcc \
            gnu-sed \
            llvm@9
export CC=/usr/local/opt/llvm@9/bin/clang
# get curl
git clone https://github.com/curl/curl.git
cd curl
git checkout curl-7_70_0
./buildconf
./configure --disable-shared --enable-static --without-libidn2 --without-ssl --without-nghttp2 --disable-ldap --with-darwinssl
make -j3 install
cd ../
git clone https://github.com/KomodoPlatform/libwally-core.git
cd libwally-core
./tools/autogen.sh
./configure --disable-shared
sudo make -j3 install
cd ..
# get SDKs 
git clone https://github.com/phracker/MacOSX-SDKs $HOME/sdk
