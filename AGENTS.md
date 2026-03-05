# AGENTS.md - Development Environment Configuration

This repository contains personal dotfiles for managing development environment configuration across Windows WSL/Ubuntu, including shell configuration, VS Code settings, and Docker setup.

## Repository Structure

```
.
├── shell/                  # Shell configurations
│   ├── .zshrc             # Zsh shell configuration
│   └── .tmux.conf        # Tmux configuration
├── config/                # Editor/IDE configurations
│   └── vscode/           # VS Code settings
│       ├── settings.json
│       ├── keybindings.json
│       └── extensions.json
├── scripts/               # Setup and automation scripts
│   └── setup.sh          # Main setup script
├── Dockerfile            # Development container (Ubuntu 22.04)
├── instal.sh             # Initial setup script for Ubuntu/WSL
├── README.md             # Documentation
├── windowsTerminalSetting.md  # Windows Terminal configuration
└── script.ps1            # PowerShell scripts
```

## Build/Lint/Test Commands

This is a **configuration repository**, not a compiled project. There are no traditional build commands.

### Running Setup Script

```bash
# Run the setup script to install everything
./scripts/setup.sh

# Or in Docker
docker build -t dotfiles-dev .
docker run --rm dotfiles-dev
```

### Shell Script Validation

For shell scripts in `scripts/` and `shell/`:

```bash
# Check shell script syntax
bash -n scripts/setup.sh

# Lint shell scripts
shellcheck scripts/setup.sh
```

### VS Code Configuration

- Settings are in `config/vscode/settings.json`
- Keybindings are in `config/vscode/keybindings.json`
- Extensions are listed in `config/vscode/extensions.json`

---

## Code Style Guidelines

### General Principles

1. **Configuration over code** - This repo stores configuration, not application logic
2. **Keep it modular** - Group related settings together
3. **Document unusual settings** - Add comments for non-obvious configurations

### Shell Scripts (.zshrc, setup.sh)

- Use **2 spaces** for indentation
- Use **lowercase** with underscores for variable names: `my_var="value"`
- Use UPPERCASE for environment variables: `export PATH="$HOME/bin:$PATH"`
- Always quote variables containing paths: `"$HOME/.oh-my-zsh"`
- Use `$(command)` for command substitution (not backticks)
- Add spaces around `=` in conditionals: `if [[ $var == "value" ]]`
- Use `[[ ]]` for tests (not `[ ]`)
- Add semicolons for one-liners: `alias n="nvim";`

### Example (from shell/.zshrc)

```zsh
# Good
export PATH="$HOME/.local/bin:$PATH"
alias n="nvim"

# Bad
export PATH=$HOME/.local/bin:$PATH
alias n="nvim"
```

### Functions

```zsh
# Function definition style
function_name() {
  local var="$1"
  if [[ -z "$var" ]]; then
    return 1
  fi
  echo "$var"
}
```

### Zsh-Specific Patterns

- Use `zstyle` for Oh-My-Zsh configuration management
- Define keybindings with `bindkey`
- Use ZLE widgets for custom shell behavior
- Plugins go in the `plugins=()` array, one per line

### Tmux Configuration

- Prefix key: `Ctrl+a` (instead of default `Ctrl+b`)
- Enable mouse mode
- Use TPM plugins for plugin management
- Configure panes with current working directory

### JSON (VS Code Settings)

- Use **2 spaces** for indentation
- Always include trailing commas except for last item
- Sort keys alphabetically within groups
- Group related settings under shared keys

### Dockerfile

- Use **Ubuntu 22.04** as base image
- Keep instructions minimal
- Place COPY last (for better caching)

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Aliases | Short, memorable | `alias n="nvim"` |
| Functions | snake_case | `r-delregion()` |
| Environment vars | UPPER_SNAKE_CASE | `ZSH="$HOME/.oh-my-zsh"` |
| Local variables | snake_case | `local widget_name="$1"` |
| Files | kebab-case or descriptive | `setup.sh`, `windowsTerminalSetting.md` |

### Error Handling

- Shell scripts: Use `set -e` for strict error handling if needed
- Commands ending with `;` or `\` for continuation
- Check return codes for critical operations

### Comments

- Use comments to explain non-obvious configurations
- Document keybindings and their purposes
- Reference external documentation where helpful

```zsh
# Example comments style
# Bind Ctrl+H to backward-kill-word
bindkey '^H' backward-kill-word
```

### Import Order (for shell/.zshrc)

1. PATH and environment variables
2. Theme configuration
3. Oh-My-Zsh settings
4. Plugin list
5. Source Oh-My-Zsh
6. User configuration
7. Aliases
8. Keybindings
9. Custom functions

---

## Editor Configuration

The VS Code settings use:
- **Font**: Cascadia Code, 20px
- **Theme**: Vim Dark Medium
- **Format on save**: Enabled
- **Vim mode**: Enabled with system clipboard

---

## Additional Notes

- This configuration is optimized for **WSL (Windows Subsystem for Linux)** / Ubuntu
- The `shell/.zshrc` includes custom ZLE widgets for shift-selection behavior
- Some settings are Windows-specific (e.g., `explorer.exe`)
- Custom YAML tags are defined for AWS CloudFormation support
- Tmux is configured with TPM plugins (tpm, sensible, resurrect, continuum)
- Run `prefix + I` (Ctrl+a then I) in tmux to install plugins
