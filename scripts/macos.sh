#!/usr/bin/env bash
# =============================================================================
# macos.sh — macOS system defaults for a new machine
# Run once after first login on a new Mac.
# Many changes require a logout/restart to take effect.
#
# Usage: bash scripts/macos.sh
# =============================================================================
set -euo pipefail

GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
log_step() { echo -e "\n${CYAN}${BOLD}▶ $1${RESET}"; }
log_ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }

# ── Keyboard & Input ──────────────────────────────────────────────────────────
log_step "Keyboard"
# Fast key repeat (lower = faster; default 6)
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 14
log_ok "Key repeat: fast"

# Disable press-and-hold for accented characters (enable key repeat in all apps)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
log_ok "Press-and-hold disabled (key repeat works in all apps)"

# Enable full keyboard access for all controls (tab in dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
log_ok "Full keyboard access enabled"

# ── Trackpad & Mouse ─────────────────────────────────────────────────────────
log_step "Trackpad"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
log_ok "Tap to click enabled"

defaults write com.apple.trackpad.scaling -float 1.5
log_ok "Trackpad tracking speed: faster"

# ── Dock ──────────────────────────────────────────────────────────────────────
log_step "Dock"
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3
log_ok "Dock: auto-hide with no delay"

defaults write com.apple.dock tilesize -int 48
log_ok "Dock: icon size 48px"

defaults write com.apple.dock show-recents -bool false
log_ok "Dock: recent apps hidden"

defaults write com.apple.dock minimize-to-application -bool true
log_ok "Dock: minimize into app icon"

# ── Finder ────────────────────────────────────────────────────────────────────
log_step "Finder"
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
log_ok "Show hidden files"

# Show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
log_ok "Show all file extensions"

# Show path bar and status bar
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
log_ok "Path bar + status bar visible"

# List view as default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
log_ok "Default view: List"

# Keep folders on top
defaults write com.apple.finder _FXSortFoldersFirst -bool true
log_ok "Folders sorted first"

# Disable the warning when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
log_ok "Extension change warning disabled"

# New Finder window opens in home directory
defaults write com.apple.finder NewWindowTarget -string "PfHm"
log_ok "New windows open at ~"

# ── Screenshots ───────────────────────────────────────────────────────────────
log_step "Screenshots"
mkdir -p "$HOME/Desktop/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Desktop/Screenshots"
log_ok "Screenshots saved to ~/Desktop/Screenshots"

defaults write com.apple.screencapture type -string "png"
log_ok "Screenshot format: PNG"

defaults write com.apple.screencapture disable-shadow -bool true
log_ok "Window shadows disabled in screenshots"

# ── Menu Bar & System ─────────────────────────────────────────────────────────
log_step "System"
# Show battery percentage
defaults write com.apple.menuextra.battery ShowPercent -bool true
log_ok "Battery percentage shown"

# Show 24-hour time with seconds
defaults write com.apple.menuextra.clock DateFormat -string "EEE HH:mm:ss"
log_ok "24h clock with seconds"

# Disable automatic capitalization and smart quotes/dashes in typing
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
log_ok "Auto-correct / smart punctuation disabled"

# Expand save and print dialogs by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
log_ok "Save & print panels expanded by default"

# ── Activity Monitor ─────────────────────────────────────────────────────────
log_step "Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true
defaults write com.apple.ActivityMonitor ShowCategory -int 0   # All processes
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0
log_ok "Activity Monitor: show all, sort by CPU"

# ── Restart affected apps ─────────────────────────────────────────────────────
log_step "Restarting affected system processes"
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "$app" 2>/dev/null && echo "  ↺ Restarted $app" || true
done

echo -e "\n${GREEN}${BOLD}✓ macOS defaults applied.${RESET}"
echo "  Some changes require a logout or restart to fully take effect."
