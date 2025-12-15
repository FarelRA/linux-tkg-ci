#!/bin/bash
set -e

VERSION="${1:-unknown}"
STAGING="repo-staging"

echo "=== Creating repo for kernel $VERSION ==="

# Create structure
mkdir -p "$STAGING"/arch/{x86_64,aarch64}
mkdir -p "$STAGING"/debian/dists/stable/main/{binary-amd64,binary-arm64}
mkdir -p "$STAGING"/debian/pool/main
mkdir -p "$STAGING"/fedora/{x86_64,aarch64}

# === ARCH ===
echo "=== Processing Arch packages ==="
for arch in x86_64 aarch64; do
    dest="$STAGING/arch/$arch"
    count=0
    
    shopt -s nullglob
    for pkg in packages/arch-${arch}-*/*.pkg.tar.zst; do
        cp -v "$pkg" "$dest/"
        ((count++)) || true
    done
    shopt -u nullglob
    
    echo "Copied $count packages for arch/$arch"
    
    # Generate simple repo database
    if [ $count -gt 0 ]; then
        (
            cd "$dest"
            for pkg in *.pkg.tar.zst; do
                name=$(echo "$pkg" | sed 's/-[0-9].*//')
                mkdir -p "linux-tkg.db/$name"
                echo -e "%FILENAME%\n$pkg\n" > "linux-tkg.db/$name/desc"
            done
            tar czf linux-tkg.db.tar.gz linux-tkg.db
            rm -rf linux-tkg.db
            ln -sf linux-tkg.db.tar.gz linux-tkg.db
            cp linux-tkg.db.tar.gz linux-tkg.files.tar.gz
            ln -sf linux-tkg.files.tar.gz linux-tkg.files
        )
    fi
done

# === DEBIAN ===
echo "=== Processing Debian packages ==="
deb_count=0
shopt -s nullglob
for pkg in packages/debian-*/*.deb; do
    cp -v "$pkg" "$STAGING/debian/pool/main/"
    ((deb_count++)) || true
done
shopt -u nullglob
echo "Copied $deb_count Debian packages"

if [ $deb_count -gt 0 ]; then
    (
        cd "$STAGING/debian"
        dpkg-scanpackages pool/main > dists/stable/main/binary-amd64/Packages
        cp dists/stable/main/binary-amd64/Packages dists/stable/main/binary-arm64/Packages
        gzip -k dists/stable/main/binary-amd64/Packages
        gzip -k dists/stable/main/binary-arm64/Packages
        
        cat > dists/stable/Release <<EOF
Origin: linux-tkg-ci
Label: linux-tkg
Suite: stable
Codename: stable
Version: $VERSION
Architectures: amd64 arm64
Components: main
Date: $(date -Ru)
EOF
    )
fi

# === FEDORA ===
echo "=== Processing Fedora packages ==="
for arch in x86_64 aarch64; do
    dest="$STAGING/fedora/$arch"
    count=0
    
    shopt -s nullglob
    for pkg in packages/fedora-${arch}-*/*.rpm; do
        cp -v "$pkg" "$dest/"
        ((count++)) || true
    done
    shopt -u nullglob
    
    echo "Copied $count packages for fedora/$arch"
    
    if [ $count -gt 0 ]; then
        createrepo_c "$dest"
    fi
done

# Summary
echo "=== Repository Summary ==="
find "$STAGING" -type f | wc -l
echo "files created"
