import os
import asyncdispatch, httpclient
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

proc asyncProc() {.async.} =
    echo "Downloading mm2"
    when defined(macosx):
        filename = target_filename & "_darwin" & target_file_extensions
        await client.downloadFile("http://195.201.0.6/mm2/mm2-latest-Darwin.zip",
                target_dir & "/" & filename)
    echo "Downloading Finished"

waitFor asyncProc()

var z: ZipArchive
echo "Opening: " & target_dir & "/" & filename
if not z.open(target_dir & "/" & filename):
    echo "Opening zip failed"
    quit(1)
z.extractAll(os.CurDir & "/assets/tools/mm2")

os.removeDir(target_dir)
