# ==============================================================================
# Makefile for user_last_login.sh
#
# Targets: install, uninstall, clean, test, lint, functional_test, help
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Variables and Dependencies
# ------------------------------------------------------------------------------

# Installation Paths
BIN_DIR = /usr/local/bin
MAN_DIR = /usr/local/man/man1
SCRIPT_NAME = user_last_login.sh
MAN_PAGE_NAME = user_last_login.1

# Runtime Directories
REPORT_DIR = /opt/sre-reports
LOG_DIR = /var/log/sre-tools

# Test Dependencies
SHELLCHECK_BIN := $(shell command -v shellcheck 2> /dev/null)
BATS_BIN := $(shell command -v bats 2> /dev/null)

.PHONY: all install uninstall clean help test lint functional_test

# ------------------------------------------------------------------------------
# 2. Main Targets  ------------------------------------------------------------------------------

# Default Target
all: help

# ------------------------------------------------------------------------------
# install: Installs script and man page to standard Unix locations.
# ------------------------------------------------------------------------------
install:
	@echo "--- Installing $(SCRIPT_NAME) and documentation ---"
	# 1. Установка исполняемого скрипта
	sudo cp $(SCRIPT_NAME) $(BIN_DIR)/
	sudo chmod +x $(BIN_DIR)/$(SCRIPT_NAME)
	# 2. Установка man-страницы
	sudo mkdir -p $(MAN_DIR)
	sudo cp $(MAN_PAGE_NAME) $(MAN_DIR)/
	# 3. Создание рабочих директорий для скрипта
	@echo "--- Creating standard report and log directories ---"
	sudo mkdir -p $(REPORT_DIR)
	sudo mkdir -p $(LOG_DIR)
	@echo "Installation complete. Run: man user_last_login"

# ------------------------------------------------------------------------------
# uninstall: Removes installed files.
# ------------------------------------------------------------------------------
uninstall:
	@echo "--- Removing installed files ---"
	sudo rm -f $(BIN_DIR)/$(SCRIPT_NAME)
	sudo rm -f $(MAN_DIR)/$(MAN_PAGE_NAME)
	@echo "Uninstallation complete."

# ------------------------------------------------------------------------------
# clean: Removes generated reports and logs.
# ------------------------------------------------------------------------------
clean:
	@echo "--- Cleaning up generated reports and logs ---"
	sudo rm -rf $(REPORT_DIR)/* || true
	sudo rm -rf $(LOG_DIR)/* || true
	@echo "Cleanup complete."

# ------------------------------------------------------------------------------
# 3. Testing Targets (Цели для тестирования - Основа для CI/CD)
# ------------------------------------------------------------------------------

# test: Runs linting and functional tests. (Эта цель вызывается в GitHub Actions)
test: lint functional_test

# lint: Runs ShellCheck on the main script.
lint:
ifeq ($(SHELLCHECK_BIN),)
	@echo "ERROR: ShellCheck is not installed. Please install it to run linting." >&2
	exit 1
endif
	@echo "--- Running ShellCheck (Linting) ---"
	$(SHELLCHECK_BIN) -x $(SCRIPT_NAME)

# functional_test: Runs tests using Bats.
functional_test:
ifeq ($(BATS_BIN),)
	@echo "ERROR: Bats is not installed. Please install it to run functional tests." >&2
	exit 1
endif
	@echo "--- Running Functional Tests (Bats) ---"
	$(BATS_BIN) tests/

# ------------------------------------------------------------------------------
# 4. Utility Targets
# ------------------------------------------------------------------------------

# help: Display help message.
help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  install    : Installs the script and man page to system paths (requires sudo)."
	@echo "  uninstall  : Removes the script and man page (requires sudo)."
	@echo "  clean      : Removes all generated reports and logs (requires sudo)."
	@echo "  test       : Runs linting (ShellCheck) and functional tests (Bats)."
	@echo "  lint       : Only runs ShellCheck."
	@echo "  functional_test: Only runs Bats tests."
	@echo "  help       : Display this help message."
