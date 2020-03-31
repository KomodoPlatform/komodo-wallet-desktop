import os
import osproc

import build
import vcpkg

proc fix_osx_libraries(atomic_app_path: string) =
    let 
        framework_path = atomic_app_path.joinPath("Contents/Frameworks")
        orig_path = os.getCurrentDir()
    echo "CWD: " & orig_path
    echo "Framework path: " & framework_path 
    os.setCurrentDir(framework_path)
    echo "CWD: " & framework_path
    let libs = [(loname: "libboost_chrono-mt.dylib", lname: "libboost_locale-mt.dylib"), 
                (loname: "libboost_system-mt.dylib", lname: "libboost_locale-mt.dylib"),
                (loname: "libboost_thread-mt.dylib", lname: "libboost_locale-mt.dylib"), 
                (loname: "libboost_thread-mt.dylib", lname: "libboost_log-mt.dylib"),
                (loname: "libboost_regex-mt.dylib", lname: "libboost_log-mt.dylib"),
                (loname: "libboost_filesystem-mt.dylib", lname: "libboost_log-mt.dylib"),
                (loname: "libboost_atomic-mt.dylib", lname: "libboost_log-mt.dylib"),
                (loname: "libboost_chrono-mt.dylib", lname: "libboost_log-mt.dylib"),
                (loname: "libboost_date_time-mt.dylib", lname: "libboost_log-mt.dylib"),
                (loname: "libicuuc.64.dylib", lname: "libicui18n.64.dylib"),
                (loname: "libicudata.64.dylib", lname: "libicui18n.64.dylib"),
                (loname: "libicudata.64.dylib", lname: "libicuuc.64.dylib")
               ]
    for idx, info in libs:
        let cmd_fix = "install_name_tool -change @loader_path/" & info.loname & " @executable_path/../Frameworks/" & info.loname & " " & info.lname
        echo "Fixing cmd: " & cmd_fix
        discard osproc.execCmd(cmd_fix)
    discard osproc.execCmd("install_name_tool -change @executable_path/../Frameworks/libboost_filesystem-mt.dylib @executable_path/../Frameworks/libboost_filesystem.dylib libboost_log-mt.dylib")
    os.setCurrentDir(orig_path)
    echo "CWD: " & os.getCurrentDir()


proc bundle*(build_type: string, osx_sdk_path: string, compiler_path: string) =
    build_atomic_qt(build_type, osx_sdk_path, compiler_path)
    when defined(osx):
        var 
            qt_macdeploy_path = os.getEnv("QT_ROOT").joinPath("clang_64").joinPath("bin").joinPath("macdeployqt")
        if not os.existsDir(qt_macdeploy_path.parentDir):
            qt_macdeploy_path = os.getEnv("QT_ROOT").joinPath("bin").joinPath("macdeployqt")
        let
            atomic_qt_app_path = os.getCurrentDir().joinPath("bin/atomic_qt.app")
            atomic_qt_qml_dir = os.getCurrentDir().parentDir().parentDir().joinPath("atomic_qt_design/qml")
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            bundling_cmd = qt_mac_deploy_path & " " & atomic_qt_app_path & " -qmldir=" & atomic_qt_qml_dir & " -dmg"
        
        echo "Bundling cmd: " & bundling_cmd
        discard osproc.execCmd(bundling_cmd)
        fix_osx_libraries(atomic_qt_app_path)
        os.removeFile(atomic_qt_app_path.parentDir().joinPath("atomic_qt.dmg"))
        discard osproc.execCmd(bundling_cmd)
        discard os.existsOrCreateDir(bundle_path)
        os.copyFile(atomic_qt_app_path.parentDir().joinPath("atomic_qt.dmg"), bundle_path.joinPath("atomic_qt.dmg"))
    when defined(windows):
        let 
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            bundle_cmd = "powershell.exe -nologo -noprofile -command \"& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('bin', 'bin.zip'); }\""
        discard osproc.execCmd(bundle_cmd)
        discard os.existsOrCreateDir(bundle_path)
        os.moveFile("bin.zip", bundle_path.joinPath("bundle.zip"))


    