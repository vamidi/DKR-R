# Script mode: turn the filled app.nacp.txt into a binary nacp with nacptool.
if(NOT DEFINED NACP_TEXT OR NOT DEFINED NACP_TOOL OR NOT DEFINED NACP_OUTPUT)
    message(FATAL_ERROR "make-nacp.cmake needs -DNACP_TEXT= -DNACP_TOOL= -DNACP_OUTPUT=")
endif()
file(READ "${NACP_TEXT}" text)
foreach(field IN ITEMS name publisher display_version)
    if(text MATCHES "(^|\n)[ \t]*${field}[ \t]*=[ \t]*([^\n\r]*)")
        string(STRIP "${CMAKE_MATCH_2}" ${field})
    else()
        set(${field} "")
    endif()
endforeach()
execute_process(COMMAND "${NACP_TOOL}" --create
    "${name}" "${publisher}" "${display_version}" "${NACP_OUTPUT}"
    COMMAND_ERROR_IS_FATAL ANY)