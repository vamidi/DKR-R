/* Toolchain verification artifact: proves the devkitA64 -> switch.specs ->
 * elf2nro pipeline end to end before any game code is cross-compiled.
 * Boots on device, prints a banner, exits on +/minus or after five seconds. */
#include <switch.h>
#include <stdio.h>

/* libnx 4.x reads this weak symbol during applet init: Application requests the
 * title-mode budget instead of the smaller Album/applet budget. */
u32 __nx_applet_type = AppletType_Application;

#define HELLO_TIMEOUT_NS (5ull * 1000ull * 1000ull * 1000ull)
#define HELLO_FRAME_NS (16ull * 1000ull * 1000ull)
#define HELLO_REPORT_NS (1000ull * 1000ull * 1000ull)

int main(void) {
    consoleInit(NULL);

    padConfigureInput(1, HidNpadStyleSet_NpadStandard);
    PadState pad;
    padInitializeDefault(&pad);

    const u32 version = hosversionGet();
    printf("DKR-R Switch scaffolding OK\n");
    printf("built %s %s\n", __DATE__, __TIME__);
    printf("firmware %u.%u.%u, applet type %d (0 = Application/title)\n",
           HOSVER_MAJOR(version), HOSVER_MINOR(version), HOSVER_MICRO(version),
           (int)appletGetAppletType());
    printf("Press + or - to exit (auto-exit in 5s).\n");
    consoleUpdate(NULL);

    const u64 freq = armGetSystemTickFreq();
    const u64 start = armGetSystemTick();
    u64 next_report = HELLO_REPORT_NS;
    u64 elapsed_ns = 0;

    while (appletMainLoop()) {
        padUpdate(&pad);
        const u64 kDown = padGetButtonsDown(&pad);
        if (kDown & (HidNpadButton_Plus | HidNpadButton_Minus)) {
            printf("exit requested by pad\n");
            break;
        }

        elapsed_ns = (armGetSystemTick() - start) * 1000000000ull / freq;
        if (elapsed_ns >= HELLO_TIMEOUT_NS) {
            printf("exit requested by timeout\n");
            break;
        }
        if (elapsed_ns >= next_report) {
            printf("alive %llus\n", (unsigned long long)(elapsed_ns / 1000000000ull));
            next_report += HELLO_REPORT_NS;
        }

        consoleUpdate(NULL);
        svcSleepThread(HELLO_FRAME_NS);
    }

    printf("banner complete after %llu ms\n",
           (unsigned long long)(elapsed_ns / 1000000ull));
    consoleUpdate(NULL);
    /* Keep the final frame on screen long enough to be read on a capture. */
    svcSleepThread(1000ull * 1000ull * 1000ull);

    consoleExit(NULL);
    return 0;
}
