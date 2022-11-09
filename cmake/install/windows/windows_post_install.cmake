include(${CMAKE_CURRENT_LIST_DIR}/../../project.metadata.cmake)

message(STATUS "PROJECT_ROOT_DIR (before readjusting) -> ${PROJECT_ROOT_DIR}")

get_filename_component(PROJECT_ROOT_DIR ${CMAKE_SOURCE_DIR} DIRECTORY)
if (EXISTS ${PROJECT_ROOT_DIR}/build-Release OR EXISTS ${PROJECT_ROOT_DIR}/build-Debug)
    message(STATUS "from ci tools, readjusting")
    get_filename_component(PROJECT_ROOT_DIR ${PROJECT_ROOT_DIR} DIRECTORY)
endif ()

set(PROJECT_APP_DIR bin)
set(PROJECT_APP_PATH ${CMAKE_SOURCE_DIR}/${PROJECT_APP_DIR})
set(TARGET_APP_PATH ${PROJECT_ROOT_DIR}/bundled/windows)

message(STATUS "VCPKG package manager enabled")
message(STATUS "PROJECT_ROOT_DIR (after readjusting) -> ${PROJECT_ROOT_DIR}")
message(STATUS "PROJECT_QML_DIR -> ${PROJECT_QML_DIR}")

if (EXISTS ${PROJECT_APP_PATH})
    message(STATUS "PROJECT_APP_PATH path is -> ${PROJECT_APP_PATH}")
    message(STATUS "TARGET_APP_PATH path is -> ${TARGET_APP_PATH}")
else ()
    message(FATAL_ERROR "Didn't find ${PROJECT_APP_PATH}")
endif ()

if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/bin.zip)
	execute_process(COMMAND powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::CreateFromDirectory('bin', 'bin.zip'); }"
			WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
			ECHO_OUTPUT_VARIABLE
			ECHO_ERROR_VARIABLE
		)
else()
	message(STATUS "bin.zip already present - skipping")
endif()

if (NOT EXISTS ${TARGET_APP_PATH}/bin.zip)
	message(STATUS "Copying ${CMAKE_SOURCE_DIR}/bin.zip to ${TARGET_APP_PATH}/${DEX_PROJECT_NAME}.zip")
	file(COPY ${CMAKE_SOURCE_DIR}/bin.zip DESTINATION ${TARGET_APP_PATH})
else()
	message(STATUS "${TARGET_APP_PATH}/${DEX_PROJECT_NAME}.zip exists - skipping")
endif()

message(STATUS "Embedding the manifest")
if (NOT EXISTS ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/data/${DEX_PROJECT_NAME}.exe.manifest)
	message(WARNING "${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/data/${DEX_PROJECT_NAME}.exe.manifest doesn't exist - aborting")
endif()
file(COPY  ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/data/${DEX_PROJECT_NAME}.exe.manifest DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/bin)
#FILE(GLOB CURDIR RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/ ${CMAKE_CURRENT_SOURCE_DIR}/bin/*)
#message(STATUS "curdir: ${CURDIR}")
#message(STATUS "Executing: [mt.exe -manifest \"${DEX_PROJECT_NAME}.exe.manifest\" -outputresource:\"${DEX_PROJECT_NAME}.exe\";\#1] from directory: ${CMAKE_CURRENT_SOURCE_DIR}/bin")
set(DEX_OUT "${CMAKE_CURRENT_SOURCE_DIR}\\bin\\${DEX_PROJECT_NAME}.exe")
set(DEX_IN "${CMAKE_CURRENT_SOURCE_DIR}\\bin\\${DEX_PROJECT_NAME}.exe.manifest")
cmake_path(CONVERT ${DEX_OUT} TO_NATIVE_PATH_LIST DEX_OUT_NATIVE)
cmake_path(CONVERT ${DEX_IN} TO_NATIVE_PATH_LIST DEX_IN_NATIVE)
#message(STATUS "mt.exe -manifest ${DEX_IN_NATIVE} -outputresource:${DEX_OUT_NATIVE}")
execute_process(COMMAND powershell.exe -File ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/ci_scripts/mt_wrapper.ps1 ${DEX_IN} ${DEX_OUT}
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin
		ECHO_ERROR_VARIABLE
		RESULT_VARIABLE MANIFEST_RESULT
		OUTPUT_VARIABLE MANIFEST_OUTPUT
		ERROR_VARIABLE MANIFEST_ERROR)
message(STATUS "manifest output: ${MANIFEST_RESULT} ${MANIFEST_OUTPUT} ${MANIFEST_ERROR}")

message(STATUS "Creating Installer")
set(IFW_BINDIR $ENV{QT_ROOT}/Tools/QtInstallerFramework/4.5/bin)
message(STATUS "IFW_BIN PATH IS ${IFW_BINDIR}")
if (NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/bin/${DEX_PROJECT_NAME}.7z)
	message(STATUS "command is: [${IFW_BINDIR}/archivegen.exe ${DEX_PROJECT_NAME}.7z .]")
	execute_process(COMMAND ${IFW_BINDIR}/archivegen.exe ${DEX_PROJECT_NAME}.7z .
		WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/bin
		ECHO_OUTPUT_VARIABLE
		ECHO_ERROR_VARIABLE
		RESULT_VARIABLE ARCHIVE_RESULT
		OUTPUT_VARIABLE ARCHIVE_OUTPUT
		ERROR_VARIABLE ARCHIVE_ERROR)
	message(STATUS "archivegen output: ${ARCHIVE_OUTPUT} ${ARCHIVE_ERROR}")
else()
	message(STATUS "${DEX_PROJECT_NAME}.7z already exists skipping")
endif()

file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/bin/${DEX_PROJECT_NAME}.7z DESTINATION ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/installer/windows/packages/com.komodoplatform.atomicdex/data)

execute_process(COMMAND ${IFW_BINDIR}/binarycreator.exe -c ./config/config.xml -p ./packages/ ${DEX_PROJECT_NAME}_installer.exe
	WORKING_DIRECTORY ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/installer/windows
	ECHO_OUTPUT_VARIABLE
	ECHO_ERROR_VARIABLE)
file(COPY ${PROJECT_ROOT_DIR}/ci_tools_atomic_dex/installer/windows/${DEX_PROJECT_NAME}_installer.exe DESTINATION ${TARGET_APP_PATH})