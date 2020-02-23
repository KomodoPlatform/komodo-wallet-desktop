import osproc
import vcpkg

let g_packages = [
    (name: "entt", head: true),
    (name: "folly", head: false),
    (name: "doctest", head: false),
    (name: "fmt", head: true),
    (name: "nlohmann-json", head: false),
    (name: "range-v3", head: false),
    (name: "libsodium", head: false),
    (name: "date", head: false)]

proc download_packages*() =
    echo "Downloading packages ... please wait"
    for idx, package in g_packages:
        if package.head:
            discard execCmd(g_vcpkg_local_path & " install " & package.name & " --head")
        else:
            discard execCmd(g_vcpkg_local_path & " install " & package.name)
    echo "Downloading packages finished"
