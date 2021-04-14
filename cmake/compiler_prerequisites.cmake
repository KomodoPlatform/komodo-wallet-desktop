find_program(ANTARA_CXX_COMPILER clang++)
find_program(ANTARA_C_COMPILER clang)
set(CMAKE_CXX_COMPILER "${ANTARA_CXX_COMPILER}" CACHE STRING "")
set(CMAKE_C_COMPILER "${ANTARA_C_COMPILER}" CACHE STRING "")

if (WIN32)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif ()

if (PREFER_BOOST_FILESYSTEM)
    message(STATUS "Boost filesystem over std::filesystem")
    add_compile_definitions(PREFER_BOOST_FILESYSTEM)
endif ()