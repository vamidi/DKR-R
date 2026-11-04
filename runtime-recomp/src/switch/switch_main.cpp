// libnx applet sizing and process-wide environment for the DKR-R .nro.
// The game entry point stays in game_main.cpp; SDL2's SDL2main shim calls
// it as SDL_main once SDL_main.h renames main() on this platform.
extern "C" {
#include <switch.h>
}

// The game needs the full application applet heap; M3 tunes the explicit
// ceilings, so let libnx size the managed heap from what the applet pool
// leaves behind.
u32 __nx_applet_type = AppletType_Application;

extern "C" __attribute__((constructor)) void dkr_switch_environment(void) {
    // NVK refuses to create a device until the application acknowledges the
    // driver's maturity (nxvk README). Set before any Vulkan code runs.
    setenv("NVK_I_WANT_A_BROKEN_VULKAN_DRIVER", "1", 1);
}