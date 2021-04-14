message(STATUS "VCPKG package manager enabled")
set(VCPKG_OVERLAY_PORTS "${CMAKE_CURRENT_SOURCE_DIR}/ci_tools_atomic_dex/vcpkg-custom-ports/ports" CACHE STRING "")
set(_VCPKG_INSTALLED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ci_tools_atomic_dex/vcpkg-repo/installed")
set(CMAKE_TOOLCHAIN_FILE
        "${CMAKE_CURRENT_SOURCE_DIR}/ci_tools_atomic_dex/vcpkg-repo/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "")
if (WIN32)
    set(VCPKG_TARGET_TRIPLET "x64-windows" CACHE STRING "")
endif ()

if (APPLE)
    set(VCPKG_APPLOCAL_DEPS OFF CACHE BOOL "")
endif ()