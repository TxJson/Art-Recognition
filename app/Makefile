
# Colour variables
# Taken from: https://gist.github.com/rsperl/d2dfe88a520968fbc1f49db0a29345b9
ifneq (,$(findstring xterm,${TERM}))
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET 		 := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif

all:
	@echo "$(YELLOW)Ensure you have your testing device plugged in, or else it may not be recognised$(RESET)"
	@echo "$(BLUE)Running Flutter$(RESET)"
	@cd src && flutter run lib/main.dart

install:
	sh setup.sh -s

action-build-appbundle:
	@echo "$(BLUE)Building Flutter App Bundle$(RESET)"
	@cd src && flutter build appbundle

action-build-apk:
	@echo "$(BLUE)Building Flutter APK$(RESET)"
	@cd src && flutter build apk

action-build-apk-release:
	@echo "$(BLUE)Building Flutter APK Release$(RESET)"
	@cd src && flutter build apk --release