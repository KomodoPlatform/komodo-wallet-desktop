import osproc
import vcpkg

let g_packages = [
    (name: "jsoncpp", head: false),
    (name: "entt", head: false),
    (name: "folly", head: false),
    (name: "boost-multiprecision", head: false),
    (name: "boost-random", head: false),
    (name: "doctest", head: false),
    (name: "fmt", head: false),
    (name: "curl", head: false),
    (name: "nlohmann-json", head: false),
    (name: "range-v3", head: false),
    (name: "libsodium", head: false),
    (name: "date", head: false)]

proc download_packages*() =
    echo "Downloading packages ... please wait"
    for idx, package in g_packages:
        if package.head:
            when defined(windows):
                discard execCmd(g_vcpkg_local_path & " install " & package.name & ":x64-windows --head")
            when defined(linux) or defined(osx):
                discard execCmd(g_vcpkg_local_path & " install " & package.name & " --head")
        else:
            when defined(windows):
                discard execCmd(g_vcpkg_local_path & " install " & package.name & ":x64-windows")
            when defined(linux) or defined(osx):
                discard execCmd(g_vcpkg_local_path & " install " & package.name)
    echo "Downloading packages finished"
