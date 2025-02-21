# Makefile for Flutter Frontend

# Define variables
FLUTTER = flutter

# Default target
all: run

# Clean the project
clean:
	@echo "Cleaning the project..."
	$(FLUTTER) clean

# Get dependencies
get-deps:
	@echo "Getting dependencies..."
	$(FLUTTER) pub get

# Run the app on a specific device
run:
	@echo "Running the app on device $(DEVICE)..."
	$(FLUTTER) run -d $(DEVICE)

integration_test:
	flutter drive --driver=test_driver/integration_test_driver.dart --target=integration_test/workout_tracker_test.dart --device-id $(DEVICE)

# Build the app for release
build-release:
	@echo "Building the app for release..."
	$(FLUTTER) build apk --release

# Build the app for debug
build-debug:
	@echo "Building the app for debug..."
	$(FLUTTER) build apk --debug

# Format the code
format:
	@echo "Formatting the code..."
	$(FLUTTER) format .

# Analyze the code
analyze:
	@echo "Analyzing the code..."
	$(FLUTTER) analyze

# Test the app
test:
	@echo "Running tests..."
	$(FLUTTER) test

# Help
help:
	@echo "Usage: make [target] [DEVICE=device_id]"
	@echo "Targets:"
	@echo "  all            Run the app (default)"
	@echo "  clean          Clean the project"
	@echo "  get-deps       Get dependencies"
	@echo "  run            Run the app on a specific device"
	@echo "  build-release  Build the app for release"
	@echo "  build-debug    Build the app for debug"
	@echo "  format         Format the code"
	@echo "  analyze        Analyze the code"
	@echo "  test           Run tests"
	@echo "  help           Show this help message"

.PHONY: all clean get-deps run build-release build-debug format analyze test help
.PHONY: integration_test