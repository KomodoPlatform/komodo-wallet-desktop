import os
import osproc
import vcpkg
import dependencies
    
proc generate_solution*(build_type: string, osx_sdk_path: string, compiler_path: string) =
    download_packages()
    var full_name = "build-" & build_type 
    os.setCurrentDir(os.getEnv("PROJECT_ROOT_DIR"))
    if not os.existsDir(os.getEnv("PROJECT_ROOT_DIR").joinPath(full_name)):
        os.createDir(full_name)
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo os.getCurrentDir()
        echo "creating directory: " & full_name
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
    else:
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
        echo os.getCurrentDir()
        echo "existing directory: " & full_name
        echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

    echo os.getEnv("PROJECT_ROOT_DIR")
    echo os.getEnv("PROJECT_ROOT_DIR").joinPath(full_name))
    os.setCurrentDir(os.getEnv("PROJECT_ROOT_DIR").joinPath(full_name))
    echo os.getCurrentDir()

    assert(os.existsEnv("QT_INSTALL_CMAKE_PATH"))
    var cmd_line = "cmake -GNinja -DCMAKE_BUILD_TYPE=" & build_type & " " & os.getEnv("PROJECT_ROOT_DIR")
    when defined(osx):
        if not osx_sdk_path.isNil() and osx_sdk_path != "nil":
            cmd_line = cmd_line & " -DCMAKE_OSX_SYSROOT=" & osx_sdk_path & " -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 -DPREFER_BOOST_FILESYSTEM=ON"
    echo "cmd line: " & cmd_line
    discard execCmd(cmd_line)
