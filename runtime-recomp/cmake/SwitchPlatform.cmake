# Switch-only adapters at the project boundary; never patch pinned dependencies here.
if(NOT DKR_SWITCH)
    return()
endif()

# Exceptions and RTTI must actually work: DKR-R throws and catches Error
# types, and the runtime relies on RTTI. Stock Switch homebrew CMake
# templates pass -fno-exceptions -fno-rtti, so assert the flags compile
# rather than trusting the toolchain file.
include(CheckCXXSourceCompiles)
set(CMAKE_REQUIRED_QUIET TRUE)
check_cxx_source_compiles("
struct Boom { };
int main(void) {
    try { throw Boom(); } catch (const Boom &) { return 0; }
    return 1;
}" DKR_SWITCH_HAS_EXCEPTIONS)
check_cxx_source_compiles("
#include <typeinfo>
struct Poly { virtual ~Poly() { } };
int main(void) {
    Poly value;
    return typeid(value).name() != nullptr ? 0 : 1;
}" DKR_SWITCH_HAS_RTTI)
unset(CMAKE_REQUIRED_QUIET)
if(NOT DKR_SWITCH_HAS_EXCEPTIONS)
    message(FATAL_ERROR
        "The Switch toolchain must compile C++ exceptions (do not pass -fno-exceptions).")
endif()
if(NOT DKR_SWITCH_HAS_RTTI)
    message(FATAL_ERROR
        "The Switch toolchain must preserve C++ RTTI (do not pass -fno-rtti).")
endif()

# Phase 1 gates: no isolated SDL3 input process (in-process SDL2 instead),
# no libdatachannel Quick Join transport, and no integrated rollback. The
# qualification executables are host-side tools and never ship in the .nro.
set(DKR_RUNTIME_BUILD_SDL3_INPUT_HOST OFF CACHE BOOL "Switch uses in-process SDL2 input" FORCE)
set(DKR_NETPLAY_WEBRTC OFF CACHE BOOL "No libdatachannel port for Switch in phase 1" FORCE)
set(DKR_EXPERIMENTAL_RACE_TEST OFF CACHE BOOL "Owned rollback backend stays out of the Switch phase 1 build" FORCE)
set(DKR_LEGACY_QUALIFICATION OFF CACHE BOOL "Qualification executables are host-only" FORCE)
set(DKR_REPLAY_QUALIFICATION OFF CACHE BOOL "Qualification executables are host-only" FORCE)
set(DKR_EXPERIMENTAL_RENDER_QUALIFICATION OFF CACHE BOOL "Qualification executables are host-only" FORCE)
set(DKR_ANDROID_RENDER_QUALIFICATION OFF CACHE BOOL "Android render qualification is host-side" FORCE)

# Switch find modules (SDL2, nxvk) and the host-side shader compiler
# selection, mirroring cmake/android/ for the Android port.
list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/switch")
set(CMAKE_PROJECT_plume_INCLUDE "${CMAKE_CURRENT_LIST_DIR}/switch/HostShaders.cmake")
