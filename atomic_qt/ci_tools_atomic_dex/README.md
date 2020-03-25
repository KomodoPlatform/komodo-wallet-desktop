## Prerequisites

- CMake 3.14 minimum
- Git
- clang C++ 17 compiler (clang-8 minimum) (if OSX Catalina Apple Clang 11.0 will be picked by default)
- QT_INSTALL_CMAKE_PATH environment variable pointing to the CMake script of QT (for osx/linux)
- QT_INSTALL_CMAKE_PATH environment variable pointing to msvc_2017x64 for windows
- On windows the executable need to be launch in the x64 native tools 2019 command line from visual studio
- Ninja

## OSX Quick start

- Install QT 5.14
- Install nim
```
brew install ninja cmake
nimble build
./ci_tools_atomic_dex.exe build release
```

## Windows Quick start

- Install QT 5.14
- Install Scoop
- Install nim

launch a powershell at admin and run:

```
scoop install llvm ninja cmake git --global
nimble build
ci_tools_atomic_dex.exe build release
```

## Linux QuickStart

- Install QT 5.14
- Install nim
```
curl https://nim-lang.org/choosenim/init.sh -sSf | sh
sudo apt-get install ninja cmake clang ## Adapt to last version if possible
nimble build
./ci_tools_atomic_dex.exe build release
```
