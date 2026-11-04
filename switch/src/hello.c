/* Toolchain verification artifact: proves the devkitA64 -> switch.specs ->
 * elf2nro pipeline end to end before any game code is cross-compiled.
 * Boots on device, prints a banner, exits on +/minus or after five seconds. */
#include <switch.h>
#include <stdio.h>

u32 __nx_applet_type = AppletType_Application;

int main(void) {
    consoleInit(nwindowGetDefault());
    printf("DKR-R Switch scaffolding OK\n");
    printf("built %s %s\n\n", __DATE__, __TIME__);
    printf("Press + or - to exit (auto-exit in 5s).\n");

    const u64 deadline = armGetSystemTick() + armGetSystemTickFreq() * 5;
    while (armGetSystemTick() < deadline) {
        padUpdate(&pad);
        if (padGetButtons(&pad, PadStateDown) & (PadButton_Plus | PadButton_Minus))
            break;
        napms(16);
    }
    return 0;
}