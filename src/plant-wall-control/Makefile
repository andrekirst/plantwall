# Plant Wall Control Backend - Makefile
# Optimized for Raspberry Pi deployment

.PHONY: build run clean dev cross-compile-arm64 install deps test deploy deploy-full install-service health-check

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOCLEAN=$(GOCMD) clean
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod

# Binary names
BINARY_NAME=plant-wall-control
BINARY_UNIX=$(BINARY_NAME)_unix
BINARY_ARM64=$(BINARY_NAME)_arm64

# Default target
all: deps test build

# Install dependencies
deps:
	$(GOMOD) download
	$(GOMOD) tidy

# Build for current platform
build:
	$(GOBUILD) -o $(BINARY_NAME) -v ./

# Run the application
run: build
	./$(BINARY_NAME)

# Development mode with auto-restart (requires air: go install github.com/cosmtrek/air@latest)
dev:
	@which air > /dev/null || (echo "Installing air for hot reload..." && go install github.com/cosmtrek/air@latest)
	air

# Cross compile for Raspberry Pi (ARM64)
cross-compile-arm64:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm64 $(GOBUILD) -o $(BINARY_ARM64) -v ./

# Cross compile for Raspberry Pi Zero (ARM32)
cross-compile-arm32:
	CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 $(GOBUILD) -o $(BINARY_NAME)_arm32 -v ./

# Test the application
test:
	$(GOTEST) -v ./...

# Clean build artifacts
clean:
	$(GOCLEAN)
	rm -f $(BINARY_NAME)
	rm -f $(BINARY_UNIX)
	rm -f $(BINARY_ARM64)
	rm -f $(BINARY_NAME)_arm32

# Format code
fmt:
	$(GOCMD) fmt ./...

# Lint code (requires golangci-lint)
lint:
	@which golangci-lint > /dev/null || (echo "Installing golangci-lint..." && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $$(go env GOPATH)/bin v1.54.2)
	golangci-lint run


# Install system dependencies on Raspberry Pi (run on Pi)
install-system-deps:
	sudo apt-get update
	sudo apt-get install -y git build-essential

# Full deployment with systemd service (automated)
deploy-full:
	./systemd/deploy.sh

# Quick deployment (legacy)
# Usage: make deploy HOST=pi@192.168.1.100
deploy: cross-compile-arm64
	@if [ -z "$(HOST)" ]; then echo "Usage: make deploy HOST=pi@192.168.1.100"; exit 1; fi
	scp $(BINARY_ARM64) $(HOST):~/$(BINARY_NAME)
	scp config.yaml $(HOST):~/config.yaml
	ssh $(HOST) "chmod +x ~/$(BINARY_NAME)"
	@echo "Deployed to $(HOST)"

# Install systemd service (run on Pi)
install-service: cross-compile-arm64
	sudo ./systemd/install-service.sh

# Run health check
health-check:
	./systemd/health-check.sh --status

# Show deployment status
status:
	./systemd/deploy.sh --status

# View remote logs
logs:
	./systemd/deploy.sh --logs

# Show help
help:
	@echo "Available targets:"
	@echo ""
	@echo "Development:"
	@echo "  deps                 - Install Go dependencies"
	@echo "  build                - Build for current platform"
	@echo "  run                  - Build and run the application"
	@echo "  dev                  - Run in development mode with hot reload"
	@echo "  test                 - Run tests"
	@echo "  fmt                  - Format Go code"
	@echo "  lint                 - Lint Go code"
	@echo "  clean                - Clean build artifacts"
	@echo ""
	@echo "Cross-compilation:"
	@echo "  cross-compile-arm64  - Cross compile for Raspberry Pi 4/Zero 2W"
	@echo "  cross-compile-arm32  - Cross compile for Raspberry Pi Zero/1"
	@echo ""
	@echo "Deployment:"
	@echo "  deploy-full          - Full automated deployment with systemd service"
	@echo "  deploy HOST=<host>   - Simple binary deployment via SSH"
	@echo "  install-service      - Install systemd service (run on Pi)"
	@echo "  status               - Check remote deployment status"
	@echo "  logs                 - View remote service logs"
	@echo "  health-check         - Run local health check"
	@echo ""
	@echo "Environment Variables for Deployment:"
	@echo "  PI_HOST=hostname     - Target Pi hostname/IP (default: plantwall.local)"
	@echo "  PI_USER=username     - SSH username (default: pi)"
	@echo "  PI_SSH_PORT=port     - SSH port (default: 22)"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy-full                           # Deploy to plantwall.local"
	@echo "  PI_HOST=192.168.1.100 make deploy-full    # Deploy to specific IP"
	@echo "  make status                                # Check deployment status"
	@echo "  help                                       - Show this help message"