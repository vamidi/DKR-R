cmake_minimum_required(VERSION 3.24)
project(DKRSwitch LANGUAGES C CXX)

if(NOT DKR_SWITCH)
    message(FATAL_ERROR
        "The switch/ project must be configured with switch/cmake/SwitchToolchain.cmake "
        "(use the switch or switch-scaffold presets in this directory).")
endif()

# Toolchain verification artifact: proves the devkitA64 -> switch.specs ->
# elf2nro pipeline end to end before any game code is cross-compiled.
option(DKR_SWITCH_HELLO "Build the toolchain-verification hello .nro" ON)
if(DKR_SWITCH_HELLO)
    add_executable(DKRSwitchHello src/hello.c)
    nx_create_nro(DKRSwitchHello
        OUTPUT "${CMAKE_BINARY_DIR}/dkr-switch-hello.nro"
        NONACP)
endif()

# The runtime project owns every compile/link decision for the game; this
# wrapper configures it under the devkitA64 toolchain and packages the
# resulting executable into an installable .nro.
add_subdirectory("${CMAKE_CURRENT_LIST_DIR}/../runtime-recomp"
                 "${CMAKE_BINARY_DIR}/runtime-recomp")

if(TARGET DKRPortGame)
    # NACP display fields come from nro/app.nacp.template; the release
    # version is the cache value the runtime project read from VERSION.
    configure_file("${CMAKE_CURRENT_LIST_DIR}/nro/app.nacp.template"
                   "${CMAKE_BINARY_DIR}/nro/app.nacp.txt" @ONLY)
    add_custom_command(
        OUTPUT "${CMAKE_BINARY_DIR}/nro/app.nacp"
        COMMAND "${CMAKE_COMMAND}"
            "-DNACP_TEXT=${CMAKE_BINARY_DIR}/nro/app.nacp.txt"
            "-DNACP_TOOL=${NX_NACPTOOL_EXE}"
            "-DNACP_OUTPUT=${CMAKE_BINARY_DIR}/nro/app.nacp"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/make-nacp.cmake"
        DEPENDS "${CMAKE_BINARY_DIR}/nro/app.nacp.txt"
        COMMENT "Building NACP from app.nacp.template"
        VERBATIM)
    nx_create_nro(DKRPortGame
        OUTPUT "${CMAKE_BINARY_DIR}/DKR-R.nro"
        NACP "${CMAKE_BINARY_DIR}/nro/app.nacp")

    # Push the built .nro to a console running an FTP server
    # (sys-ftpd convention: port 5000, anonymous, SD card root).
    set(DKR_SWITCH_CONSOLE_IP "" CACHE STRING
        "Console IPv4 address for the dkr-switch-deploy target")
    add_custom_target(dkr-switch-deploy
        COMMAND "${CMAKE_COMMAND}"
            "-DNRO=$<TARGET_FILE:DKRPortGame_nro>"
            "-DCONSOLE_IP=${DKR_SWITCH_CONSOLE_IP}"
            -P "${CMAKE_CURRENT_LIST_DIR}/cmake/deploy-nro.cmake"
        DEPENDS DKRPortGame_nro
        USES_TERMINAL)
endif()
