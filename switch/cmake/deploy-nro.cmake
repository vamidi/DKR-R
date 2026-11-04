# Script mode: push a built .nro to a console running an FTP server
# (sys-ftpd convention: port 5000, anonymous login, SD card root).
if(NOT DEFINED NRO OR NOT EXISTS "${NRO}")
    message(FATAL_ERROR "deploy-nro.cmake: built .nro not found (${NRO}); build first")
endif()
if(NOT DEFINED CONSOLE_IP OR CONSOLE_IP STREQUAL "")
    message(FATAL_ERROR
        "dkr-switch-deploy needs the console address: "
        "cmake -DDKR_SWITCH_CONSOLE_IP=<ip> in the build directory first")
endif()
find_program(DKR_CURL_EXE NAMES curl)
if(NOT DKR_CURL_EXE)
    message(FATAL_ERROR "dkr-switch-deploy needs curl on the host PATH")
endif()
get_filename_component(nro_name "${NRO}" NAME)
execute_process(COMMAND "${DKR_CURL_EXE}" --fail --upload-file "${NRO}"
    "ftp://${CONSOLE_IP}:5000/switch/${nro_name}"
    COMMAND_ERROR_IS_FATAL ANY)
message(STATUS "pushed ${nro_name} to ${CONSOLE_IP}:/switch/")