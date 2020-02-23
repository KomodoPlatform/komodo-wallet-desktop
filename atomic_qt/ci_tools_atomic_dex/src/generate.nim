import os
import osproc
import vcpkg
import dependencies

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
    let cmd_line = "cmake -GNinja -DCMAKE_TOOLCHAIN_FILE=" & 
                    g_vcpkg_cmake_script_path & " " & 
                    os.getCurrentDir().parentDir().parentDir() & " -DVCPKG_APPLOCAL_DEPS=OFF " & "-DCMAKE_PREFIX_PATH=" & os.getEnv("QT_INSTALL_CMAKE_PATH")
    discard execCmd(cmd_line)
