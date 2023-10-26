
# Install all dependencies
install:
	@cd app && make install
	@cd python && make install

# Install with force
install-f:
	@cd app && make install
	@cd python && make install-f

# Separate installations
install-app:
	@cd app && make install

install-python:
	@cd network && make install

run-app:
	@echo "Running Application"
	@cd app && make

# Build app for release
build-app-release:
	@echo "Building app release"
	@cd app && make action-build-release