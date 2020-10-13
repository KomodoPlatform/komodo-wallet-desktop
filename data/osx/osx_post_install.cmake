message(STATUS "Hello post install ${CMAKE_SOURCE_DIR}")
get_filename_component(PROJECT_ROOT_DIR ${CMAKE_SOURCE_DIR} DIRECTORY)

message(STATUS "PROJECT_ROOT_DIR -> ${PROJECT_ROOT_DIR}")
set(PROJECT_QML_DIR ${PROJECT_ROOT_DIR}/atomic_defi_design/qml)
message(STATUS "PROJECT_QML_DIR -> ${PROJECT_QML_DIR}")
set(PROJECT_APP_PATH ${PROJECT_ROOT_DIR}/bundled/osx/atomicdex-desktop.app)
if (EXISTS ${PROJECT_APP_PATH})
    message(STATUS "PROJECT_APP_PATH path is -> ${PROJECT_APP_PATH}")
else ()
    message(FATAL_ERROR "Didn't find PROJECT_APP_PATH")
endif ()

if (EXISTS ${CMAKE_SOURCE_DIR}/conan_paths.cmake)
    set(CONAN_ENABLED ON)
    message(STATUS "Conan package manager enabled")
    include(${CMAKE_SOURCE_DIR}/conan_paths.cmake)
else ()
    message(STATUS "VCPKG package manager enabled")
endif ()

set(MAC_DEPLOY_PATH "")
if (CONAN_ENABLED)
    message(STATUS "Using QT tools from ${CONAN_QT_ROOT}/bin")
    set(MAC_DEPLOY_PATH ${CONAN_QT_ROOT}/bin/macdeployqt)
else ()
    message(STATUS "Using QT tools from $HOME/QT")
    set(MAC_DEPLOY_PATH $ENV{QT_ROOT}/clang_64/bin/macdeployqt)
endif ()

if (EXISTS ${MAC_DEPLOY_PATH})
    message(STATUS "macdeployqt path is -> ${MAC_DEPLOY_PATH}")
else ()
    message(FATAL_ERROR "Didn't find macdeployqt")
endif ()

message(STATUS "Executing macdeployqt to fix dependencies")
execute_process(COMMAND ${MAC_DEPLOY_PATH} ${PROJECT_APP_PATH} -qmldir=${PROJECT_QML_DIR}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE MACDEPLOYQT_RESULT
        OUTPUT_VARIABLE MACDEPLOYQT_OUTPUT
        ERROR_VARIABLE MACDEPLOYQT_ERROR)
message(STATUS "Result -> ${MACDEPLOYQT_RESULT}")
message(STATUS "Output -> ${MACDEPLOYQT_OUTPUT}")
message(STATUS "Error -> ${MACDEPLOYQT_ERROR}")

message(STATUS "Pacaking the DMG")
set(PACKAGER_PATH ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/dmg-packager/package.sh)
if (EXISTS ${PACKAGER_PATH})
    message(STATUS "packager path is -> ${PACKAGER_PATH}")
else ()
    message(FATAL_ERROR "Didn't find PACKAGER_PATH")
endif ()

execute_process(COMMAND ${PACKAGER_PATH} atomicdex-desktop atomicdex-desktop ${PROJECT_ROOT_DIR}/bundled/osx/
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        RESULT_VARIABLE PACKAGER_PATH_RESULT
        OUTPUT_VARIABLE PACKAGER_PATH_OUTPUT
        ERROR_VARIABLE PACKAGER_PATH_ERROR)

message(STATUS "Result -> ${PACKAGER_PATH_RESULT}")
message(STATUS "Output -> ${PACKAGER_PATH_OUTPUT}")
message(STATUS "Error -> ${PACKAGER_PATH_ERROR}")