#!/bin/bash

# Ladybird Debian Package Builder (From Installation)
# This script creates a .deb package from an existing installation

set -e

# Configuration
PACKAGE_NAME="ladybird"
PACKAGE_VERSION="1.0.0"
PACKAGE_REVISION="1"
MAINTAINER_NAME="Ladybird Browser Team"
MAINTAINER_EMAIL="team@ladybird.org"
BUILD_DIR="/tmp/ladybird-deb"
SOURCE_DIR="$(pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check if we're in the right directory
if [[ ! -f "CMakeLists.txt" ]] || [[ ! -d "Meta" ]]; then
    print_error "This script must be run from the Ladybird source root directory"
fi

# Check if Ladybird is installed
if [[ ! -x "/usr/local/bin/Ladybird" ]]; then
    print_error "Ladybird is not installed at /usr/local/bin/Ladybird"
fi

# Clean up previous build artifacts
print_status "Cleaning up previous build directory: $BUILD_DIR"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

package_dir="$BUILD_DIR/$PACKAGE_NAME-$PACKAGE_VERSION"
mkdir -p "$package_dir/DEBIAN"

# Create control file
print_status "Creating DEBIAN/control file..."
cat << EOF > "$package_dir/DEBIAN/control"
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION-$PACKAGE_REVISION
Architecture: amd64
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Depends: libqt6core6t64, libqt6gui6t64, libqt6widgets6t64, libqt6waylandclient6, libgl1, libdrm2, libpulse0
Description: The Ladybird web browser
 Ladybird is a new, independent web browser engine and UI.
 It aims to be a modern, fast, and secure browser.
EOF

# Copy installed files to package directory
print_status "Copying installed files to package directory..."
mkdir -p "$package_dir/usr/local"

# Copy only Ladybird-specific files
if [[ -d "/usr/local/bin" ]]; then
    mkdir -p "$package_dir/usr/local/bin"
    # Copy Ladybird executables
    for exe in Ladybird js wasm; do
        if [[ -f "/usr/local/bin/$exe" ]]; then
            cp "/usr/local/bin/$exe" "$package_dir/usr/local/bin/"
        fi
    done
fi

if [[ -d "/usr/local/lib" ]]; then
    mkdir -p "$package_dir/usr/local/lib"
    # Copy Ladybird libraries
    cp /usr/local/lib/liblagom-*.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libskia.so "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/liblibEGL_angle.so "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/liblibGLESv2_angle.so "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libSDL3.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libxml2.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libjpeg.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libturbojpeg.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libicu*.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libjxl*.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libcpptrace.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libav*.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libtommath.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libdwarf.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libswresample.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libtheora*.so "$package_dir/usr/local/lib/" 2>/dev/null || true
    cp /usr/local/lib/libsimdutf.so* "$package_dir/usr/local/lib/" 2>/dev/null || true
    # Copy from build directory if not in /usr/local/lib
    if [[ ! -f "$package_dir/usr/local/lib/libsimdutf.so.26.0.0" ]]; then
        cp /projects/ladybird/Build/release/vcpkg_installed/x64-linux-dynamic/lib/libsimdutf.so.26.0.0 "$package_dir/usr/local/lib/" 2>/dev/null || true
        ln -sf libsimdutf.so.26.0.0 "$package_dir/usr/local/lib/libsimdutf.so.26" 2>/dev/null || true
    fi
fi

if [[ -d "/usr/local/include" ]]; then
    mkdir -p "$package_dir/usr/local/include"
    cp -r /usr/local/include/* "$package_dir/usr/local/include/" 2>/dev/null || true
fi

if [[ -f "/usr/local/COMMIT" ]]; then
    cp "/usr/local/COMMIT" "$package_dir/usr/local/"
fi

# Create symlink for easier access
mkdir -p "$package_dir/usr/bin"
ln -sf ../local/bin/Ladybird "$package_dir/usr/bin/ladybird"

# Copy desktop file and icon if they exist
if [[ -f "Meta/ladybird.desktop" ]]; then
    print_status "Copying desktop file..."
    mkdir -p "$package_dir/usr/share/applications"
    cp "Meta/ladybird.desktop" "$package_dir/usr/share/applications/"
fi

if [[ -f "Meta/ladybird.svg" ]]; then
    print_status "Copying icon..."
    mkdir -p "$package_dir/usr/share/icons/hicolor/scalable/apps"
    cp "Meta/ladybird.svg" "$package_dir/usr/share/icons/hicolor/scalable/apps/"
fi

# Build the .deb package
print_status "Building the .deb package..."
dpkg-deb --build "$package_dir" "$BUILD_DIR/$PACKAGE_NAME-$PACKAGE_VERSION.deb"

print_status "Debian package created successfully: $BUILD_DIR/$PACKAGE_NAME-$PACKAGE_VERSION.deb"
print_status "Package size: $(du -h "$BUILD_DIR/$PACKAGE_NAME-$PACKAGE_VERSION.deb" | cut -f1)"
