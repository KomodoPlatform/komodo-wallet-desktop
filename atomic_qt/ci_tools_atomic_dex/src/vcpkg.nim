import os
import osproc

var g_vcpkg_local_path* = ""

proc check_if_vcpkg_exists(): bool =
    result = os.existsDir("vcpkg-repo")

proc build_vcpkg() =
    g_vcpkg_local_path = os.getCurrentDir().joinPath("vcpkg-repo").joinPath("vcpkg")
    when defined(windows):
        g_vcpkg_local_path.addFileExt(".exe")
    echo g_vcpkg_local_path
    if not os.existsFile(g_vcpkg_local_path):
        echo "building vcpkg"
        os.setCurrentDir("vcpkg-repo")
        when defined(windows):
            discard execCmd("bootstrap-vcpkg.bat")
        when defined(linux) or defined(macosx):
            discard execCmd("./bootstrap-vcpkg.sh")
        os.setCurrentDir(os.parentDir(os.getCurrentDir()))
    else:
        echo "vcpkg already builded, skipping"

proc install_vcpkg*() =
    if not check_if_vcpkg_exists():
        echo "Installing vcpkg"
        discard execCmd("git clone https://github.com/microsoft/vcpkg vcpkg-repo")
        build_vcpkg()
    else:
        echo "vcpkg repo exist"
        build_vcpkg()

