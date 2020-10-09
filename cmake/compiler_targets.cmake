add_library(antara_error_settings INTERFACE)


# Using namespaces causes CMake to error our in case of typos on the
# consuming side, very important.
add_library(antara::error_settings ALIAS antara_error_settings)

##! We use only clang for simplicity
target_compile_options(
        antara_error_settings
        INTERFACE
        $<$<AND:$<PLATFORM_ID:Linux>,$<CXX_COMPILER_ID:Clang>>:-Wall -Wextra -Wfatal-errors>
        $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:Clang>>:-Wall -Wextra -Wfatal-errors>
        $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:AppleClang>>:-Wall -Wextra -Wfatal-errors>
        $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<BOOL:${ClangCL}>>,$<CXX_COMPILER_ID:Clang>>:-Wall -Wextra -Wfatal-errors>
        $<$<AND:$<PLATFORM_ID:Windows>,$<BOOL:${ClangCL}>,$<CXX_COMPILER_ID:Clang>>:/W4 /permissive->
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:MSVC>>:/W4 /permissive- /std:c++latest>)

# $<$<AND:$<PLATFORM_ID:Windows>,$<NOT:$<BOOL:${ClangCL}>>,$<CXX_COMPILER_ID:Clang>>:-Wall -Wextra -Wfatal-errors>
# $<$<AND:$<PLATFORM_ID:Windows>,$<BOOL:${ClangCL}>,$<CXX_COMPILER_ID:Clang>>:/W4 /permissive->
##! We are using C++ 17 for all of our targets
add_library(antara_defaults_features INTERFACE)
add_library(antara::defaults_features ALIAS antara_defaults_features)
if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    target_compile_features(antara_defaults_features INTERFACE cxx_std_17)
else()
    target_compile_features(antara_defaults_features INTERFACE cxx_std_20)
endif()

add_library(antara_optimize_settings INTERFACE)
add_library(antara::optimize_settings ALIAS antara_optimize_settings)

##! Msvc flags info
# /Zi - Produces a program database (PDB) that contains type information and symbolic debugging information for use with the debugger.
# /FS - Allows multiple cl.exe processes to write to the same .pdb file
# /DEBUG - Enable debug during linking
# /Od - Disables optimization
# /Ox - Full optimization
# /Oy- do not suppress frame pointers (recommended for debugging)

target_compile_options(antara_optimize_settings INTERFACE
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Linux>>:-O0 -g>
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Linux>>:-O3 --target=x86_64-unknown-linux-gui -ffast-math>
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Darwin>>:-O0 -g>
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Darwin>>:-O3 -ffast-math>
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:AppleClang>,$<PLATFORM_ID:Darwin>>:-O0 -g>
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:AppleClang>,$<PLATFORM_ID:Darwin>>:-O3 -ffast-math>
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Windows>,$<NOT:$<BOOL:${ClangCL}>>>:-O0 -g>
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Windows>,$<NOT:$<BOOL:${ClangCL}>>>:-O1>
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Windows>,$<BOOL:${ClangCL}>>:/Zi /FS /DEBUG /Od /MDd /Oy->
        $<$<AND:$<CONFIG:Debug>,$<CXX_COMPILER_ID:MSVC>>:/Zi /FS /DEBUG /Od /MDd /Oy->
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:MSVC>>:/Ox -DNDEBUG>
        $<$<AND:$<CONFIG:Release>,$<CXX_COMPILER_ID:Clang>,$<PLATFORM_ID:Windows>,$<BOOL:${ClangCL}>>:/Ox -DNDEBUG>
        )


if (NOT "${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
    if (NOT APPLE)
        find_package(OpenMP)
        if (OpenMP_CXX_FOUND)
            message(STATUS "OpenMP found, adding it to targets")
            target_link_libraries(antara_optimize_settings INTERFACE OpenMP::OpenMP_CXX)
        endif ()
    else ()
        find_library(OpenMP_LIBRARY
                NAMES omp
                )

        find_path(OpenMP_INCLUDE_DIR
                omp.h
                )

        mark_as_advanced(OpenMP_LIBRARY OpenMP_INCLUDE_DIR)

        include(FindPackageHandleStandardArgs)
        find_package_handle_standard_args(OpenMP DEFAULT_MSG
                OpenMP_LIBRARY OpenMP_INCLUDE_DIR)

        if (OpenMP_FOUND)
            set(OpenMP_LIBRARIES ${OpenMP_LIBRARY})
            set(OpenMP_INCLUDE_DIRS ${OpenMP_INCLUDE_DIR})
            set(OpenMP_COMPILE_OPTIONS -Xpreprocessor -fopenmp)

            add_library(OpenMP::OpenMP SHARED IMPORTED)
            set_target_properties(OpenMP::OpenMP PROPERTIES
                    IMPORTED_LOCATION ${OpenMP_LIBRARIES}
                    INTERFACE_INCLUDE_DIRECTORIES "${OpenMP_INCLUDE_DIRS}"
                    INTERFACE_COMPILE_OPTIONS "${OpenMP_COMPILE_OPTIONS}"
                    )
            target_link_libraries(antara_optimize_settings INTERFACE OpenMP::OpenMP)
        endif ()
    endif ()
endif ()

## Cross filesystem
add_library(antara_cross_filesystem INTERFACE)
add_library(antara::cross_filesystem ALIAS antara_cross_filesystem)

target_link_libraries(antara_cross_filesystem INTERFACE
        $<$<AND:$<PLATFORM_ID:Linux>,$<VERSION_LESS:$<CXX_COMPILER_VERSION>,9.0>>:stdc++fs>
        #$<$<AND:$<PLATFORM_ID:Darwin>,$<VERSION_LESS:$<CXX_COMPILER_VERSION>,9.0>>:c++fs>
        )
target_compile_options(antara_cross_filesystem INTERFACE
        $<$<AND:$<PLATFORM_ID:Darwin>,$<VERSION_GREATER:$<CXX_COMPILER_VERSION>,8.0>>:-mmacosx-version-min=10.14>)

add_library(antara_default_settings INTERFACE)
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
target_link_libraries(antara_default_settings INTERFACE antara::error_settings antara::optimize_settings antara::defaults_features antara::cross_filesystem Threads::Threads)
add_library(antara::default_settings ALIAS antara_default_settings)
