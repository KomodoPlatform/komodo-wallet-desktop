# Package

version       = "1.0.0"
author        = "milerius"
description   = "Atomic Dex Desktop nim"
license       = "GPL-2.0"
srcDir        = "src"
bin           = @["atomic_dex_desktop"]

backend       = "cpp"

# Dependencies

requires "nim >= 1.0.4"

task download_deps, "Download MM2 Dependencies":
    exec "nim c -r tools/dependencies.nim" 
