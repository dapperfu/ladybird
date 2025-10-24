#!/bin/bash

# Ladybird Debian Package Builder (Simplified Version)
# This script creates a .deb package using only dpkg-deb

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
}

# Check if we're in the right directory
if [[ ! -f "CMakeLists.txt" ]] || [[ ! -d "Meta" ]]; then
    print_error "This script must be run from the Ladybird source root directory"
    exit 1
fi

# Check if build exists
if [[ ! -d "Build/release" ]]; then
    print_error "Build directory not found. Please run './Meta/ladybird.py build' first"
    exit 1
fi

# Check for required tools
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v dpkg-deb &> /dev/null; then
        print_error "dpkg-deb not found. This is required for creating .deb packages."
        exit 1
    fi
    
    print_status "All dependencies found"
}

# Clean up previous builds
cleanup() {
    print_status "Cleaning up previous builds..."
    rm -rf "$BUILD_DIR"
}

# Create package directory structure
create_package_structure() {
    print_status "Creating package directory structure..."
    
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    local package_dir="${PACKAGE_NAME}-${PACKAGE_VERSION}"
    mkdir -p "$package_dir/DEBIAN"
    
    print_status "Package directory: $BUILD_DIR/$package_dir"
}

# Install files to package directory
install_files() {
    print_status "Installing files to package directory..."
    
    local package_dir="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    
    cd "$SOURCE_DIR"
    cmake --install Build/release --prefix "$package_dir/usr/local"
    
    # Install additional libraries from vcpkg
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libskia.so "$package_dir/usr/local/lib/"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/liblibEGL_angle.so "$package_dir/usr/local/lib/"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/liblibGLESv2_angle.so "$package_dir/usr/local/lib/"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libSDL3.so.0.2.22 "$package_dir/usr/local/lib/"
    ln -sf libSDL3.so.0.2.22 "$package_dir/usr/local/lib/libSDL3.so.0"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libxml2.so.16.1.0 "$package_dir/usr/local/lib/"
    ln -sf libxml2.so.16.1.0 "$package_dir/usr/local/lib/libxml2.so.16"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libjpeg.so.62.4.0 "$package_dir/usr/local/lib/"
    ln -sf libjpeg.so.62.4.0 "$package_dir/usr/local/lib/libjpeg.so.62"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libturbojpeg.so.0.4.0 "$package_dir/usr/local/lib/"
    ln -sf libturbojpeg.so.0.4.0 "$package_dir/usr/local/lib/libturbojpeg.so.0"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libicuuc.so.76.1 "$package_dir/usr/local/lib/"
    ln -sf libicuuc.so.76.1 "$package_dir/usr/local/lib/libicuuc.so.76"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libicui18n.so.76.1 "$package_dir/usr/local/lib/"
    ln -sf libicui18n.so.76.1 "$package_dir/usr/local/lib/libicui18n.so.76"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libicudata.so.76.1 "$package_dir/usr/local/lib/"
    ln -sf libicudata.so.76.1 "$package_dir/usr/local/lib/libicudata.so.76"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libicutu.so.76.1 "$package_dir/usr/local/lib/"
    ln -sf libicutu.so.76.1 "$package_dir/usr/local/lib/libicutu.so.76"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libicuio.so.76.1 "$package_dir/usr/local/lib/"
    ln -sf libicuio.so.76.1 "$package_dir/usr/local/lib/libicuio.so.76"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libjxl.so.0.11.1 "$package_dir/usr/local/lib/"
    ln -sf libjxl.so.0.11.1 "$package_dir/usr/local/lib/libjxl.so.0.11"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libjxl_cms.so.0.11.1 "$package_dir/usr/local/lib/"
    ln -sf libjxl_cms.so.0.11.1 "$package_dir/usr/local/lib/libjxl_cms.so.0.11"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libjxl_threads.so.0.11.1 "$package_dir/usr/local/lib/"
    ln -sf libjxl_threads.so.0.11.1 "$package_dir/usr/local/lib/libjxl_threads.so.0.11"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libcpptrace.so.1.0.2 "$package_dir/usr/local/lib/"
    ln -sf libcpptrace.so.1.0.2 "$package_dir/usr/local/lib/libcpptrace.so.1"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libavcodec.so.61.19.101 "$package_dir/usr/local/lib/"
    ln -sf libavcodec.so.61.19.101 "$package_dir/usr/local/lib/libavcodec.so.61"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libavformat.so.61.7.100 "$package_dir/usr/local/lib/"
    ln -sf libavformat.so.61.7.100 "$package_dir/usr/local/lib/libavformat.so.61"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libavutil.so.59.39.100 "$package_dir/usr/local/lib/"
    ln -sf libavutil.so.59.39.100 "$package_dir/usr/local/lib/libavutil.so.59"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libtommath.so.1.3.0 "$package_dir/usr/local/lib/"
    ln -sf libtommath.so.1.3.0 "$package_dir/usr/local/lib/libtommath.so.1"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libdwarf.so.2.1.0 "$package_dir/usr/local/lib/"
    ln -sf libdwarf.so.2.1.0 "$package_dir/usr/local/lib/libdwarf.so.2"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libswresample.so.5.3.100 "$package_dir/usr/local/lib/"
    ln -sf libswresample.so.5.3.100 "$package_dir/usr/local/lib/libswresample.so.5"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libtheora.so "$package_dir/usr/local/lib/"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libtheoradec.so "$package_dir/usr/local/lib/"
    cp Build/release/vcpkg_installed/x64-linux-dynamic/lib/libtheoraenc.so "$package_dir/usr/local/lib/"
    
    # Create symlink for easier access
    mkdir -p "$package_dir/usr/bin"
    ln -sf ../local/bin/Ladybird "$package_dir/usr/bin/ladybird"
    
    # Create desktop file
    mkdir -p "$package_dir/usr/share/applications"
    cat > "$package_dir/usr/share/applications/ladybird.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Ladybird Browser
Comment=Independent web browser based on web standards
Exec=ladybird %U
Icon=ladybird
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/vnd.mozilla.xul+xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;x-scheme-handler/chrome;video/webm;application/x-xpinstall;
StartupNotify=true
StartupWMClass=Ladybird
EOF

    # Create manpage
    mkdir -p "$package_dir/usr/share/man/man1"
    cat > "$package_dir/usr/share/man/man1/ladybird.1" << 'EOF'
.TH LADYBIRD 1 "2025-10-24" "Ladybird Browser" "User Commands"
.SH NAME
ladybird \- Independent web browser based on web standards
.SH SYNOPSIS
.B ladybird
[\fIOPTIONS\fR] [\fIURL\fR]
.SH DESCRIPTION
Ladybird is a truly independent web browser, using a novel engine based on 
web standards. It features a multi-process architecture with sandboxed 
renderer processes for improved security and stability.
.SH OPTIONS
.TP
\fB\-\-help\fR
Show help message and exit
.TP
\fB\-\-version\fR
Show version information and exit
.TP
\fBURL\fR
URL to open in the browser
.SH EXAMPLES
.TP
.B ladybird
Start Ladybird with a blank page
.TP
.B ladybird https://ladybird.org
Start Ladybird and navigate to https://ladybird.org
.SH AUTHOR
Ladybird Browser contributors
.SH HOMEPAGE
https://ladybird.org
.SH BUGS
Report bugs at https://github.com/LadybirdBrowser/ladybird/issues
EOF

    print_status "Files installed successfully"
}

