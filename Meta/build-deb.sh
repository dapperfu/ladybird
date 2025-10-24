#!/bin/bash

# Ladybird Debian Package Builder
# This script automates the creation of a .deb package for Ladybird browser

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
    
    local missing_deps=()
    
    for cmd in dpkg-buildpackage debhelper dh_make; do
        if ! command -v "$cmd" &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_error "Missing required tools: ${missing_deps[*]}"
        print_status "Install them with: sudo apt install devscripts debhelper dh-make build-essential"
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
    mkdir -p "$package_dir/debian"
    
    print_status "Package directory: $BUILD_DIR/$package_dir"
}

# Install files to package directory
install_files() {
    print_status "Installing files to package directory..."
    
    local package_dir="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    
    cd "$SOURCE_DIR"
    cmake --install Build/release --prefix "$package_dir/usr/local"
    
    # Create symlink for easier access
    ln -sf usr/bin/Ladybird "$package_dir/usr/bin/ladybird"
    
    print_status "Files installed successfully"
}

# Create debian control files
create_debian_files() {
    print_status "Creating Debian control files..."
    
    local package_dir="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    local debian_dir="$package_dir/debian"
    
    # Create control file
    cat > "$debian_dir/control" << EOF
Source: $PACKAGE_NAME
Section: web
Priority: optional
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Build-Depends: debhelper (>= 13), cmake (>= 3.25), ninja-build, 
               qt6-base-dev, qt6-tools-dev-tools, qt6-wayland,
               libdrm-dev, libgl1-mesa-dev, nasm, autoconf-archive,
               automake, libtool, pkg-config, python3-venv,
               fonts-liberation2, git, curl, tar, unzip, zip,
               libstdc++-14-dev, clang-20
Standards-Version: 4.6.2
Homepage: https://ladybird.org
Vcs-Browser: https://github.com/LadybirdBrowser/ladybird
Vcs-Git: https://github.com/LadybirdBrowser/ladybird.git

Package: $PACKAGE_NAME
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}, 
         libqt6core6, libqt6gui6, libqt6widgets6, libqt6wayland6,
         libgl1-mesa-glx, libdrm2, libpulse0
Recommends: fonts-liberation2
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
EOF

    # Create rules file
    cat > "$debian_dir/rules" << 'EOF'
#!/usr/bin/make -f

export DH_VERBOSE = 1
export DH_OPTIONS = -v

%:
	dh $@

override_dh_auto_configure:
	# Configuration is handled by the build process

override_dh_auto_build:
	# Build is handled by the build process

override_dh_auto_install:
	# Installation is handled by the build process

override_dh_auto_clean:
	# Clean is handled by the build process
EOF

    chmod +x "$debian_dir/rules"

    # Create changelog
    cat > "$debian_dir/changelog" << EOF
$PACKAGE_NAME ($PACKAGE_VERSION-$PACKAGE_REVISION) unstable; urgency=medium

  * Initial release of Ladybird browser
  * Multi-process architecture with sandboxed renderer
  * Standards-compliant web engine implementation
  * Qt6-based user interface
  * Support for modern web standards

 -- $MAINTAINER_NAME <$MAINTAINER_EMAIL>  $(date -R)
EOF

    # Create copyright file
    cat > "$debian_dir/copyright" << 'EOF'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ladybird
Source: https://github.com/LadybirdBrowser/ladybird

Files: *
Copyright: 2020-2025 Ladybird Browser contributors
License: BSD-2-Clause

Files: debian/*
Copyright: 2025 Ladybird Browser Team <team@ladybird.org>
License: BSD-2-Clause

License: BSD-2-Clause
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 .
 1. Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
 .
 2. Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
 .
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVISEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
EOF

    # Create install file
    cat > "$debian_dir/install" << 'EOF'
usr/local/bin/Ladybird usr/bin/
usr/local/libexec/* usr/lib/ladybird/
usr/local/lib/* usr/lib/
usr/local/share/Lagom/* usr/share/ladybird/
EOF

    # Create desktop file
    cat > "$debian_dir/ladybird.desktop" << 'EOF'
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

    # Create install file for desktop integration
    cat > "$debian_dir/ladybird.install" << 'EOF'
debian/ladybird.desktop usr/share/applications/
usr/share/ladybird/icons/16x16/* usr/share/icons/hicolor/16x16/apps/
usr/share/ladybird/icons/32x32/* usr/share/icons/hicolor/32x32/apps/
usr/share/ladybird/icons/48x48/* usr/share/icons/hicolor/48x48/apps/
usr/share/ladybird/icons/128x128/* usr/share/icons/hicolor/128x128/apps/
EOF

    # Create manpage
    cat > "$debian_dir/ladybird.1" << 'EOF'
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

    # Create manpages file
    echo "usr/share/man/man1/ladybird.1" > "$debian_dir/manpages"

    print_status "Debian control files created"
}

# Build the package
build_package() {
    print_status "Building Debian package..."
    
    local package_dir="$BUILD_DIR/${PACKAGE_NAME}-${PACKAGE_VERSION}"
    
    cd "$package_dir"
    
    # Build the package
    dpkg-buildpackage -us -uc -b
    
    print_status "Package built successfully"
}

# Show package information
show_package_info() {
    print_status "Package information:"
    
    cd "$BUILD_DIR"
    
    local package_file="${PACKAGE_NAME}_${PACKAGE_VERSION}-${PACKAGE_REVISION}_amd64.deb"
    
    if [[ -f "$package_file" ]]; then
        echo "Package file: $BUILD_DIR/$package_file"
        echo "Package size: $(du -h "$package_file" | cut -f1)"
        echo ""
        echo "Package contents:"
        dpkg -c "$package_file" | head -20
        echo "..."
        echo ""
        echo "Package information:"
        dpkg -I "$package_file"
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
    create_debian_files
    build_package
    show_package_info
    
    print_status "Package build completed successfully!"
    print_status "Package location: $BUILD_DIR/${PACKAGE_NAME}_${PACKAGE_VERSION}-${PACKAGE_REVISION}_amd64.deb"
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
