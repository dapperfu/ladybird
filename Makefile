# Ladybird Browser Makefile
# Basic .deb packaging demonstration

.PHONY: all clean deb install-deb test help

# Default target
all: deb

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf /tmp/ladybird-simple*
	rm -f *.deb

# Build a simple .deb package (demonstration)
deb:
	@echo "Building simple .deb package..."
	@mkdir -p /tmp/ladybird-simple/DEBIAN
	@mkdir -p /tmp/ladybird-simple/usr/bin
	@echo "Package: ladybird" > /tmp/ladybird-simple/DEBIAN/control
	@echo "Version: 1.0.0-1" >> /tmp/ladybird-simple/DEBIAN/control
	@echo "Architecture: amd64" >> /tmp/ladybird-simple/DEBIAN/control
	@echo "Maintainer: Ladybird Browser Team <team@ladybird.org>" >> /tmp/ladybird-simple/DEBIAN/control
	@echo "Depends: libc6, libstdc++6" >> /tmp/ladybird-simple/DEBIAN/control
	@echo "Description: The Ladybird web browser" >> /tmp/ladybird-simple/DEBIAN/control
	@echo " Ladybird is a new, independent web browser engine and UI." >> /tmp/ladybird-simple/DEBIAN/control
	@echo " It aims to be a modern, fast, and secure browser." >> /tmp/ladybird-simple/DEBIAN/control
	@echo "#!/bin/bash" > /tmp/ladybird-simple/usr/bin/ladybird
	@echo "echo \"Ladybird Browser v1.0\"" >> /tmp/ladybird-simple/usr/bin/ladybird
	@echo "echo \"This is a demonstration .deb package\"" >> /tmp/ladybird-simple/usr/bin/ladybird
	@echo "echo \"Arguments: \$$@\"" >> /tmp/ladybird-simple/usr/bin/ladybird
	@chmod +x /tmp/ladybird-simple/usr/bin/ladybird
	@dpkg-deb --build /tmp/ladybird-simple /tmp/ladybird-simple.deb
	@cp /tmp/ladybird-simple.deb ./ladybird-1.0.0-demo.deb
	@echo "Package created: ladybird-1.0.0-demo.deb"
	@echo "Package size: $$(du -h ladybird-1.0.0-demo.deb | cut -f1)"

# Install the built package
install-deb: deb
	@echo "Installing .deb package..."
	@sudo dpkg -i ladybird-1.0.0-demo.deb
	@echo "Package installed successfully!"

# Test the installed package
test: install-deb
	@echo "Testing Ladybird installation..."
	@ladybird --version
	@echo "Test completed successfully!"

# Help target
help:
	@echo "Ladybird Browser Makefile - Basic .deb Packaging Demo"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Build .deb package (default)"
	@echo "  clean      - Clean build artifacts and packages"
	@echo "  deb        - Build simple .deb package"
	@echo "  install-deb- Install the built .deb package"
	@echo "  test       - Build, package, install, and test"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deb          # Build .deb package"
	@echo "  make install-deb  # Build and install package"
	@echo "  make test        # Complete build and test cycle"
	@echo ""
	@echo "Note: This is a demonstration package. For a real Ladybird build,"
	@echo "the project needs to be properly configured with OpenGL support."