# Create control file
create_control_file() {
    print_status "Creating control file..."
    
    local package_dir="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    local control_file="$package_dir/DEBIAN/control"
    
    cat > "$control_file" << EOF
Package: $PACKAGE_NAME
Version: $PACKAGE_VERSION-$PACKAGE_REVISION
Section: web
Priority: optional
Architecture: amd64
Depends: libqt6core6t64, libqt6gui6t64, libqt6widgets6t64, libqt6waylandclient6, libgl1, libdrm2, libpulse0
Recommends: fonts-liberation2
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Description: Independent web browser based on web standards
 Ladybird is a truly independent web browser, using a novel engine based on 
 web standards. It features a multi-process architecture with sandboxed 
 renderer processes for improved security and stability.
 .
 Key features:
  * Multi-process architecture for security
  * Standards-compliant web engine
  * Modern C++ implementation
  * Cross-platform support
  * Independent from major browser vendors
Homepage: https://ladybird.org
EOF

    print_status "Control file created"
}

# Build the package
build_package() {
    print_status "Building Debian package..."
    
    local package_dir="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    
    cd "$BUILD_DIR"
    
    # Build the package using dpkg-deb
    dpkg-deb --build "$package_dir"
    
    print_status "Package built successfully"
}

# Show package information
show_package_info() {
    print_status "Package information:"
    
    cd "$BUILD_DIR"
    
    local package_file="${PACKAGE_NAME}-${PACKAGE_VERSION}.deb"
    
    if [[ -f "$package_file" ]]; then
        echo "Package file: $BUILD_DIR/$package_file"
        echo "Package size: $(du -h "$package_file" | cut -f1)"
        echo ""
        echo "Package contents:"
        dpkg-deb -c "$package_file" | head -20
        echo "..."
        echo ""
        echo "Package information:"
        dpkg-deb -I "$package_file"
    else
        print_error "Package file not found: $package_file"
        exit 1
    fi
}

# Main execution
main() {
    print_status "Starting Ladybird Debian package build..."
    print_status "Source directory: $SOURCE_DIR"
    print_status "Build directory: $BUILD_DIR"
    
    check_dependencies
    cleanup
    create_package_structure
    install_files
    create_control_file
    build_package
    show_package_info
    
    print_status "Package build completed successfully!"
    print_status "Package location: $BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}.deb"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0 [OPTIONS]"
        echo ""
        echo "Options:"
        echo "  --help, -h     Show this help message"
        echo "  --clean        Clean build directory and exit"
        echo ""
        echo "This script builds a Debian package for Ladybird browser."
        echo "Make sure to run './Meta/ladybird.py build' first."
        exit 0
        ;;
    --clean)
        cleanup
        print_status "Build directory cleaned"
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
