import os
import osproc

import build
import vcpkg

proc bundle*(build_type: string, osx_sdk_path: string, compiler_path: string) =
    build_atomic_qt(build_type, osx_sdk_path, compiler_path)
    when defined(osx):
        discard osproc.execCmd("ninja install")

    when defined(windows):
        let
            build_path =  os.getCurrentDir().parentDir().joinPath("build-" & build_type).joinPath("bin")
            mm2_path =  os.getCurrentDir().parentDir().joinPath("build-" & build_type).joinPath("bin").joinPath("assets").joinPath("tools").joinPath("mm2")
            dll_path   = os.getCurrentDir().parentDir().joinPath("windows_misc")
            bundle_path = os.getCurrentDir().parentDir().joinPath("bundle-" & build_type)
            pwsh_cmd_mm2 = "Get-ChildItem " & dll_path & " | Copy-Item -Destination " & mm2_path & " -Recurse -filter *.dll"
            copy_dll_mm2_cmd = "powershell.exe -nologo -noprofile -command \"& { " & pwsh_cmd_mm2 & " }\""
            bundle_cmd = "powershell.exe -nologo -noprofile -command \"& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('bin', 'bin.zip'); }\""

        discard osproc.execCmd(bundle_cmd)
        discard os.existsOrCreateDir(bundle_path)
        os.moveFile("bin.zip", bundle_path.joinPath("bundle.zip"))
    when defined(linux):
        echo "current dir is: " & os.getCurrentDir()
        discard osproc.execCmd("ninja install")


