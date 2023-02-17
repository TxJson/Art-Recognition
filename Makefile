
install:
	@cd app && make install
	@cd network && make install

install-app:
	@cd app && make install

install-network:
	@cd network && make install

install-network-f:
	@cd network && make install-f

run-app:
	@echo "Running Application"
	@cd app && make

run-be:
	@echo "Running Network"
	@cd network && make