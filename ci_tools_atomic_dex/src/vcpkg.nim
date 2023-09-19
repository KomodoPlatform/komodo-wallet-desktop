import os
import osproc

var g_vcpkg_local_path* = ""
var g_vcpkg_cmake_script_path* = ""

proc check_if_vcpkg_exists*(): bool =
    result = os.dirExists("vcpkg-repo")

proc build_vcpkg() =
    if not os.fileExists(g_vcpkg_local_path):
        echo "building vcpkg"
        os.setCurrentDir("vcpkg-repo")
        when defined(windows):
            discard execCmd(".\\bootstrap-vcpkg.bat")
        when defined(linux):
            discard execCmd("./bootstrap-vcpkg.sh")
        when defined(osx):
             discard execCmd("CXXFLAGS=\"-D_CTERMID_H_\" CXX=g++-9 ./bootstrap-vcpkg.sh")
        os.setCurrentDir(os.parentDir(os.getCurrentDir()))
    else:
        echo "vcpkg already builded, skipping"

proc set_vcpkg_path*() =
    g_vcpkg_local_path = os.getCurrentDir().joinPath("vcpkg-repo").joinPath("vcpkg")
    g_vcpkg_cmake_script_path = os.getCurrentDir().joinPath(
            "vcpkg-repo").joinPath("scripts").joinPath("buildsystems").joinPath("vcpkg.cmake")
    when defined(windows):
        discard g_vcpkg_local_path.addFileExt(".exe")
    echo g_vcpkg_local_path
    echo g_vcpkg_cmake_script_path

proc integrate_vcpkg() =
    discard execCmd(g_vcpkg_local_path & " integrate install")

proc install_vcpkg*() =
    set_vcpkg_path()
    if not check_if_vcpkg_exists():
        echo "Installing vcpkg"
        discard execCmd("git clone https://github.com/KomodoPlatform/vcpkg vcpkg-repo")
        build_vcpkg()
        integrate_vcpkg()
    else:
        echo "vcpkg repo exist"
        build_vcpkg()
        integrate_vcpkg()

proc vcpkg_prepare*() =
    if not check_if_vcpkg_exists():
        install_vcpkg()
    else:
        set_vcpkg_path()

