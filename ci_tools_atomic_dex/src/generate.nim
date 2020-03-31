import os
import osproc
import vcpkg
import dependencies

proc get_windows_deploy_cmd*() : string =
    let windeploypath = os.getEnv("QT_INSTALL_CMAKE_PATH").joinPath("bin").joinPath("windeployqt.exe")
    result = windeploypath & " .\\bin\\ --qmldir " & os.getCurrentDir().parentDir().parentDir().joinPath("atomic_qt_design/qml")
    echo result

proc generate_solution*(build_type: string) =
    download_packages()
    var full_name = "build-" & build_type 
    if not os.existsDir(os.getCurrentDir().joinPath(full_name)):
        echo "creating directory: " & full_name 
        os.createDir(full_name)
    else:
        echo "existing directory: " & full_name
    os.setCurrentDir(os.getCurrentDir().joinPath(full_name))
    assert(os.existsEnv("QT_INSTALL_CMAKE_PATH"))
    var cmd_line = "cmake -GNinja -DCMAKE_BUILD_TYPE=" &  build_type & " -DCMAKE_TOOLCHAIN_FILE=" & 
                    g_vcpkg_cmake_script_path & " " & 
                    os.getCurrentDir().parentDir().parentDir() & " -DCMAKE_PREFIX_PATH=" & os.getEnv("QT_INSTALL_CMAKE_PATH")
    when defined(osx):
        cmd_line = cmd_line & " -DVCPKG_APPLOCAL_DEPS=OFF " & " -DCMAKE_CXX_COMPILER=/usr/local/opt/llvm@9/bin/clang++"
    when defined(windows) or defined(linux):
        cmd_line = cmd_line & " -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang"
    echo "cmd line: " & cmd_line
    discard execCmd(cmd_line)
    when defined(windows):
        discard execCmd(get_windows_deploy_cmd())