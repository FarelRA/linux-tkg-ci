#!/bin/bash
set -ex

VERSION="${KERNEL_VERSION:?}"
SCHEDULER="${SCHEDULER:?}"
CONFIG="${CONFIG:?}"
ARCH="${BUILD_ARCH:?}"
WORKDIR="/workspace"

echo "=== Building Fedora: $VERSION / $SCHEDULER / $CONFIG / $ARCH ==="

cd "$WORKDIR"
git clone --depth 1 https://github.com/Frogging-Family/linux-tkg.git linux-tkg-build
cd linux-tkg-build

# Create config
cat "${WORKDIR}/configs/${CONFIG}.cfg" > customization.cfg
cat >> customization.cfg <<EOF

# === CI Overrides ===
_distro="Fedora"
_version="${VERSION}"
_cpusched="${SCHEDULER}"
_kernel_localversion="${SCHEDULER}-${CONFIG}"
_install_after_building="no"
_logging_use_script="no"
EOF

# Cross-compilation setup
if [ "$ARCH" = "aarch64" ]; then
    export CROSS_COMPILE=aarch64-linux-gnu-
    export ARCH=arm64
fi

./install.sh install 2>&1 | tail -200 || true

mkdir -p "${WORKDIR}/output"
find . -name "*.rpm" -path "*/RPMS/*" -exec mv {} "${WORKDIR}/output/" \;

echo "=== Output ==="
ls -lah "${WORKDIR}/output/" || echo "No packages built"
