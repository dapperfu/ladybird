# Ladybird Browser Makefile
# Provides convenient targets for building and packaging

.PHONY: all build rebuild clean deb rebuild-deb install-deb test

# Default target
all: build

# Build the project (only if Build/release doesn't exist or is incomplete)
build:
	@echo "Building Ladybird..."
	@if [ ! -d "Build/release" ] || [ ! -f "Build/release/cmake_install.cmake" ] || [ ! -f "Build/release/Ladybird" ]; then \
		echo "Build directory not found or incomplete, configuring and building..."; \
		cmake --preset Release; \
		cmake --build --preset Release; \
	else \
		echo "Build directory exists and appears complete, skipping build..."; \
	fi

# Force rebuild (clean + build)
rebuild: clean build

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf Build/
	rm -f *.deb

# Build Debian package (uses existing build or creates from working package)
deb: 
	@echo "Building Debian package..."
	@if [ ! -f "Meta/build-deb-simple.sh" ]; then \
		echo "Error: Meta/build-deb-simple.sh not found"; \
		exit 1; \
	fi
	@if [ -d "Build/release" ] && [ -f "Build/release/cmake_install.cmake" ] && [ -f "Build/release/bin/Ladybird" ]; then \
		echo "Using existing complete build directory..."; \
		./Meta/build-deb-simple.sh; \
	elif [ -x "/usr/local/bin/Ladybird" ]; then \
		echo "Using existing working installation..."; \
		./Meta/build-deb-from-install.sh; \
	else \
		echo "No working build or installation found. Please run 'make rebuild' first."; \
		exit 1; \
	fi

# Rebuild everything and create package
rebuild-deb: clean build deb

# Install the built package
install-deb: deb
	@echo "Installing Debian package..."
	@if [ ! -f "/tmp/ladybird-deb/ladybird-1.0.0.deb" ]; then \
		echo "Error: Package not found. Run 'make deb' first."; \
		exit 1; \
	fi
	sudo dpkg -i /tmp/ladybird-deb/ladybird-1.0.0.deb
	@echo "Package installed successfully!"

# Test the installed package
test: install-deb
	@echo "Testing Ladybird installation..."
	ladybird --version
	@echo "Test completed successfully!"

# Help target
help:
	@echo "Ladybird Browser Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Build the project (default)"
	@echo "  build      - Build the project using CMake (if needed)"
	@echo "  rebuild    - Force rebuild (clean + build)"
	@echo "  clean      - Clean build artifacts and packages"
	@echo "  deb        - Build Debian package from existing build"
	@echo "  rebuild-deb- Clean, rebuild, and create package"
	@echo "  install-deb- Install the built Debian package"
	@echo "  test       - Build, package, install, and test"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deb          # Build .deb package (uses existing build)"
	@echo "  make rebuild-deb  # Clean rebuild and create package"
	@echo "  make install-deb  # Build and install package"
	@echo "  make test        # Complete build and test cycle"
