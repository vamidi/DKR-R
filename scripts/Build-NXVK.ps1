# Builds the pinned nxvk checkout (extern/nxvk) inside its own devkitA64
# container image and installs the resulting portlib into $env:DEVKITPRO\portlibs\switch.
# Requires Docker (or any DOCKER_HOST-compatible engine). The cross-build output
# lives in the nxvk-cross named volume so Windows bind-mount I/O does not stall
# the Mesa compile.
#
# Usage: scripts/Build-NXVK.ps1 [-SkipImage]
param(
    [switch]$SkipImage
)
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$nxvk = Join-Path $root "extern\nxvk"
if (-not (Test-Path (Join-Path $nxvk "switch\docker\Dockerfile"))) {
    throw "extern/nxvk is not prepared. Run scripts/bootstrap_dependencies.py --only nxvk first."
}
if (-not $env:DEVKITPRO) { throw "DEVKITPRO is not set." }
$portlibs = Join-Path $env:DEVKITPRO "portlibs\switch"

if (-not $SkipImage) {
    docker build -t nxvk (Join-Path $nxvk "switch\docker")
    if ($LASTEXITCODE) { throw "docker build failed" }
}
# The cross ninja tree lives in a named volume (Windows bind-mount I/O is far
# too slow for the Mesa compile). The volume must not shadow switch/build,
# which holds the build scripts themselves, so it mounts only at cross/.
docker volume create nxvk-cross 2>$null | Out-Null
$crossArgs = @("nxvk-cross:/work/switch/build/cross")

function Run-Stage([string]$script) {
    docker run --rm -v "${nxvk}:/work" $crossArgs `
        -w /work nxvk bash -c "bash $script"
    if ($LASTEXITCODE) { throw "nxvk stage failed: $script" }
}

Run-Stage "switch/build/build-native-tools.sh"
Run-Stage "switch/rust/build-std-sysroot.sh"
Run-Stage "switch/build/configure-mesa.sh"

# Driver + support archives (the final libvulkan_nouveau.so link is expected
# to fail upstream; the .a archives are what the portlib ships).
$targets = @(
    "src/nouveau/vulkan/libnvk.a",
    "src/util/libmesa_util.a", "src/util/libmesa_util_simd.a",
    "src/util/blake3/libblake3.a", "src/c11/impl/libmesa_util_c11.a",
    "src/nouveau/compiler/libnak.a", "src/nouveau/compiler/libnak_rs.a",
    "src/compiler/rust/libcompiler_c_helpers.a",
    "src/nouveau/headers/libnvidia_headers_c.a",
    "src/nouveau/nil/libnil.a", "src/nouveau/nil/liblibnil_format_table.a",
    "src/compiler/nir/libnir.a", "src/compiler/libcompiler.a",
    "src/nouveau/mme/libnouveau_mme.a", "src/nouveau/winsys/libnouveau_ws.a",
    "src/vulkan/util/libvulkan_util.a", "src/compiler/spirv/libvtn.a",
    "src/util/libxmlconfig.a"
)
docker run --rm -v "${nxvk}:/work" $crossArgs -w /work nxvk `
    bash -c "cp -r switch/docker/cross-include/. /opt/switch-cross-include/ 2>/dev/null || true; export PATH=/work/switch/build/native-tools/bin:`$PATH; ninja -C /work/switch/build/cross $($targets -join ' ')"
if ($LASTEXITCODE) { throw "nxvk ninja build failed" }

# Bundle into libnvk.a / libnvk_support.a with the image's devkitA64 ar.
docker run --rm -v "${nxvk}:/work" $crossArgs -w /work nxvk `
    bash -c @'
set -euo pipefail
AR=/opt/devkitpro/devkitA64/bin/aarch64-none-elf-ar
CROSS=/work/switch/build/cross
PKG=/work/switch/build/pkg
mkdir -p $PKG/lib/pkgconfig
bundle() {
    local out=$1 dir=$2; shift 2
    printf 'create %s\n' "$out" > "$out.mri"
    for a in "$@"; do printf 'addlib %s/%s\n' "$dir" "$a" >> "$out.mri"; done
    printf 'save\nend\n' >> "$out.mri"
    $AR -M < "$out.mri"
    rm -f "$out.mri"
}
bundle $PKG/lib/libnvk.a $CROSS src/nouveau/vulkan/libnvk.a
bundle $PKG/lib/libnvk_support.a $CROSS src/util/libmesa_util.a src/util/libmesa_util_simd.a src/util/blake3/libblake3.a src/c11/impl/libmesa_util_c11.a src/nouveau/compiler/libnak.a src/nouveau/compiler/libnak_rs.a src/compiler/rust/libcompiler_c_helpers.a src/nouveau/headers/libnvidia_headers_c.a src/nouveau/nil/libnil.a src/nouveau/nil/liblibnil_format_table.a src/compiler/nir/libnir.a src/compiler/libcompiler.a src/nouveau/mme/libnouveau_mme.a src/nouveau/winsys/libnouveau_ws.a src/vulkan/util/libvulkan_util.a src/compiler/spirv/libvtn.a src/util/libxmlconfig.a
version=$(cat /work/VERSION 2>/dev/null || echo 0.0.0)
printf 'prefix=/devkitpro-portlibs\nexec_prefix=${prefix}\nlibdir=${prefix}/lib\nincludedir=${prefix}/include\n\nName: nxvk\nDescription: NVK ported to the Nintendo Switch\nVersion: %s\nLibs: -L${libdir} -Wl,--whole-archive -lnvk -Wl,--no-whole-archive -Wl,--start-group -lnvk_support -lz -lexpat -Wl,--end-group -Wl,-u,vk_icdGetInstanceProcAddr -Wl,--gc-sections\nCflags: -I${includedir} -D__SWITCH__ -DVK_USE_PLATFORM_VI_NN -ffunction-sections -fdata-sections\n' "$version" > $PKG/lib/pkgconfig/nxvk.pc
echo staged
'@
if ($LASTEXITCODE) { throw "nxvk packaging failed" }

# The staged package lands on the bind mount (switch/build/pkg is not inside
# the cross volume), so install it straight from the checkout into the other
# devkitPro portlibs, rewriting the .pc prefix to the Windows portlibs path.
$stage = Join-Path $nxvk "switch\build\pkg"
if (-not (Test-Path (Join-Path $stage "lib\libnvk.a"))) { throw "libnvk.a missing from staged package" }
New-Item -ItemType Directory -Force -Path (Join-Path $portlibs "lib\pkgconfig"), (Join-Path $portlibs "include"), (Join-Path $portlibs "licenses\nxvk") | Out-Null
Copy-Item -Force (Join-Path $stage "lib\*.a") (Join-Path $portlibs "lib")
Copy-Item -Force (Join-Path $stage "lib\pkgconfig\nxvk.pc") (Join-Path $portlibs "lib\pkgconfig")
foreach ($dir in "vulkan", "vk_video") {
    $src = Join-Path $nxvk "include\$dir"
    if (Test-Path $src) { Copy-Item -Recurse -Force $src (Join-Path $portlibs "include") }
}
Copy-Item -Force (Join-Path $nxvk "licenses\GPL-2.0-or-later") (Join-Path $portlibs "licenses\nxvk") -ErrorAction SilentlyContinue
$pc = Join-Path $portlibs "lib\pkgconfig\nxvk.pc"
((Get-Content $pc) -replace "^prefix=.*", "prefix=$($portlibs -replace '\\','/')") | Set-Content $pc
Write-Host "nxvk installed into $portlibs"
