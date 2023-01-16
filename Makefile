
install:
	sh frontend/setup.sh
	sh backend/setup.sh

install-fe:
	sh frontend/setup.sh

install-be:
	sh backend/setup.sh

run-fe:
	@echo "Running Frontend"
	@cd frontend && make

run-be:
	@echo "Running Backend"
	@cd backend && make