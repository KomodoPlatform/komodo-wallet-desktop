# Building Komodo Wallet Desktop on Linux

_Note: These instructions may not be up to date. Please refer to the github actions workflows for more recent build requirements_


## Linux builds with docker

From project root, run `docker build -t kw-build-container .` to create a build environment container.
Run `./docker-build-linux.sh` to build the app
Run `docker run -it kw-build-container bash` to enter the container for debugging.
Output will be found in the `bundled` subfolder.

### Prerequisites

- Clang C++ 17 compiler (clang-12 minimum)
- [CMake](https://cmake.org/install/) 3.18 minimum


### Clone Komodo Wallet Desktop repository (with submodules)

`git clone --recurse-submodules https://github.com/KomodoPlatform/komodo-wallet-desktop.git`


### Install Qt

```bash
python3 -m venv .venv
.venv/bin/pip install aqtinstall==3.1.1
.venv/bin/python -m aqt install-qt linux desktop 5.15.2 -O $HOME/Qt -b https://qt-mirror.dannhauer.de/ -m qtcharts debug_info qtwebengine
```

Add the following environment variables to your `~/.bashrc` or `~/.zshrc` profiles:
 * `QT_INSTALL_CMAKE_PATH` equal to the CMake QT path
 * `QT_ROOT` equal to the QT root installation folder

e.g.:
```bash
export QT_INSTALL_CMAKE_PATH=~/Qt/5.15.2/gcc_64/lib/cmake
export QT_ROOT=~/Qt/5.15.2
```

Make sure Qt binaries are on the PATH. E.g.

```bash
export PATH=$PATH:/home/username/Qt/5.15.2/gcc_64/bin
```

### Install Linux dependencies (aptitude)

```bash
sudo apt-get install build-essential \
                    libgl1-mesa-dev \
                    ninja-build \
                    curl \
                    wget \
                    zstd \
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
sudo ./llvm.sh 12

# set clang version
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 777
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 777
sudo apt-get update
# if you want to use libclang
#sudo apt-get install libc++abi-12-dev libc++-12-dev -y

# Add the following environment variables to your `~/.bashrc` or `~/.zshrc` profiles:

#if you want to use libclang
#export CXXFLAGS=-stdlib=libc++
#export LDFLAGS=-stdlib=libc++
export CXX=clang++-12
export CC=clang-12
```

### Install Linux dependencies (rpm)

```bash
sudo dnf update
sudo dnf groupinstall "Development Tools" "Development Libraries"
sudo dnf install  wget \
                  curl \
                  cmake \
                  perl \
                  calng12-devel \
                  ninja-build \
                  zstd \
                  mesa-libGL-devel \
                  redhat-lsb-core \
                  libtool \
                  autoconf \
                  zip \
                  unzip \
                  openssl \
                  openssl-devel \
                  libxkbcommon-x11 \
                  libxcb-* \
                  gstreamer1-plugins-base-devel

# Fresh versions of RedHat (9+) and Fedora (34+) come with clang15 and llvm15, no extra packages or configuration is required
```


### Install Libwally (Windows only)

```bash
git clone https://github.com/KomodoPlatform/libwally-core.git
<TBA - refer to github action>
```



### Bootstrap VCPKG modules

Install vcpkg from within the `ci_tools_atomic_dex` folder:

```bash
cd komodo-wallet-desktop/ci_tools_atomic_dex/vcpkg-repo
./bootstrap-vcpkg.sh
```


### Build komodo-wallet-desktop (portable)

In your shell command prompt (Powershell/Zsh/Bash), from within the `root` folder (e.g. ~/komodo-wallet-desktop), type:

```bash
cd komodo-wallet-desktop\build              # create the 'build' folder if it doesn't exist
cmake -DCMAKE_BUILD_TYPE=Release ../    # add -GNinja if you want to use the ninja build system.
cmake --build . --config Release --target komodo-wallet
```


### Bundle komodo-wallet-desktop (installer)


```
cd komodo-wallet-desktop\build              # create the 'build' folder if it doesn't exist
cmake -DCMAKE_BUILD_TYPE=Release -GNinja ../
cmake --build . --config Release --target komodo-wallet
ninja install
```


# Building Atomicdex Desktop on MacOS


### Prerequisites

- Clang C++ 17 compiler (clang-12 minimum)
    - on macOS Catalina/BigSur, Apple Clang 12.0 is picked by default 
- [CMake](https://cmake.org/install/) 3.18 minimum
- [brew](https://brew.sh)
- macOS [command line tools](https://developer.apple.com/downloads)


### Clone AtomicDEX repository (with submodules)

`git clone --recurse-submodules https://github.com/KomodoPlatform/komodo-wallet-desktop.git`


### Install Qt

```bash
# Could also be pip3 depending of your python installation
pip install aqtinstall
python3 -m aqt install-qt mac desktop 5.15.2 clang_64 -O $HOME/Qt -b https://qt-mirror.dannhauer.de/ -m qtcharts debug_info qtwebengine
```

Add the following environment variables to your `~/.bashrc` or `~/.zshrc` profile:
 * `QT_INSTALL_CMAKE_PATH` equal to the CMake QT path
 * `QT_ROOT` equal to the QT root installation folder

e.g.:

```bash
export QT_INSTALL_CMAKE_PATH=/Users/SatoshiNakamoto/Qt/5.15.2/clang_64/lib/cmake
export QT_ROOT=/Users/SatoshiNakamoto/Qt/5.15.2
```


### Install brew requirements

```bash
brew install autoconf \
             automake \
             libtool \
             pkgconfig \
             wget \
             ninja \
             gnu-sed \
             coreutils \
             gnu-getopt
```


### Installing OSX SDK's (optional, for older systems):

```bash
git clone https://github.com/phracker/MacOSX-SDKs.git ~/MacOSX-SDKs
```


### Install Libwally

```bash
git clone https://github.com/KomodoPlatform/libwally-core.git
cd libwally-core
./tools/autogen.sh
PYTHON_VERSION=3 ./configure --disable-shared    # configure requires you to pass python version to use instead of deprecated python2
sudo make -j2 install
```


### Bootstrap VCPKG modules

```bash
cd komodo-wallet-desktop\ci_tools_atomic_dex\vcpkg-repo
./bootstrap-vcpkg.sh
```

### Build komodo-wallet-desktop (portable)

In your shell command prompt (Powershell/Zsh/Bash), from within the `root` folder (e.g. ~/komodo-wallet-desktop), type:

```bash
cd komodo-wallet-desktop\build              # create the 'build' folder if it doesn't exist
cmake -DCMAKE_BUILD_TYPE=Release ../    # add -GNinja if you want to use the ninja build system.
cmake --build . --config Release --target komodo-wallet
```

### Bundle komodo-wallet-desktop (installer)


On MacOS some extra variables in the environment are required to be able to bundle and sign the app:

```bash
export PATH=$HOME/Qt/5.15.2/clang_64/bin:$PATH

## Need to be your Developer ID Application if you want to fork/rebundle the app on OSX
## This also assume your certificates is already in your MacOS Keystore
export MAC_SIGN_IDENTITY="Developer ID Application: Satoshi Nakamoto (923YHAAKNY)"

## This is app deployment password that can be generate in your apple account profile
export APPLE_ATOMICDEX_PASSWORD="foo-bar-foo-bar"

## This is your apple id email
export APPLE_ID="satoshinakamoto@bitcoin.com"
```

```
cd komodo-wallet-desktop\build              # create the 'build' folder if it doesn't exist
cmake -DCMAKE_BUILD_TYPE=Release -GNinja ../
cmake --build . --config Release --target komodo-wallet
ninja install
```



# Building Atomicdex Desktop on Windows


### Prerequisites

- Visual Studio 2019 with [Desktop development with C++](https://docs.microsoft.com/en-gb/cpp/build/vscpp-step-0-installation?view=vs-2019).
- [CMake](https://cmake.org/install/) 3.18 minimum


### Clone AtomicDEX repository (with submodules)

`git clone --recurse-submodules https://github.com/KomodoPlatform/komodo-wallet-desktop.git`


### Install Qt

```powershell
# Could also be pip3 depending of your python installation
python3.exe -m pip install aqtinstall
python3.exe -m aqt install-qt windows desktop "5.15.2" win64_msvc2019_64 -O "C:\Qt" -m qtcharts debug_info qtwebengine  -b https://qt-mirror.dannhauer.de/
```

### Install Scoop requirements

In your powershell execute: 

```
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

After scoop installation execute in powershell as Admin:

```
scoop install llvm --global
scoop install ninja --global
scoop install cmake --global
scoop install git --global
scoop install 7zip  --global
```

- Next, add a `QT_INSTALL_CMAKE_PATH` environment variable pointing to the msvc_2019x64 location

e.g.: `$Env:QT_INSTALL_CMAKE_PATH = "C:\Qt\5.15.2\msvc2019_64"`

- Then, also add a `QT_ROOT` environment variable pointing to the Qt root folder location

e.g.: `$Env:QT_ROOT = "C:\Qt"`

We advice to set it permanently through the environment variable manager on windows.


### Install Libwally

Libwally build requires tools only available in Development powershell environment. If unsure, start powershell from inside VisualStudio to execute following steps:

```
git clone -b v0.8.5 --recurse-submodules https://github.com/KomodoPlatform/libwally-core.git
cd libwally-core
$env:LIBWALLY_DIR=$pwd

git submodule init
git submodule sync --recursive
git submodule update --init --recursive
Get-ChildItem -Filter build -Recurse -ErrorAction SilentlyContinue

"$env:LIBWALLY_DIR\tools\msvc\gen_ecmult_static_context.bat"
copy src\ccan\ccan\str\hex\hex.c src\ccan\ccan\str\hex\hex_.c
copy src\ccan\ccan\base64\base64.c src\ccan\ccan\base64\base64_.c
cl /utf-8 /DUSE_ECMULT_STATIC_PRECOMPUTATION /DECMULT_WINDOW_SIZE=15 /DWALLY_CORE_BUILD /DHAVE_CONFIG_H /DSECP256K1_BUILD /I$env:LIBWALLY_DIR\src\wrap_js\windows_config /I$env:LIBWALLY_DIR /I$env:LIBWALLY_DIR\src /I$env:LIBWALLY_DIR\include /I$env:LIBWALLY_DIR\src\ccan /I$env:LIBWALLY_DIR\src\ccan\base64 /I$env:LIBWALLY_DIR\src\secp256k1 /Zi /LD src/aes.c src/anti_exfil.c src/base58.c src/base64.c src/bech32.c src/bip32.c src/bip38.c src/bip39.c src/blech32.c src/ecdh.c src/elements.c src/hex.c src/hmac.c src/internal.c src/mnemonic.c src/pbkdf2.c src/pullpush.c src/psbt.c src/script.c src/scrypt.c src/sign.c src/symmetric.c src/transaction.c src/wif.c src/wordlist.c src/ccan/ccan/crypto/ripemd160/ripemd160.c src/ccan/ccan/crypto/sha256/sha256.c src/ccan/ccan/crypto/sha512/sha512.c src/ccan/ccan/base64/base64_.c src\ccan\ccan\str\hex\hex_.c src/secp256k1/src/secp256k1.c src/secp256k1/src/precomputed_ecmult_gen.c src/secp256k1/src/precomputed_ecmult.c /Fewally.dll

# After cloning komodo-wallet-desktop, copy the wally.dll file
Copy-Item "$env:LIBWALLY_DIR\wally.dll" -Destination "komodo-wallet-desktop\wally\wally.dll" -force
```

### Bootstrap VCPKG modules

```bash
cd komodo-wallet-desktop\ci_tools_atomic_dex\vcpkg-repo
.\bootstrap-vcpkg.bat
```

### Build komodo-wallet-desktop (portable)

In your shell command prompt (Powershell/Zsh/Bash), from within the `root` folder (e.g. ~/komodo-wallet-desktop), started as Administrator, type:

```bash
cd komodo-wallet-desktop\build              # create the 'build' folder if it doesn't exist
cmake -DCMAKE_BUILD_TYPE=Release ../ -GNinja
cmake --build . --config Release --target komodo-wallet
```

### Bundle komodo-wallet-desktop (installer)

```
cd komodo-wallet-desktop\build              # create the 'build' folder if it doesn't exist
cmake -DCMAKE_BUILD_TYPE=Release -GNinja ../
cmake --build . --config Release --target komodo-wallet
ninja install
```