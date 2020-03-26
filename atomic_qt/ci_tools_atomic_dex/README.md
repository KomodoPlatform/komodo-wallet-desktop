# AtomicDEX Pro alpha build instructions

## Build AtomicDEX

### Installation of scoop (Windows only)

Open powershell as admin and type: 

```
Set-ExecutionPolicy RemoteSigned -scope CurrentUser
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
```

### Installation of qt

Follow the instructions here: https://www.qt.io/download

**Once QT is installed we add environment variable depending on your platform.**

#### Windows

- add `QT_INSTALL_CMAKE_PATH` environment variable pointing to msvc_2017x64 for windows

Example: `C:\Qt\5.14.1\msvc2017_64`

#### Osx

In your `~/.bashrc` or `~/.zshrc` add:
 * `QT_INSTALL_CMAKE_PATH` equal to the CMake QT PATH
 * `QT_ROOT` equal to the QT Root installation folder

Example:
```bash
export QT_INSTALL_CMAKE_PATH=/Users/romanszterg/Qt/5.14.0/clang_64/lib/cmake
export QT_ROOT=/Users/romanszterg/Qt/5.14.0
```

#### Linux

In your `~/.bashrc` or `~/.zshrc` you will need:
 * `QT_INSTALL_CMAKE_PATH` equal to the CMake QT PATH
 * `QT_ROOT` equal to the QT Root installation folder

Example:
```bash
export QT_INSTALL_CMAKE_PATH=~/Qt/5.14.0/gcc/lib/cmake
export QT_ROOT=~/Qt/5.14.0
```

### Installation of nim

#### OSX/Linux

Open a terminal and type:

`curl https://nim-lang.org/choosenim/init.sh -sSf | sh`

on OSX you can alternatively use brew:

`brew install nim`

At the end of the installation you will have a line to add into your `.bashrc` / `.zshrc` shell configuration file. (if you install with the curl tool)

#### Windows

Open a powershell as admin and type:

`scoop install nim --global`

### Installation of CMake (Mini 3.14) / Clang (mini 8.0 or AppleClang 11.0) / Ninja / Git

#### Windows

Open a powershell as admin and type:

```sh
scoop install llvm --global
scoop install ninja --global
scoop install cmake --global
scoop install git --global
```

#### OSX

If you have OSX Catalina, the Apple Clang version is a supported version

Open a terminal and type:
```
brew install cmake ninja git
```

#### Linux

Open a terminal and type:

```
sudo apt-get install -y ninja-build cmake git

wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 9
```

Make sure that `clang` point to the last version installed using update alternatives:

`sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-9 100`
`sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-9 100`

**Version 8.0 clang minimum is required and CMake 3.14**

### Build the project

Go to the `ci_tools_atomic_dex` folder and type:

```bash
nimble build
./ci_tools_atomic_dex.exe build release # Windows
./ci_tools_atomic_dex build release # OSX Linux
```



