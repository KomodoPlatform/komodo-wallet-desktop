function(DEX_NEW_LIB name)
    cmake_parse_arguments(
        NEW_LIBRARY
        "STATIC;SHARED;INTERFACE"
        "DIRECTORY"
        "PUBLIC_DEPS;PRIVATE_DEPS;INTERFACE_DEPS;PUBLIC_DEFS;PRIVATE_DEFS;INTERFACE_DEFS"
        ${ARGN}
    )

    # Sets targets name.
    set(target_name ${PROJECT_NAME}_${name})
    set(alias_name ${PROJECT_NAME}::${name})

    # Sets sources directory.
    if (NEW_LIBRARY_DIRECTORY)
        set(directory ${NEW_LIBRARY_DIRECTORY})
    else ()
        set(directory ${name})
    endif ()

    # Gets directory's sources.
    set(sources)
    if (APPLE)
        file(GLOB_RECURSE sources
            ${directory}/*.cpp ${directory}/*/*.cpp
            ${directory}/*.hpp ${directory}/*/*.hpp
            ${directory}/*.inl ${directory}/*/*.inl
            ${directory}/*.mm ${directory}/*/*.mm)
    else ()
        file(GLOB_RECURSE sources
            ${directory}/*.cpp ${directory}/*/*.cpp
            ${directory}/*.hpp ${directory}/*/*.hpp
            ${directory}/*.inl ${directory}/*/*.inl)
    endif ()

    # Creates target.
    if (NEW_LIBRARY_STATIC)
        add_library(${target_name} STATIC ${sources})
        target_include_directories(${target_name} PUBLIC $<IF:$<BOOL:${NEW_LIBRARY_DIRECTORY}>,${DIRECTORY},${CMAKE_CURRENT_SOURCE_DIR}/${name}>)
        target_compile_definitions(${target_name} PRIVATE DEX_STATIC_LIB)
    elseif (NEW_LIBRARY_SHARED)
        add_library(${target_name} SHARED ${sources})
        target_include_directories(${target_name} PUBLIC $<IF:$<BOOL:${NEW_LIBRARY_DIRECTORY}>,${DIRECTORY},${CMAKE_CURRENT_SOURCE_DIR}/${name}>)
        target_compile_definitions(${target_name} PRIVATE DEX_SHARED_LIB)
    elseif (NEW_LIBRARY_INTERFACE)
        add_library(${target_name} INTERFACE)
        target_sources(${target_name} INTERFACE ${sources})
        target_include_directories(${target_name} INTERFACE $<IF:$<BOOL:${NEW_LIBRARY_DIRECTORY}>,${DIRECTORY},${CMAKE_CURRENT_SOURCE_DIR}/${name}>)
    else()
        message(FATAL_ERROR "You must select a library type, possible options: STATIC;SHARED;INTERFACE")
    endif()

    # Sets dependencies.
    if (NEW_LIBRARY_PUBLIC_DEPS)
        target_link_libraries(${target_name} PUBLIC ${NEW_LIBRARY_PUBLIC_DEPS})
    endif()
    if (NEW_LIBRARY_PRIVATE_DEPS)
        target_link_libraries(${target_name} PRIVATE ${NEW_LIBRARY_PRIVATE_DEPS})
    endif()
    if (NEW_LIBRARY_INTERFACE_DEPS)
        target_link_libraries(${target_name} INTERFACE ${NEW_LIBRARY_INTERFACE_DEPS})
    endif()

    # Sets definitions.
    if (NEW_LIBRARY_PUBLIC_DEFS)
        target_compile_definitions(${target_name} PUBLIC ${NEW_LIBRARY_PUBLIC_DEFS})
    endif()
    if (NEW_LIBRARY_PRIVATE_DEFS)
        target_compile_definitions(${target_name} PRIVATE ${NEW_LIBRARY_PRIVATE_DEFS})
    endif()
    if (NEW_LIBRARY_INTERFACE_DEFS)
        target_compile_definitions(${target_name} INTERFACE ${NEW_LIBRARY_INTERFACE_DEFS})
    endif ()

    # Creates alias target.
    add_library(${alias_name} ALIAS ${target_name})

    message(STATUS "New library ${alias_name} -- Files: ${sources}")
endfunction()