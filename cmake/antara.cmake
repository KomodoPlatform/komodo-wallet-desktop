if (${CMAKE_SYSTEM_NAME} STREQUAL "Linux")
    set(LINUX TRUE)
endif ()

macro(init_apple_env)
    if (APPLE)
        if (EXISTS "/usr/local/opt/llvm/lib")
            link_directories("/usr/local/opt/llvm/lib")
        endif ()
        if (EXISTS "/usr/local/opt/llvm@8/lib")
            link_directories("/usr/local/opt/llvm@8/lib")
        endif ()
        if (EXISTS "/usr/local/opt/llvm@9/lib")
            link_directories("/usr/local/opt/llvm@9/lib")
        endif ()
    endif ()
endmacro()

macro(configure_icon_osx icon_path icon_variable icon_name)
    if (APPLE)
        set(${icon_variable} ${icon_path})
        set_source_files_properties(${icon_name} PROPERTIES
                MACOSX_PACKAGE_LOCATION "Resources")
    endif ()
endmacro()

macro(init_windows_env)
    if (WIN32)
        message(STATUS "${CMAKE_CXX_COMPILER_ID} x${CMAKE_CXX_SIMULATE_ID} ${CMAKE_CXX_COMPILER}")
        get_filename_component(real_compiler ${CMAKE_CXX_COMPILER} NAME_WE)
        if (${real_compiler} STREQUAL "clang-cl")
            set(ClangCL ON)
            message(STATUS "clang cl detected")
        endif ()
    endif ()
endmacro()

init_windows_env()

include(compiler_targets)
include(dependencies)

macro(target_enable_coverage target)
    if (ENABLE_COVERAGE)
        message(STATUS "coverage enaled, configuring...")
        if (COVERAGE_CLION_TOOLS)
            message(STATUS "clion coverage tools enabled")
            set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fprofile-instr-generate -fcoverage-mapping")
            target_compile_options(${target} PUBLIC
                    $<$<AND:$<PLATFORM_ID:Linux>,$<CXX_COMPILER_ID:Clang>>:-fprofile-instr-generate -fcoverage-mapping>
                    $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:Clang>>:-fprofile-instr-generate -fcoverage-mapping>)
            target_link_options(${target} PUBLIC
                    $<$<AND:$<PLATFORM_ID:Linux>,$<CXX_COMPILER_ID:Clang>>:-fprofile-instr-generate -fcoverage-mapping>
                    $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:Clang>>:-fprofile-instr-generate -fcoverage-mapping>)
        else ()
            message(STATUS "regular coverage tools enabled")
            target_compile_options(${target} PUBLIC
                    $<$<AND:$<PLATFORM_ID:Linux>,$<CXX_COMPILER_ID:Clang>>:--coverage>
                    $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:Clang>>:--coverage>
                    $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:AppleClang>>:--coverage>)
            target_link_options(${target} PUBLIC
                    $<$<AND:$<PLATFORM_ID:Linux>,$<CXX_COMPILER_ID:Clang>>:--coverage>
                    $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:Clang>>:--coverage>
                    $<$<AND:$<PLATFORM_ID:Darwin>,$<CXX_COMPILER_ID:AppleClang>>:--coverage>)
        endif ()
    endif ()
endmacro()

macro(download_app_image)
    if (LINUX)
        ## We need appimage
        if (NOT EXISTS ${PROJECT_SOURCE_DIR}/tools/linux/linuxdeploy-x86_64.AppImage)
            file(DOWNLOAD
                    https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage
                    ${PROJECT_SOURCE_DIR}/tools/linuxdeploy-x86_64.AppImage
                    SHOW_PROGRESS
                    )
        endif ()
        if (EXISTS ${PROJECT_SOURCE_DIR}/tools/linuxdeploy-x86_64.AppImage)
            file(COPY
                    ${PROJECT_SOURCE_DIR}/tools/linuxdeploy-x86_64.AppImage DESTINATION
                    ${PROJECT_SOURCE_DIR}/tools/linux/
                    FILE_PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ)
        endif ()
        if (EXISTS ${PROJECT_SOURCE_DIR}/tools/linuxdeploy-x86_64.AppImage)
            file(REMOVE ${PROJECT_SOURCE_DIR}/tools/linuxdeploy-x86_64.AppImage)
        endif ()
    endif ()
endmacro()

macro(target_enable_asan target)
    if (USE_ASAN AND NOT EMSCRIPTEN)
        message("-- ASAN Enabled, Configuring...")
        target_compile_options(${target} PUBLIC
                $<$<AND:$<CONFIG:Debug>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fsanitize=address -fno-omit-frame-pointer>)
        target_link_options(${target} PUBLIC
                $<$<AND:$<CONFIG:Debug>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fsanitize=address -fno-omit-frame-pointer>)
    endif ()
endmacro()


macro(target_enable_tsan target)
    if (USE_TSAN AND NOT ASAN AND NOT EMSCRIPTEN)
        message("-- TSAN Enabled, Configuring...")
        target_compile_options(${target} PUBLIC
                $<$<AND:$<CONFIG:Debug>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fsanitize=thread -fno-omit-frame-pointer>)
        target_link_options(${target} PUBLIC
                $<$<AND:$<CONFIG:Debug>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fsanitize=thread -fno-omit-frame-pointer>)
    endif ()
