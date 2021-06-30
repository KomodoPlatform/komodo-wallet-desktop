FROM ubuntu:18.04
MAINTAINER smk 
ENV QT_VERSION=5.15.2
ENV CMAKE_VERSION=3.20.5

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get install software-properties-common -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get -y install build-essential libgl1-mesa-dev ninja-build curl wget zstd lsb-release libpulse-dev libtool autoconf unzip libssl-dev libxkbcommon-x11-0 libxcb-icccm4 libxcb-image0 libxcb1-dev libxcb-keysyms1-dev libxcb-render-util0-dev libxcb-xinerama0 libgstreamer-plugins-base1.0-dev git zip unzip python3-pip python-pip wget gcc-9 g++-9 python-pyqt5 libssl-dev libxcursor-dev libxcomposite-dev libxdamage-dev libxrandr-dev libfontconfig1-dev libxss-dev libxtst-dev libpci-dev libcap-dev libsrtp0-dev libasound2-dev libnspr4-dev libnss3-dev ninja-build -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN wget https://apt.llvm.org/llvm.sh; chmod +x llvm.sh; ./llvm.sh 12; \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 777; \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 777; \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 777; \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 777; \
    apt-get update; \
    export CXX=clang++-12; \
    export CC=clang-12;

RUN wget https://github.com/Kitware/CMake/releases/download/v$CMAKE_VERSION/cmake-$CMAKE_VERSION-linux-x86_64.tar.gz; \
    tar xvf cmake-$CMAKE_VERSION-linux-x86_64.tar.gz; curdir=$(pwd); \
    export PATH=${PATH}:${curdir}/cmake-$CMAKE_VERSION-linux-x86_64/bin;

RUN python3 -m pip install --upgrade pip; \
    python3 -m pip install setuptools wheel; \
    python3 -m pip install py7zr==0.16.1; \
    python3 -m pip install aqtinstall==1.2.1; \
    python3 -m aqt install -O /opt/Qt $QT_VERSION linux desktop -b https://qt-mirror.dannhauer.de/ -m qtcharts qtwidgets debug_info qtwebengine qtwebview;

RUN git clone https://github.com/KomodoPlatform/libwally-core.git; \ 
	cd libwally-core; ./tools/autogen.sh; ./configure --disable-shared; make -j2 install; cd ..;

RUN export QT_INSTALL_CMAKE_PATH=/opt/Qt/$QT_VERSION/gcc_64/lib/cmake; \
    export QT_ROOT=/opt/Qt/$QT_VERSION; \
    export Qt5_DIR=/opt/Qt/$QT_VERSION/gcc_64/lib/cmake/Qt5; \
    export PATH=/opt/Qt/$QT_VERSION/gcc_64/bin:$PATH 

CMD ["entrypoint"]
