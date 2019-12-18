import os

proc get_assets_path*() : string {.inline.} =
    var path = os.getAppDir() & "/assets"
    when defined(macosx):
        path = os.getAppDir().parentDir &  "/Resources/asssets"
    return path