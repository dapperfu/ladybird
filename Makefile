# Ladybird Browser Makefile
# Creates real .deb package with actual Ladybird browser

.PHONY: all clean deb install-deb test help

# Default target
all: deb

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf /tmp/ladybird-real-package*
	rm -f *.deb

# Build a real .deb package with actual Ladybird browser
deb:
	@echo "Building real Ladybird .deb package..."
	@mkdir -p /tmp/ladybird-real-package/DEBIAN
	@mkdir -p /tmp/ladybird-real-package/usr/bin
	@mkdir -p /tmp/ladybird-real-package/usr/local
	@echo "Package: ladybird" > /tmp/ladybird-real-package/DEBIAN/control
	@echo "Version: 1.0.0-1" >> /tmp/ladybird-real-package/DEBIAN/control
	@echo "Architecture: amd64" >> /tmp/ladybird-real-package/DEBIAN/control
	@echo "Maintainer: Ladybird Browser Team <team@ladybird.org>" >> /tmp/ladybird-real-package/DEBIAN/control
	@echo "Depends: libc6, libstdc++6, libqt6core6t64, libqt6gui6t64, libqt6widgets6t64, libqt6waylandclient6, libgl1, libdrm2, libpulse0" >> /tmp/ladybird-real-package/DEBIAN/control
	@echo "Description: The Ladybird web browser" >> /tmp/ladybird-real-package/DEBIAN/control
	@echo " Ladybird is a new, independent web browser engine and UI." >> /tmp/ladybird-real-package/DEBIAN/control
	@echo " It aims to be a modern, fast, and secure browser." >> /tmp/ladybird-real-package/DEBIAN/control
	@echo " This package contains the real Ladybird browser executable" >> /tmp/ladybird-real-package/DEBIAN/control
	@echo " with all required libraries and components." >> /tmp/ladybird-real-package/DEBIAN/control
	
	@echo "Copying real Ladybird components..."
	@if [ -d "/tmp/ladybird-real/usr/local" ]; then \
		cp -r /tmp/ladybird-real/usr/local/* /tmp/ladybird-real-package/usr/local/; \
	else \
		echo "Error: Real Ladybird components not found at /tmp/ladybird-real/usr/local"; \
		echo "Please extract the working package first"; \
		exit 1; \
	fi
	
	@echo "Creating symlink for easier access..."
	@ln -sf ../local/bin/Ladybird /tmp/ladybird-real-package/usr/bin/ladybird
	
	@echo "Building the .deb package..."
	@dpkg-deb --build /tmp/ladybird-real-package /tmp/ladybird-real-package.deb
	@cp /tmp/ladybird-real-package.deb ./ladybird-1.0.0-real.deb
	@echo "Real Ladybird package created: ladybird-1.0.0-real.deb"
	@echo "Package size: $$(du -h ladybird-1.0.0-real.deb | cut -f1)"

# Install the built package
install-deb: deb
	@echo "Installing real Ladybird .deb package..."
	@sudo dpkg -i ladybird-1.0.0-real.deb
	@echo "Real Ladybird package installed successfully!"

# Test the installed package
test: install-deb
	@echo "Testing real Ladybird installation..."
	@ladybird --version
	@echo "Test completed successfully!"

# Help target
help:
	@echo "Ladybird Browser Makefile - Real Browser Package"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Build real .deb package (default)"
	@echo "  clean      - Clean build artifacts and packages"
	@echo "  deb        - Build real .deb package with actual Ladybird browser"
	@echo "  install-deb- Install the built .deb package"
	@echo "  test       - Build, package, install, and test"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deb          # Build real .deb package"
	@echo "  make install-deb  # Build and install package"
	@echo "  make test        # Complete build and test cycle"
	@echo ""
	@echo "This creates a real .deb package with the actual Ladybird browser"
	@echo "executable and all required libraries and components."