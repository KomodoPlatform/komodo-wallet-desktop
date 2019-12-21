# Package

version = "1.0.0"
author = "milerius"
description = "Atomic Dex Desktop nim"
license = "GPL-2.0"
srcDir = "src"
bin = @["atomic_dex_desktop"]
backend = "cpp"

when defined(macosx):
    binDir = "bin/atomic_dex_desktop.app/Contents/MacOS"
    cpFile("data/osx/Info.plist", "bin/atomic_dex_desktop.app/Contents/Info.plist")
    cpDir("assets", "bin/atomic_dex_desktop.app/Contents/Resources/assets")
    exec("chmod +x bin/atomic_dex_desktop.app/Contents/Resources/assets/tools/mm2/mm2")

when defined(windows):
    binDir = "bin"
    cpDir("assets", "bin/assets")

when defined(linux):
    binDir = "bin/AtomicDexAppDir/usr/bin"
    cpDir("assets", "bin/AtomicDexAppDir/usr/share/assets")
    exec("chmod +x bin/AtomicDexAppDir/usr/share/assets/tools/mm2/mm2")
    exec("mkdir -p bin/AtomicDexAppDir/usr/share/icons/hicolor/128x128/apps/ && mkdir -p bin/AtomicDexAppDir/usr/share/metainfo/ && mkdir -p bin/AtomicDexAppDir/usr/share/applications/")
    cpFile("data/linux/komodo_icon.png", "bin/AtomicDexAppDir/usr/share/icons/hicolor/128x128/apps/komodo_icon.png")
    cpFile("data/linux/org.antara.gaming.atomicdex.appdata.xml", "bin/AtomicDexAppDir/usr/share/metainfo/org.antara.gaming.atomicdex.appdata.xml")
    cpFile("data/linux/org.antara.gaming.atomicdex.desktop", "bin/AtomicDexAppDir/usr/share/applications/org.antara.gaming.atomicdex.desktop")
    if not system.fileExists("tools/https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"):
        withDir("tools"):
            exec("curl https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage -o linuxdeploy-x86-64.AppImage")

requires "nim >= 1.0.4"
requires "ui_workflow_nim >= 0.6.0"
requires "jsonschema"

task download_deps, "Download MM2 Dependencies":
    exec "nim c -r tools/dependencies.nim"
