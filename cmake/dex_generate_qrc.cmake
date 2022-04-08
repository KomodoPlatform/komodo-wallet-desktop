function(dex_generate_qrc directory output)
    cmake_parse_arguments(
        GENERATE_QRC
        ""
        "PATH_PREFIX"
        ""
        ${ARGN}
    )

    set(resources)
    file(GLOB_RECURSE resources ${directory}/* ${directory}/*/*)

    file(WRITE ${directory}/qml.qrc "<RCC>\n")
    file(APPEND ${directory}/qml.qrc "    <qresource prefix=\"/${GENERATE_QRC_PATH_PREFIX}\">\n")
    foreach(res ${resources})
        string(REPLACE ${directory}/ "" res ${res})
        file(APPEND ${directory}/qml.qrc "        <file>${res}</file>\n")
    endforeach()
    file(APPEND ${directory}/qml.qrc "    </qresource>\n")
    file(APPEND ${directory}/qml.qrc "</RCC>\n")

    set(${output} ${directory}/qml.qrc PARENT_SCOPE)

endfunction()