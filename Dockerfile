FROM docker.io/ubuntu:20.04 AS base

LABEL authors=<smk@komodoplatform.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV SHELL=/bin/bash
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /build/komodo-wallet-desktop
COPY . /build/komodo-wallet-desktop
RUN rm -rf .git build logs tmp

RUN apt-get update -y && \
    apt-get install -y build-essential \
    libgtk-3-dev \
    libgdk-pixbuf2.0-dev \
    libglib2.0-dev \
    autoconf \
    automake \
    libtool \
    libgl1-mesa-dev \
    ca-certificates \
    zip \
    tar \
    sudo \
    python3-dev \
    python3-venv \
    python3-pip \
    python-is-python3 \
    curl \
    wget \
    zstd \
    software-properties-common \
    lsb-release \
    libpulse-dev \
    libtool \
    autoconf \
    unzip \
    fuse \
    libfuse2 \
    libssl-dev \
    libxkbcommon-x11-0 \
    libxcb-icccm4 \
    libxcb-image0 \
    qt5-gtk-platformtheme \
    libxcb1-dev \
    libxcb-keysyms1-dev \
    libxcb-render-util0-dev \
    libxcb-xinerama0 \
    libxcb-shape0-dev \
    libxcb-xfixes0-dev \
    libxcb-image0-dev \
    libxcb-randr0-dev \
    libxcb-xinerama0-dev \
    libxcb-icccm4-dev \
    libxcb-sync-dev \
    libxcb-present-dev \
    libxcb-dri3-dev \
    libxcb-glx0-dev \
    libxcomposite-dev \
    libxdamage-dev  \
    libxrandr-dev  \
    libxcursor-dev  \
    libxi-dev  \
    libxtst-dev  \
    libx11-xcb-dev \
    libxrender-dev \
    gtk2-engines-pixbuf \
    libgtk2.0-0 \
    libgtk2.0-dev \
    libgbm-dev \
    git \
    libnss3-dev \
    libnspr4-dev \
    libgstreamer-plugins-base1.0-dev \
    libqt5charts5-dev \
    libqt5webchannel5-dev \
    libasound2-dev

RUN git config --global --add safe.directory /build/komodo-wallet-desktop
RUN cd /build/komodo-wallet-desktop && ./ci_tools_atomic_dex/ci_scripts/linux_script_docker.sh


ENV CXX=clang++-12
ENV CC=clang-12
#ENV CXXFLAGS="-stdlib=libc++ -std=c++20"
#ENV LDFLAGS="-stdlib=libc++"

# Install Qt
RUN python3 -m venv /build/.venv && \
    /build/.venv/bin/pip install aqtinstall && \
    /build/.venv/bin/python -m aqt install-qt linux desktop 5.15.2 -O $HOME/Qt -b https://qt-mirror.dannhauer.de/ -m qtcharts debug_info qtwebengine


ENV DEBIAN_FRONTEND=noninteractive
ENV SHELL=/bin/bash
ENV QT_INSTALL_CMAKE_PATH=/root/Qt/5.15.2/gcc_64/lib/cmake
ENV QT_ROOT=/root/Qt/5.15.2
ENV PATH=/root/Qt/5.15.2/gcc_64/bin:$PATH


# Install Nim
ENV CHOOSENIM_CHOOSE_VERSION=1.6.2
RUN /build/komodo-wallet-desktop/ci_tools_atomic_dex/ci_scripts/choosenim.sh -y && \
    export PATH=/root/.nimble/bin:$PATH && \
    chmod +x /root/.choosenim/toolchains/nim-1.6.2/bin/*
ENV PATH=/root/.nimble/bin:$PATH
    
RUN cd /build/komodo-wallet-desktop/ci_tools_atomic_dex/vcpkg-repo && ./bootstrap-vcpkg.sh


# USAGE: ###
#
#  To build the build container
#    docker build -t kw-build-container . --progress=plain --no-cache
#
#  To build the app
#    ./docker-build-linux.sh
#    
#  To enter container for debugging
#    docker run -it kw-build-container bash                           
###

CMD [ "bash" ]
