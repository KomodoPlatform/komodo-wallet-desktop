import os

proc remove_vcpkg()=
    if os.existsDir("vcpkg-repo"):
        os.removeDir("vcpkg-repo")

proc remove_build()=
    if os.existsDir("build-debug"):
        os.removeDir("build-debug")
    if os.existsDir("build-release"):
        os.removeDir("build-release")

proc clean*(clean_type: string) =
    echo "Cleaning"
    if clean_type == "dependencies":
        remove_vcpkg()
    elif clean_type == "build_dir":
        remove_build()
    elif clean_type == "full":
        remove_vcpkg()
        remove_build()