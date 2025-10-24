# Creating a .deb Package for Ladybird Browser

This document provides instructions for creating a Debian package (.deb) for the Ladybird browser.

## Prerequisites

Before creating a .deb package, ensure you have:

1. **Built Ladybird successfully** following the [Build Instructions](BuildInstructionsLadybird.md)
2. **Installed packaging tools**:
   ```bash
   sudo apt install devscripts debhelper dh-make build-essential
   ```

## Package Structure Overview

The Ladybird browser consists of several components that need to be packaged:

- **Main executable**: `Ladybird` (Qt-based browser UI)
- **Helper processes**: `WebContent`, `RequestServer`, `ImageDecoder`, `WebWorker`
- **Libraries**: Various Lagom libraries (liblagom-*.so)
- **Resources**: Fonts, icons, themes, and web content
- **Desktop integration**: .desktop file, icons, metainfo

## Step-by-Step Packaging Instructions

### 1. Prepare the Build Directory

First, ensure you have a clean build:

```bash
cd /path/to/ladybird
./Meta/ladybird.py build
```

### 2. Create Package Directory Structure

Create a temporary directory for packaging:

```bash
mkdir -p /tmp/ladybird-deb
cd /tmp/ladybird-deb
mkdir -p ladybird-1.0.0/debian
```

### 3. Install Files to Package Directory

Use CMake's install target to place files in the correct locations:

```bash
cd /path/to/ladybird
cmake --install Build/release --prefix /tmp/ladybird-deb/ladybird-1.0.0/usr/local
```

### 4. Create Debian Control Files

#### `debian/control`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/control`:

```
Source: ladybird
Section: web
Priority: optional
Maintainer: Your Name <your.email@example.com>
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

Package: ladybird
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, 
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
```

#### `debian/rules`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/rules`:

```makefile
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
```

Make it executable:
```bash
chmod +x /tmp/ladybird-deb/ladybird-1.0.0/debian/rules
```

#### `debian/changelog`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/changelog`:

```
ladybird (1.0.0-1) unstable; urgency=medium

  * Initial release of Ladybird browser
  * Multi-process architecture with sandboxed renderer
  * Standards-compliant web engine implementation
  * Qt6-based user interface
  * Support for modern web standards

 -- Your Name <your.email@example.com>  $(date -R)
```

#### `debian/copyright`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/copyright`:

```
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: ladybird
Source: https://github.com/LadybirdBrowser/ladybird

Files: *
Copyright: 2020-2025 Ladybird Browser contributors
License: BSD-2-Clause

Files: debian/*
Copyright: 2025 Your Name <your.email@example.com>
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
```

#### `debian/install`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/install`:

```
usr/local/bin/Ladybird usr/bin/
usr/local/libexec/* usr/lib/ladybird/
usr/local/lib/* usr/lib/
usr/local/share/Lagom/* usr/share/ladybird/
```

#### `debian/ladybird.desktop`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/ladybird.desktop`:

```
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
```

#### `debian/ladybird.install`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/ladybird.install`:

```
debian/ladybird.desktop usr/share/applications/
usr/share/ladybird/icons/16x16/* usr/share/icons/hicolor/16x16/apps/
usr/share/ladybird/icons/32x32/* usr/share/icons/hicolor/32x32/apps/
usr/share/ladybird/icons/48x48/* usr/share/icons/hicolor/48x48/apps/
usr/share/ladybird/icons/128x128/* usr/share/icons/hicolor/128x128/apps/
```

#### `debian/manpages`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/manpages`:

```
usr/share/man/man1/ladybird.1
```

#### `debian/ladybird.1`

Create `/tmp/ladybird-deb/ladybird-1.0.0/debian/ladybird.1`:

```
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
```

### 5. Create Symbolic Links and Fix Paths

```bash
cd /tmp/ladybird-deb/ladybird-1.0.0
ln -sf usr/bin/Ladybird usr/bin/ladybird
```

### 6. Build the Package

```bash
cd /tmp/ladybird-deb/ladybird-1.0.0
dpkg-buildpackage -us -uc -b
```

### 7. Install the Package (Optional)

To install the generated package:

```bash
cd /tmp/ladybird-deb
sudo dpkg -i ladybird_1.0.0-1_amd64.deb
```

If there are dependency issues, fix them with:

```bash
sudo apt-get install -f
```

## Advanced Packaging Options

### Creating a Source Package

To create a source package for distribution:

```bash
dpkg-buildpackage -S
```

### Signing the Package

To sign the package with your GPG key:

```bash
dpkg-buildpackage -k<your-gpg-key-id>
```

### Creating Multiple Architecture Packages

For cross-compilation or multiple architectures, modify the `Architecture` field in `debian/control`:

```
Architecture: any
```

Or specify specific architectures:

```
Architecture: amd64 arm64 armhf
```

## Package Verification

After building, verify the package contents:

```bash
dpkg -c ladybird_1.0.0-1_amd64.deb
dpkg -I ladybird_1.0.0-1_amd64.deb
```

## Troubleshooting

### Common Issues

1. **Missing dependencies**: Ensure all build dependencies are installed
2. **File permissions**: Check that all files have correct permissions
3. **Path issues**: Verify that symbolic links and paths are correct
4. **Library dependencies**: Use `ldd` to check library dependencies

### Debugging Commands

```bash
# Check package contents
dpkg -c package.deb

# Check package information
dpkg -I package.deb

# Check library dependencies
ldd usr/bin/Ladybird

# Test package installation
dpkg --dry-run -i package.deb
```

## Integration with Build System

For automated packaging, you can integrate this process with the CMake build system by adding packaging targets to the main `CMakeLists.txt`:

```cmake
# Add to CMakeLists.txt
if(UNIX AND NOT APPLE)
    include(CPack)
    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Your Name <your.email@example.com>")
    set(CPACK_DEBIAN_PACKAGE_DEPENDS "libqt6core6, libqt6gui6, libqt6widgets6")
    set(CPACK_DEBIAN_PACKAGE_SECTION "web")
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_PACKAGE_VERSION_MAJOR "1")
    set(CPACK_PACKAGE_VERSION_MINOR "0")
    set(CPACK_PACKAGE_VERSION_PATCH "0")
endif()
```

Then build packages with:

```bash
make package
```

## Notes

- The package structure follows Debian packaging standards
- All helper processes are placed in `/usr/lib/ladybird/`
- Resources are installed to `/usr/share/ladybird/`
- The main executable is symlinked as `ladybird` for easier access
- Desktop integration files are properly installed for system integration

This packaging approach ensures that Ladybird integrates properly with the Debian/Ubuntu ecosystem while maintaining its multi-process architecture and security features.
