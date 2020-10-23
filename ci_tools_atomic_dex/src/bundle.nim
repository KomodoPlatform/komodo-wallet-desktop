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
    discard osproc.execCmd("install_name_tool -change @loader_path/libboost_system-mt.dylib @executable_path/../Frameworks/libboost_system.dylib libboost_locale-mt.dylib")
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
            dmg_name = "atomicdex-desktop"
            app_name = "atomicdex-desktop"
            atomicdex_desktop_app_dir = os.getCurrentDir().joinPath("bin")
            atomicdex_desktop_app_path = atomicdex_desktop_app_dir.joinPath(app_name & ".app")
            atomicdex_desktop_qml_dir = os.getCurrentDir().parentDir().parentDir().joinPath("atomic_defi_design/qml")
            bundling_cmd = qt_mac_deploy_path & " " & atomicdex_desktop_app_path & " -qmldir=" & atomicdex_desktop_qml_dir
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            dmg_packager_path = os.getCurrentDir().parentDir().joinPath("dmg-packager").joinPath("package.sh")
            dmg_packaging_cmd = dmg_packager_path & " \"" & dmg_name & "\" " & app_name & " " & atomicdex_desktop_app_dir & "/"
            created_dmg_path = atomicdex_desktop_app_path.parentDir().joinPath(dmg_name & ".dmg")
            final_dmg_path = bundle_path.joinPath(dmg_name & ".dmg")

        echo "Bundling cmd: " & bundling_cmd
        discard osproc.execCmd(bundling_cmd)
        fix_osx_libraries(atomicdex_desktop_app_path)

        echo "DMG Packaging cmd: " & dmg_packaging_cmd
        discard osproc.execCmd(dmg_packaging_cmd)

        echo "Creating bundle folder: " & bundle_path
        discard os.existsOrCreateDir(bundle_path)

        echo "Copy .dmg to bundle path: " & created_dmg_path & "   to   " & final_dmg_path
        os.copyFile(created_dmg_path, final_dmg_path)

    when defined(windows):
        let
            build_path =  os.getCurrentDir().parentDir().joinPath("build-" & build_type).joinPath("bin")
            mm2_path =  os.getCurrentDir().parentDir().joinPath("build-" & build_type).joinPath("bin").joinPath("assets").joinPath("tools").joinPath("mm2")
            dll_path   = os.getCurrentDir().parentDir().joinPath("windows_misc")
            dll_path_vcpkg = os.getCurrentDir().parentDir().joinPath("vcpkg-repo").joinPath("installed").joinPath("x64-windows").joinPath("bin")
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            #Copy-Item C:\Code\Trunk -Filter *.csproj.user -Destination C:\Code\F2 -Recurse
            pwsh_cmd = "Get-ChildItem " & dll_path & " | Copy-Item -Destination " & build_path & " -Recurse -filter *.dll"
            pwsh_cmd_vcpkg = "Get-ChildItem " & dll_path_vcpkg & " | Copy-Item -Destination " & build_path & " -Recurse -filter *.dll"
            pwsh_cmd_mm2 = "Get-ChildItem " & dll_path & " | Copy-Item -Destination " & mm2_path & " -Recurse -filter *.dll"
            copy_dll_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd & " }\""
            copy_dll_mm2_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd_mm2 & " }\""
            copy_dll_vcpkg_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd_vcpkg & " }\""
            bundle_cmd = "powershell.exe -nologo -noprofile -command \"& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('bin', 'bin.zip'); }\""

        echo copy_dll_cmd
        discard osproc.execCmd(copy_dll_cmd)
        discard osproc.execCmd(copy_dll_cmd)
        discard osproc.execCmd(copy_dll_vcpkg_cmd)
        discard osproc.execCmd(bundle_cmd)
        discard os.existsOrCreateDir(bundle_path)
        os.moveFile("bin.zip", bundle_path.joinPath("bundle.zip"))
    when defined(linux):
        let
            build_path =  os.getCurrentDir().parentDir().joinPath("build-" & build_type).joinPath("bin")
            desktop_path = build_path.joinPath("AntaraAtomicDexAppDir/usr/share/applications/atomicdex-desktop.desktop")
            atomicdex_desktop_qml_dir = os.getCurrentDir().parentDir().parentDir().joinPath("atomic_defi_design/qml")
            linux_deploy_tool = os.getCurrentDir().parentDir().joinPath("linux_misc").joinPath("linuxdeployqt-continuous-x86_64.AppImage")
            bundling_cmd = linux_deploy_tool & " " & desktop_path & " -qmldir=" & atomicdex_desktop_qml_dir & " -bundle-non-qt-libs -exclude-libs=\"libnss3.so,libnssutil3.so\""
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            tar_cmd = "tar -czvf AntaraAtomicDexAppDir.tar.gz -C " & build_path.joinPath("AntaraAtomicDexAppDir").parentDir() & " ."

        echo "Bundling cmd: " & bundling_cmd
        discard osproc.execCmd(bundling_cmd)
        
        echo "Creating bundle folder: " & bundle_path
        discard os.existsOrCreateDir(bundle_path)
        os.setCurrentDir(bundle_path)

        echo "Copying extra lib before"
        var output_dir = $build_path.joinPath("AntaraAtomicDexAppDir").joinPath("usr").joinPath("lib")
        var list_of_libs = ["libsmime3.so", "libssl3.so"]
        for idx, cur_lib in list_of_libs:
            os.copyFile("/usr/lib/x86_64-linux-gnu/" & cur_lib, output_dir & "/" & cur_lib)
        var list_of_other_libs = ["libfreebl3.chk", "libfreebl3.so", "libnssckbi.so", "libnssdbm3.chk", "libnssdbm3.so", "libnsssysinit.so", "libsoftokn3.chk", "libsoftokn3.so"]
        for idx, cur_lib in list_of_other_libs:
           os.copyFile("/usr/lib/x86_64-linux-gnu/nss/" & cur_lib, output_dir & "/" & cur_lib)
        #discard os.copyFile("/usr/lib/x86_64-linux-gnu/libnss3.so", output_dir.joinPath("libnss3.so").string)

        echo "Tar cmd: " & tar_cmd
        discard osproc.execCmd(tar_cmd)


