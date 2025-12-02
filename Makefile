# Nuke Arsenal - Build Configuration

APP_NAME=arsenal
VERSION?=$(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
BUILD_DIR=dist
CMD_DIR=cmd/arsenal

# Build flags
LDFLAGS=-ldflags "-s -w -X main.Version=$(VERSION)"

# Default target
.PHONY: all
all: help

# Build frontend assets
.PHONY: build-frontend
build-frontend:
	@echo "Building frontend..."
	@cd frontend && npm install --silent && npm run build
	@echo "Frontend built!"

# Build for current platform
.PHONY: build
build: build-frontend
	@echo "Building $(APP_NAME)..."
	@go build $(LDFLAGS) -o $(APP_NAME) ./$(CMD_DIR) 2>&1 | grep -v "^ld: warning" || true
	@echo "Done! Binary: ./$(APP_NAME)"

# Install to local bin
.PHONY: install
install: build
	@echo "Installing to /usr/local/bin/$(APP_NAME)..."
	@sudo cp $(APP_NAME) /usr/local/bin/
	@echo "Installed! Run 'arsenal' from anywhere"

# Quick dev workflow - build and run
.PHONY: dev
dev:
	@cd frontend && npm install && npm run build
	@wails3 dev

# Generate Wails bindings
.PHONY: bindings
bindings:
	@wails3 generate bindings -d frontend/bindings -clean=true ./$(CMD_DIR)/...

# Build macOS .app bundle (production)
.PHONY: app
app:
	@echo "Building macOS app bundle..."
	@wails3 task darwin:package
	@echo "Done! App bundle: bin/Nuke Arsenal.app"

# Build universal macOS .app bundle (arm64 + amd64)
.PHONY: app-universal
app-universal:
	@echo "Building universal macOS app bundle..."
	@wails3 task darwin:package:universal
	@echo "Done! Universal app bundle: bin/Nuke Arsenal.app"

# Install app to /Applications
.PHONY: install-app
install-app: app
	@echo "Installing Nuke Arsenal.app to /Applications..."
	@rm -rf "/Applications/Nuke Arsenal.app"
	@cp -R "bin/Nuke Arsenal.app" /Applications/
	@echo "Done! Nuke Arsenal installed to /Applications"

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR)
	@rm -rf bin
	@rm -f $(APP_NAME)
	@rm -rf frontend/dist frontend/node_modules
	@echo "Clean complete"

# Run tests
.PHONY: test
test:
	@echo "Running tests..."
	@go test -v ./...

# Format code
.PHONY: fmt
fmt:
	@echo "Formatting code..."
	@go fmt ./...
	@echo "Format complete"

# Check for issues
.PHONY: vet
vet:
	@echo "Running go vet..."
	@go vet ./...
	@echo "Vet complete"

# Show help
.PHONY: help
help:
	@echo "Nuke Arsenal - Build Targets"
	@echo ""
	@echo "  make build         - Build binary for current platform"
	@echo "  make install       - Install to /usr/local/bin (requires sudo)"
	@echo "  make dev           - Run in development mode with hot reload"
	@echo ""
	@echo "  make app           - Build macOS .app bundle (production)"
	@echo "  make app-universal - Build universal macOS .app (arm64 + amd64)"
	@echo "  make install-app   - Install .app to /Applications"
	@echo ""
	@echo "  make clean         - Remove build artifacts"
	@echo "  make test          - Run tests"
	@echo "  make fmt           - Format code"
	@echo "  make vet           - Check for issues"
	@echo ""

.DEFAULT_GOAL := help
