#!/bin/bash
set -ex

VERSION="${KERNEL_VERSION:?}"
SCHEDULER="${SCHEDULER:?}"
CONFIG="${CONFIG:?}"
ARCH="${BUILD_ARCH:?}"
WORKDIR="/workspace"

echo "=== Building Arch: $VERSION / $SCHEDULER / $CONFIG / $ARCH ==="

cd "$WORKDIR"
git clone --depth 1 https://github.com/Frogging-Family/linux-tkg.git linux-tkg-build
cd linux-tkg-build

# Create config
cat "${WORKDIR}/configs/${CONFIG}.cfg" > customization.cfg
cat >> customization.cfg <<EOF

# === CI Overrides ===
_distro="Arch"
_version="${VERSION}"
_cpusched="${SCHEDULER}"
_kernel_localversion="${SCHEDULER}-${CONFIG}"
_NUKR="true"
EOF

# Cross-compilation setup
if [ "$ARCH" = "aarch64" ]; then
    export CROSS_COMPILE=aarch64-linux-gnu-
    export ARCH=arm64
    # Modify PKGBUILD for cross-compile
    sed -i 's/make /make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- /g' PKGBUILD
fi

makepkg -sf --noconfirm --skippgpcheck 2>&1 | tail -100 || true

mkdir -p "${WORKDIR}/output"
find . -maxdepth 1 -name "*.pkg.tar.zst" -exec mv {} "${WORKDIR}/output/" \;

echo "=== Output ==="
ls -lah "${WORKDIR}/output/" || echo "No packages built"
