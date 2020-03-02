## Prerequisites

- CMake 3.14 minimum
- clang C++ 17 compiler (clang-8 minimum)
- QT_INSTALL_CMAKE_PATH environment variable pointing to the CMake script of QT (for osx/linux)
- QT_INSTALL_CMAKE_PATH environment variable pointing to msvc_2017x64 for windows
- On windows the executable need to be launch in the x64 native tools 2019 command line from visual studio
- Ninja

## OSX Quick start

- Install QT 5.14
```
brew install ninja cmake
```

## Windows Quick start

- Install QT 5.14
- Install Scoop

launch a powershell at admin and run:
```
scoop install llvm ninja cmake --global
```