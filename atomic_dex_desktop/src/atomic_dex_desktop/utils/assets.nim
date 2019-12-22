import os

proc getAssetsPath*() : string {.inline.} =
    result = os.getAppDir() & "/assets"
    when defined(macosx):
        result = os.getAppDir().parentDir &  "/Resources/assets"
    when defined(linux):
        result = os.getAppDir().parentDir &  "/share/assets"    
    result.normalizePath