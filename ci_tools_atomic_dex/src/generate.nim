import os
import osproc
import vcpkg
import dependencies
    
proc generate_solution*(build_type: string, osx_sdk_path: string, compiler_path: string) =
    download_packages()
    var full_name = "build-" & build_type 
    if not os.dirExists(os.getCurrentDir().joinPath(full_name)):
        echo "creating directory: " & full_name 
        os.createDir(full_name)
    else:
        echo "existing directory: " & full_name
    os.setCurrentDir(os.getCurrentDir().joinPath(full_name))
    assert(os.existsEnv("QT_INSTALL_CMAKE_PATH"))
    var cmd_line = "cmake -GNinja -DCMAKE_BUILD_TYPE=" &  build_type & " " &
                    os.getCurrentDir().parentDir().parentDir()
    when defined(osx):
        if os.dirExists(osx_sdk_path):
            cmd_line = cmd_line & " -DCMAKE_OSX_SYSROOT=" & osx_sdk_path & " -DCMAKE_OSX_DEPLOYMENT_TARGET=14.2"
    echo "cmd line: " & cmd_line
    discard execCmd(cmd_line)
