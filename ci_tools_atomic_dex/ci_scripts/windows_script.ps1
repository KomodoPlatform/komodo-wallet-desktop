Set-ExecutionPolicy RemoteSigned -scope CurrentUser

Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
scoop install llvm --global --RunAsAdmin
scoop install ninja --global --RunAsAdmin
scoop install cmake@3.22.0 --global --RunAsAdmin
scoop install git --global --RunAsAdmin
scoop install 7zip  --global --RunAsAdmin
scoop cache rm 7zip
scoop cache rm git
scoop cache rm cmake
scoop cache rm ninja
scoop cache rm llvm
$Env:QT_INSTALL_CMAKE_PATH = "C:\Qt\$Env:QT_VERSION\msvc2019_64"
$Env:QT_ROOT = "C:\Qt"
mkdir b
cd b
cmake --version
cmake -DCMAKE_BUILD_TYPE=Release -GNinja ../
ninja install
