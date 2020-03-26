# AtomicDEX Pro alpha build instructions

## Prerequisites

- Visual Studio 2019 (Windows)
- Clang C++ 17 compiler (clang-8 minimum)
    - on macOS Catalina, Apple Clang 11.0 is picked by default 
- CMake 3.14 minimum (https://cmake.org/download/)

### Dependencies

Follow the QT installation (5.14) instructions here: https://www.qt.io/download

#### Windows

Open powershell as admin and type: 

```
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')

scoop install nim --global
scoop install llvm --global
scoop install ninja --global
scoop install cmake --global
scoop install git --global
```

- add `QT_INSTALL_CMAKE_PATH` environment variable pointing to msvc_2017x64 for windows

Example: `C:\Qt\5.14.1\msvc2017_64`


#### Osx

Ensure you have [brew](https://brew.sh) and Command Line Tools installed.

```shell
brew install nim cmake ninja git
```

In your `~/.bashrc` or `~/.zshrc` add:
 * `QT_INSTALL_CMAKE_PATH` equal to the CMake QT PATH
 * `QT_ROOT` equal to the QT Root installation folder

Example:
```bash
export QT_INSTALL_CMAKE_PATH=/Users/romanszterg/Qt/5.14.0/clang_64/lib/cmake
export QT_ROOT=/Users/romanszterg/Qt/5.14.0
```

#### Linux

Open a terminal and type:

```shell
sudo apt-get install -y ninja-build cmake git

curl https://nim-lang.org/choosenim/init.sh -sSf | sh

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 9
```

Make sure that `clang` point to the last version installed using update alternatives:

`sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 100`
`sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 100`


In your `~/.bashrc` or `~/.zshrc` you will need:
 * `QT_INSTALL_CMAKE_PATH` equal to the CMake QT PATH
 * `QT_ROOT` equal to the QT Root installation folder

Example:
```bash
export QT_INSTALL_CMAKE_PATH=~/Qt/5.14.0/gcc/lib/cmake
export QT_ROOT=~/Qt/5.14.0
```

## Build AtomicDex

### Windows

Open an x64 Visual studio command prompt, go to the `ci_tools_atomic_dex` folder and type:

```bash
nimble build
./ci_tools_atomic_dex.exe build release
./ci_tools_atomic_dex.exe build debug
```

### OSX/Linux

Open a terminal, go to the `ci_tools_atomic_dex` folder and type:

```bash
nimble build
./ci_tools_atomic_dex build debug
./ci_tools_atomic_dex build release
```

## Bundle AtomicDex

### Windows

Open an x64 Visual studio command prompt, go to the `ci_tools_atomic_dex` folder and type:

```
nimble build
./ci_tools_atomic_dex.exe build release
./ci_tools_atomic_dex.exe bundle release
./ci_tools_atomic_dex.exe build debug
./ci_tools_atomic_dex.exe bundle debug
```

### OSX

Open a terminal, go to the `ci_tools_atomic_dex` folder and type:

```
nimble build
./ci_tools_atomic_dex bundle release
./ci_tools_atomic_dex bundle debug
```




