
install:
	sh app/setup.sh
	sh app/setup.sh

install-app:
	sh app/setup.sh

install-network:
	sh network/setup.sh

run-app:
	@echo "Running Application"
	@cd app && make

run-be:
	@echo "Running Network"
	@cd network && make