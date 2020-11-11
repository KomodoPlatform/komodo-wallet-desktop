import os
import osproc

import build
import vcpkg

proc fix_osx_libraries(atomic_app_path: string) =
    let 
        framework_path = atomic_app_path.joinPath("Contents/Frameworks")
        orig_path = os.getCurrentDir()
        cmd_fix = "install_name_tool -add_rpath @executable_path/../../../../../../Frameworks " & framework_path.joinPath("QtWebEngineCore.framework/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess")
    echo "CWD: " & orig_path
    echo "Framework path: " & framework_path 
    os.setCurrentDir(framework_path)
    echo "CWD: " & framework_path
    discard osproc.execCmd(cmd_fix)


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
            bundling_cmd = qt_macdeploy_path & " " & atomicdex_desktop_app_path & " -qmldir=" & atomicdex_desktop_qml_dir
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
            #dll_path_vcpkg = os.getCurrentDir().parentDir().joinPath("vcpkg-repo").joinPath("installed").joinPath("x64-windows").joinPath("bin")
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            #Copy-Item C:\Code\Trunk -Filter *.csproj.user -Destination C:\Code\F2 -Recurse
            #pwsh_cmd = "Get-ChildItem " & dll_path & " | Copy-Item -Destination " & build_path & " -Recurse -filter *.dll"
            #pwsh_cmd_vcpkg = "Get-ChildItem " & dll_path_vcpkg & " | Copy-Item -Destination " & build_path & " -Recurse -filter *.dll"
            pwsh_cmd_mm2 = "Get-ChildItem " & dll_path & " | Copy-Item -Destination " & mm2_path & " -Recurse -filter *.dll"
            #copy_dll_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd & " }\""
            copy_dll_mm2_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd_mm2 & " }\""
            #copy_dll_vcpkg_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd_vcpkg & " }\""
            bundle_cmd = "powershell.exe -nologo -noprofile -command \"& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('bin', 'bin.zip'); }\""

        #echo copy_dll_cmd
        #discard osproc.execCmd(copy_dll_cmd)
        #discard osproc.execCmd(copy_dll_cmd)
        #discard osproc.execCmd(copy_dll_vcpkg_cmd)
        discard osproc.execCmd(bundle_cmd)
        discard os.existsOrCreateDir(bundle_path)
        os.moveFile("bin.zip", bundle_path.joinPath("bundle.zip"))
    when defined(linux):
        echo "current dir is: " & os.getCurrentDir()
        discard osproc.execCmd("ninja install")


