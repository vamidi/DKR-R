# devkitA64/libnx toolchain for the DKR-R Nintendo Switch port.
#
# Built on devkitPro's own CMake support (the switch-cmake package's
# Switch.cmake + Platform/NintendoSwitch.cmake), with DKR-specific fixes:
#   - C++ exceptions and RTTI stay ENABLED. Stock Switch homebrew CMake
#     templates pass -fno-exceptions -fno-rtti; DKR-R throws and catches
#     Error types and uses std::filesystem and RTTI-owning runtime classes.
#     devkitPro's toolchain does not disable them, and SwitchPlatform.cmake
#     asserts both at configure time rather than trusting that.
#   - DKR_SWITCH cache marker consumed by runtime-recomp/CMakeLists.txt.
#   - devkitPro's aarch64 pkg-config is a bash wrapper on Windows, so the
#     FindSDL2/FindNXVK modules read portlibs directly instead of executing
#     pkg-config. PKG_CONFIG_EXECUTABLE is still recorded for generators
#     that can run it.
cmake_minimum_required(VERSION 3.24)

if(NOT DEFINED ENV{DEVKITPRO})
    message(FATAL_ERROR
        "The DEVKITPRO environment variable must point at the devkitPro "
        "install prefix (for example C:/devkitPro).")
endif()
file(TO_CMAKE_PATH "$ENV{DEVKITPRO}" DEVKITPRO)
# devkitPro's own CMake helpers concatenate this prefix into strings, so it
# must use forward slashes (TO_CMAKE_PATH yields backslashes on Windows).
# dkp-initialize-path re-reads the environment variable, so normalize that
# too; switch.specs and the tool custom commands consume it through getenv.
string(REPLACE "\\" "/" DEVKITPRO "${DEVKITPRO}")
set(ENV{DEVKITPRO} "${DEVKITPRO}")
set(DEVKITA64 "${DEVKITPRO}/devkitA64")
set(NX_ROOT "${DEVKITPRO}/libnx")
set(DKR_SWITCH_PORTLIBS "${DEVKITPRO}/portlibs/switch")
# Cache-exported so FindSDL2/FindNXVK in subdirectory scopes can resolve the
# portlibs layout (toolchain normal variables do not propagate there).
set(DKR_SWITCH_PORTLIBS "${DKR_SWITCH_PORTLIBS}" CACHE INTERNAL
    "devkitPro Switch portlibs prefix")

foreach(required IN ITEMS
        "${NX_ROOT}/switch.specs" "${NX_ROOT}/lib/libnx.a"
        "${DEVKITA64}/bin" "${DKR_SWITCH_PORTLIBS}/lib")
    if(NOT EXISTS "${required}")
        message(FATAL_ERROR
            "devkitPro is missing ${required}. Update the Switch SDK with: "
            "dkp-pacman -Syu --needed switch-dev switch-tools")
    endif()
endforeach()

# devkitPro's official platform modules (Platform/NintendoSwitch.cmake).
list(APPEND CMAKE_MODULE_PATH "${DEVKITPRO}/cmake")

set(CMAKE_SYSTEM_NAME NintendoSwitch)
set(CMAKE_SYSTEM_VERSION 1)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# The host build tool must be resolved before devkitPro's toolchain turns
# off system-environment-path search for the target side.
find_program(DKR_HOST_NINJA NAMES ninja ninja-build HINTS ENV PATH)
if(DKR_HOST_NINJA)
    set(CMAKE_MAKE_PROGRAM "${DKR_HOST_NINJA}" CACHE FILEPATH "Host ninja build tool" FORCE)
endif()
# Host-side tools the project pipeline still needs while cross-compiling:
# Git for the staged-patch pipeline, Python for the prepare/generate steps.
find_program(DKR_HOST_GIT NAMES git HINTS ENV PATH)
if(DKR_HOST_GIT)
    set(GIT_EXECUTABLE "${DKR_HOST_GIT}" CACHE FILEPATH "Host Git for staged patching" FORCE)
endif()
find_program(DKR_HOST_PYTHON NAMES python python3 HINTS ENV PATH)
if(DKR_HOST_PYTHON)
    set(Python3_EXECUTABLE "${DKR_HOST_PYTHON}" CACHE FILEPATH "Host Python 3" FORCE)
endif()

# The official Switch.cmake toolchain resolves the compilers, the find-root
# prefixes (portlibs + libnx + devkitA64 + tools), pkg-config, and the
# elf2nro/nacptool family.
include("${DEVKITPRO}/cmake/Switch.cmake")

# DKR-R consumes this marker throughout runtime-recomp/CMakeLists.txt.
set(DKR_SWITCH ON CACHE BOOL "Building the DKR-R Nintendo Switch target" FORCE)

# switch.specs resolves the link script through this environment variable;
# record the resolved prefix so custom commands can re-export it.
set(ENV{DEVKITPRO} "${DEVKITPRO}")
set(DKR_SWITCH_DEVKITPRO_ENV "${DEVKITPRO}" CACHE INTERNAL
    "DEVKITPRO prefix exported for switch.specs and elf2nro custom commands")

find_program(DKR_SWITCH_PKG_CONFIG NAMES aarch64-none-elf-pkg-config
    HINTS "${DKR_SWITCH_PORTLIBS}/bin")
if(DKR_SWITCH_PKG_CONFIG)
    set(PKG_CONFIG_EXECUTABLE "${DKR_SWITCH_PKG_CONFIG}" CACHE FILEPATH
        "devkitPro target pkg-config")
endif()

# The .nro needs the console's applet heap sizing; keep the default applet
# type Application (set in src/switch/switch_main.cpp).
set(DKR_SWITCH_NRO_TITLE "Diddy Kong Racing R" CACHE STRING
    "NACP application display name")
set(DKR_SWITCH_NRO_AUTHOR "DKR-R contributors" CACHE STRING
    "NACP application author")
