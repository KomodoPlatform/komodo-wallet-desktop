import os
import osproc
import asyncdispatch, httpclient

when defined(windows):
    #{.passC: "-I"  & os.getEnv("VCPKG_ROOT") & "/installed/x64-windows/include"}
    {.passL: "-lz"}
import zip/zipfiles

if os.existsDir(os.CurDir & "/assets/tools/mm2"):
    echo "Assets Already Downloaded"
    quit(0)

var client = newAsyncHttpClient()
var target_dir = os.CurDir & "/tmp"
var target_filename = "mm2"
var target_file_extensions = ".zip"
var filename = ""

if not os.existsDir(target_dir):
    echo "Create target dir: " & target_dir
    os.createDir(target_dir)

proc onProgressChanged(total, progress, speed: BiggestInt) {.async.} =
    echo("Downloaded ", progress, " of ", total)
    echo("Current rate: ", speed div 1000, "kb/s")

client.onProgressChanged = onProgressChanged

proc async_download_files(file: string, output: string) {.async.} =
    echo "Downloading " & file
    await client.downloadFile(file, output)
    echo "Downloading " & file & " Finished."


proc extract_zip(file: string, output: string) =
    var z: ZipArchive
    echo "Opening: " & file
    if not z.open(file):
        echo "Opening zip failed"
        quit(1)
    echo "Extracting: " & file    
    z.extractAll(output)
    echo "Extracting: " & file & " finished."

when defined(macosx):
    filename = target_filename & "_darwin" & target_file_extensions
    waitFor async_download_files("http://195.201.0.6/mm2/mm2-latest-Darwin.zip",
            target_dir & "/" & filename)

when defined(linux):
    filename = target_filename & "_linux" & target_file_extensions
    waitFor async_download_files("http://195.201.0.6/mm2/mm2-latest-Linux.zip",
            target_dir & "/" & filename)

when defined(windows):
    filename = target_filename & "_windows" & target_file_extensions
    waitFor async_download_files("http://195.201.0.6/mm2/mm2-latest-Windows_NT.zip",
            target_dir & "/" & filename)

extract_zip(target_dir & "/" & filename, os.CurDir & "/assets/tools/mm2")

when defined(linux):
    discard execCmd("chmod +x " & os.CurDir & "/assets/tools/mm2/mm2")

var git_target = "https://github.com/jl777/coins/archive/master.zip"

waitFor async_download_files(git_target, target_dir & "/coins.zip")
extract_zip(target_dir & "/coins.zip", target_dir & "/coins")
os.copyFile(target_dir & "/coins/coins-master/coins", os.CurDir & "/assets/tools/mm2/coins")

echo "Removing: " & target_dir & " directory."
os.removeDir(target_dir)
