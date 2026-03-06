# =============================================================================
# Makefile — Dotfiles management entry point
# =============================================================================
.DEFAULT_GOAL := help

DOTFILES_DIR := $(shell pwd)
SCRIPTS_DIR  := $(DOTFILES_DIR)/scripts

.PHONY: all install link update check clean help

help: ## Show available targets
	@echo ""
	@echo "  \033[1mDotfiles\033[0m"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'
	@echo ""

install: ## Install all tools + create symlinks
	@bash $(SCRIPTS_DIR)/setup.sh

link: ## Create symlinks only (no installs)
	@bash $(SCRIPTS_DIR)/link.sh

link-force: ## Create symlinks, overwriting existing (no backup)
	@bash $(SCRIPTS_DIR)/link.sh --force

update: ## Pull latest dotfiles + re-link
	@echo "Pulling latest..."
	@git pull --rebase
	@bash $(SCRIPTS_DIR)/link.sh
	@echo "Done. Run 'exec zsh' to reload your shell."

check: ## Validate shell scripts and JSON configs
	@echo "Checking shell scripts..."
	@bash -n $(SCRIPTS_DIR)/setup.sh  && echo "  ✓ setup.sh"
	@bash -n $(SCRIPTS_DIR)/link.sh   && echo "  ✓ link.sh"
	@zsh  -n shell/.zshrc             && echo "  ✓ shell/.zshrc"
	@zsh  -n shell/exports.zsh        && echo "  ✓ shell/exports.zsh"
	@zsh  -n shell/aliases.zsh        && echo "  ✓ shell/aliases.zsh"
	@zsh  -n shell/plugins.zsh        && echo "  ✓ shell/plugins.zsh"
	@zsh  -n shell/keybindings.zsh    && echo "  ✓ shell/keybindings.zsh"
	@node -e "require('fs').readFileSync('config/vscode/settings.json','utf8')" \
		&& echo "  ✓ vscode/settings.json (JSONC)"
	@node -e "require('fs').readFileSync('config/vscode/keybindings.json','utf8')" \
		&& echo "  ✓ vscode/keybindings.json (JSONC)"
	@echo "All checks passed."

clean: ## Remove all symlinks created by link.sh
	@echo "Removing symlinks..."
	@rm -f ~/.zshrc ~/.tmux.conf ~/.gitconfig ~/.gitignore_global
	@rm -f ~/.config/starship.toml
	@rm -f ~/.config/zsh/exports.zsh ~/.config/zsh/aliases.zsh \
	        ~/.config/zsh/plugins.zsh ~/.config/zsh/keybindings.zsh
	@echo "Done. Your original files (if backed up) are at ~/.*.backup.*"
