# linux-tkg-ci

Automated CI pipeline for building linux-tkg kernels with performance patches.

## Overview

Uses GitHub Actions to automatically build patched kernels when new versions are available, then pushes to distribution repos via raw GitHub content hosting.

## Features

- Monitors upstream kernel releases (latest stable)
- Applies linux-tkg (Frogging-Family) patches
- Automated builds via GitHub Actions
- Distributes via raw.githubusercontent.com

## Build Matrix

| Distros | Schedulers | Configs | Architectures |
|---------|------------|---------|---------------|
| Arch, Debian, Fedora | pds, bmq, bore, eevdf | default, all-patches | x86_64, aarch64 |

**48 package variants per kernel release**

## Installation

### Arch Linux

```bash
# Add to /etc/pacman.conf
[linux-tkg]
SigLevel = Optional TrustAll
Server = https://raw.githubusercontent.com/<user>/linux-tkg-ci/repo/arch/$arch

# Install
sudo pacman -Sy linux-tkg-<scheduler>-<config>
```

### Debian/Ubuntu

```bash
# Add repository
echo "deb [trusted=yes] https://raw.githubusercontent.com/<user>/linux-tkg-ci/repo/debian stable main" | sudo tee /etc/apt/sources.list.d/linux-tkg.list

# Install
sudo apt update
sudo apt install linux-image-*-tkg-<scheduler>-<config>
```

### Fedora

```bash
# Add repository
sudo dnf config-manager --add-repo https://raw.githubusercontent.com/<user>/linux-tkg-ci/repo/fedora/\$basearch

# Install
sudo dnf install kernel-*-tkg-<scheduler>-<config>
```

## Schedulers

- **pds** - Project C PDS scheduler
- **bmq** - Project C BMQ scheduler
- **bore** - Burst-Oriented Response Enhancer
- **eevdf** - Earliest Eligible Virtual Deadline First (kernel default 6.6+)

## Configs

- **default** - TKG default settings
- **all-patches** - All optional patches enabled (ACS override, O3, tickless, etc.)

## Credits

- [Frogging-Family/linux-tkg](https://github.com/Frogging-Family/linux-tkg)
