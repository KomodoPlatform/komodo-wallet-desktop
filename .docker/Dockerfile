FROM docker.io/ubuntu:20.04 AS base

LABEL authors=<smk@komodoplatform.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
ENV SHELL=/bin/bash
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /build

RUN apt-get update -y && \
    apt-get install -y  \
        ca-certificates \
        curl \
        zip \
        unzip \
        tar \
        sudo \
        git \
        wget \
        python3-dev \
        python3-venv \
        python3-pip \
        python-is-python3

ARG branch='update/docs'
RUN git clone --branch $branch https://github.com/KomodoPlatform/komodo-wallet-desktop.git --recursive

RUN cp -f /build/linux_script.sh /build/komodo-wallet-desktop/ci_tools_atomic_dex/ci_scripts/linux_script.sh
RUN cd /build/komodo-wallet-desktop && ./ci_tools_atomic_dex/ci_scripts/linux_script_docker.sh

RUN ninja --version
RUN cmake --version

RUN echo $(ninja --version) > /build/ninja2b.log
RUN echo $(cmake --version) > /build/cmake2b.log

ENV CXX=clang++-12
ENV CC=clang-12
#ENV CXXFLAGS="-stdlib=libc++ -std=c++20"
#ENV LDFLAGS="-stdlib=libc++"

# Install Qt
RUN python3 -m venv /build/.venv && \
    /build/.venv/bin/pip install aqtinstall==3.1.1 && \
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

RUN echo $(ninja --version) > /build/ninja3.log
RUN echo $(cmake --version) > /build/cmake3.log

RUN ninja --version
RUN cmake --version

RUN cd /build/komodo-wallet-desktop/ci_tools_atomic_dex && nimble build -y

RUN ninja --version
RUN cmake --version

RUN echo $(ninja --version) > /build/ninja4.log
RUN echo $(cmake --version) > /build/cmake4.log

# USAGE: ###
#
#    docker build -t kw-build-container -f .docker/Dockerfile .
#    docker run -v "$(pwd)":/build/komodo-wallet-desktop -w /build/komodo-wallet-desktop/ci_tools_atomic_dex kw-build-container bash -c  "./ci_tools_atomic_dex build Debug"
#    docker run -v "$(pwd)":/build/komodo-wallet-desktop -w /build/komodo-wallet-desktop/ci_tools_atomic_dex kw-build-container bash -c  "./ci_tools_atomic_dex build Release"
#
#    docker run -it kw-build-container bash                           # (to enter container for debugging)
###

CMD [ "bash" ]
