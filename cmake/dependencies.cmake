##! Dependancies
include(FetchContent)

find_package(doctest CONFIG REQUIRED)
find_package(EnTT CONFIG REQUIRED)
find_package(fmt CONFIG REQUIRED)

set(BUILD_TESTING OFF CACHE BOOL "Override option" FORCE)
set(REPROC++ ON CACHE BOOL "" FORCE)

FetchContent_Declare(
        doom_st
        URL https://github.com/doom/strong_type/archive/1.0.2.tar.gz
)

FetchContent_Declare(
        doom_meta
        URL https://github.com/doom/meta/archive/master.zip
)

find_package(nlohmann_json CONFIG REQUIRED)

FetchContent_Declare(
        reproc
        URL https://github.com/DaanDeMeyer/reproc/archive/v13.0.1.zip
)

set(EXPECTED_ENABLE_TESTS OFF CACHE BOOL "Override option" FORCE)

FetchContent_Declare(
        expected
        URL https://github.com/Milerius/expected/archive/patch-1.zip
)


find_package(range-v3 CONFIG REQUIRED)


FetchContent_Declare(
        refl-cpp
        URL https://github.com/KomodoPlatform/refl-cpp/archive/v0.6.5.zip
)

FetchContent_Declare(
        joboccara-pipes
        URL https://github.com/joboccara/pipes/archive/master.zip)

add_library(antara_entt INTERFACE)
target_link_libraries(antara_entt INTERFACE EnTT::EnTT)
add_library(antara::entt ALIAS antara_entt)

add_library(doctest INTERFACE)
target_link_libraries(doctest INTERFACE doctest::doctest)

FetchContent_MakeAvailable(doom_st expected refl-cpp doom_meta joboccara-pipes reproc)

add_library(refl-cpp INTERFACE)
target_include_directories(refl-cpp INTERFACE ${refl-cpp_SOURCE_DIR})
add_library(antara::refl-cpp ALIAS refl-cpp)