endmacro()

macro(target_enable_ubsan target)
    if (USE_UBSAN AND NOT ASAN AND NOT EMSCRIPTEN)
        message("-- UBSAN Enabled, Configuring...")
        target_compile_options(${target} PUBLIC
                $<$<AND:$<CONFIG:Debug>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fsanitize=undefined -fno-omit-frame-pointer>)
        target_link_options(${target} PUBLIC
                $<$<AND:$<CONFIG:Debug>,$<NOT:$<CXX_COMPILER_ID:MSVC>>>:-fsanitize=undefined -fno-omit-frame-pointer>)
    endif ()
endmacro()

macro(magic_game_app_image_generation from_dir desktop_file appdata_file app_icon target appimage_dirname assets_dir)
    if (LINUX)
        get_target_property(exe_runtime_directory ${target} RUNTIME_OUTPUT_DIRECTORY)
        set(output_dir ${exe_runtime_directory}/${appimage_dirname})
        set_target_properties(${target} PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY ${output_dir}/usr/bin
                RUNTIME_OUTPUT_DIRECTORY_DEBUG ${output_dir}/usr/bin
                RUNTIME_OUTPUT_DIRECTORY_RELEASE ${output_dir}/usr/bin)
        file(COPY ${assets_dir} DESTINATION ${output_dir}/usr/share/)
        if (BUILD_WITH_APPIMAGE)
            configure_file(${from_dir}/${desktop_file} ${output_dir}/usr/share/applications/${desktop_file} COPYONLY)
            configure_file(${from_dir}/${appdata_file} ${output_dir}/usr/share/metainfo/${appdata_file} COPYONLY)
            configure_file(${from_dir}/${app_icon} ${output_dir}/usr/share/icons/hicolor/128x128/apps/${app_icon} COPYONLY)
            add_custom_command(TARGET ${target}
                    POST_BUILD COMMAND
                    bash -c
                    "ARCH=x86_64 VERSION=${PROJECT_VERSION} ${PROJECT_SOURCE_DIR}/tools/linux/linuxdeploy-x86_64.AppImage --appdir ${output_dir} --output appimage"
                    $<TARGET_FILE:${target}>
                    WORKING_DIRECTORY ${exe_runtime_directory})
        endif ()
    endif ()
endmacro()

macro(import_antara_dlls TARGET_NAME)
    if (WIN32)
        get_target_property(target_runtime_directory ${TARGET_NAME} RUNTIME_OUTPUT_DIRECTORY)
        message(STATUS "target: ${TARGET_NAME}, output_directory: ${target_runtime_directory}")
        set(ANTARA_DLLS "")
        if (ENABLE_BLOCKCHAIN_MODULES)
            message(STATUS "importing blockchain DLLs")
            ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_directory "${reproc_BINARY_DIR}/reproc/lib" "${target_runtime_directory}"
                    COMMENT "copying dlls …"
                    $<TARGET_FILE_DIR:${TARGET_NAME}>
                    )

            ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_directory "${reproc_BINARY_DIR}/reproc++/lib" "${target_runtime_directory}"
                    COMMENT "copying dlls …"
                    $<TARGET_FILE_DIR:${TARGET_NAME}>
                    )
        endif ()
        if (USE_IMGUI_ANTARA_WRAPPER)
            if (USE_SFML_ANTARA_WRAPPER)
                ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME}  POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy "${imgui-sfml_BINARY_DIR}/ImGui-SFML.dll" "${target_runtime_directory}"
                        COMMENT "copying dlls …"
                        $<TARGET_FILE_DIR:${TARGET_NAME}>
                        )
            endif ()
        endif ()

        if (USE_SFML_ANTARA_WRAPPER)
            ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_directory "${SFML_BINARY_DIR}/lib" "${target_runtime_directory}"
                    COMMENT "copying dlls …"
                    $<TARGET_FILE_DIR:${TARGET_NAME}>
                    )
            ADD_CUSTOM_COMMAND(TARGET ${TARGET_NAME} POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E copy_directory "${SFML_SOURCE_DIR}/extlibs/bin/x64" "${target_runtime_directory}"
                    COMMENT "copying dlls …"
                    $<TARGET_FILE_DIR:${TARGET_NAME}>
                   )
        endif ()

    endif ()
endmacro()


macro(get_nspv_assets output_dir)
    IF (UNIX)
        configure_file(${nspv_SOURCE_DIR}/nspv ${output_dir}/assets/tools/nspv COPYONLY)
        configure_file(${nspv_SOURCE_DIR}/coins ${output_dir}/assets/tools/coins COPYONLY)
    endif ()
    IF (WIN32)
        configure_file(${nspv_SOURCE_DIR}/nspv.exe ${output_dir}/assets/tools/nspv.exe COPYONLY)
        configure_file(${nspv_SOURCE_DIR}/libwinpthread-1.dll ${output_dir}/assets/tools/libwinpthread-1.dll COPYONLY)
        configure_file(${nspv_SOURCE_DIR}/coins ${output_dir}/assets/tools/coins COPYONLY)
    endif ()
endmacro()

macro(init_antara_env)
    init_apple_env()
    download_app_image()
endmacro()
