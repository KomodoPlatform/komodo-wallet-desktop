function(dex_generate_qrc directory output)
    cmake_parse_arguments(
        GENERATE_QRC
        ""
        "PATH_PREFIX"
        "FILES_TO_EXCLUDE;FILES"
        ${ARGN}
    )

    set(resources)
    file(GLOB_RECURSE resources ${directory}/* ${directory}/*/*)

    file(WRITE ${directory}/qml.qrc "<RCC>\n")
    file(APPEND ${directory}/qml.qrc "    <qresource prefix=\"/${GENERATE_QRC_PATH_PREFIX}\">\n")
    foreach(res ${resources})
        set(excluded FALSE)
        foreach(file_to_exclude ${GENERATE_QRC_FILES_TO_EXCLUDE})
            set(find_res)
            string(FIND ${res} ${file_to_exclude} find_res)
            if (${find_res} GREATER -1)
                set(excluded TRUE)
                break()
            endif ()
        endforeach()
        if (excluded)
            continue()
        endif ()
        string(REPLACE ${directory}/ "" res ${res})
        file(APPEND ${directory}/qml.qrc "        <file>${res}</file>\n")
    endforeach()
    foreach(res ${GENERATE_QRC_FILES})
        string(REPLACE ${directory}/ "" res ${res})
        file(APPEND ${directory}/qml.qrc "        <file>${res}</file>\n")
    endforeach()
    file(APPEND ${directory}/qml.qrc "    </qresource>\n")
    file(APPEND ${directory}/qml.qrc "</RCC>\n")

    set(${output} ${directory}/qml.qrc PARENT_SCOPE)

endfunction()