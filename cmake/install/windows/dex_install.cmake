if (WIN32)
    message(STATUS "Windows")
	install(SCRIPT ${CMAKE_SOURCE_DIR}/cmake/install/windows/windows_post_install.cmake)
endif()