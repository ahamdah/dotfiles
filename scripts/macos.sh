#!/usr/bin/env bash
# =============================================================================
# macos.sh — macOS system defaults for a new machine
# Run once after first login on a new Mac.
# Many changes require a logout/restart to take effect.
#
# Usage: bash scripts/macos.sh
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
log_step() { echo -e "\n${CYAN}${BOLD}▶ $1${RESET}"; }
log_ok()   { echo -e "  ${GREEN}✓${RESET} $1"; }

# ── Keyboard & Input ──────────────────────────────────────────────────────────
log_step "Keyboard"
# Fast key repeat (lower = faster; default 6)
defaults write NSGlobalDomain KeyRepeat -int 6
defaults write NSGlobalDomain InitialKeyRepeat -int 12
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

defaults write -g com.apple.trackpad.scaling -float 1.5
log_ok "Trackpad tracking speed: faster"

# ── Dock ──────────────────────────────────────────────────────────────────────
log_step "Dock"
defaults write com.apple.dock autohide -bool false
log_ok "Dock: visible (not auto-hidden)"

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
# (Battery percentage moved to Control Center in Big Sur — set it in
#  System Settings → Control Center → Battery; the old defaults key is dead.)

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

# ── Default Applications ──────────────────────────────────────────────────────
# Xcode, TextEdit and Safari claim most developer file types out of the box.
# With no explicit handler set, LaunchServices arbitrates and Xcode usually
# wins — so pin every text / config / source format to VS Code.
if command -v duti >/dev/null 2>&1 && [[ -d "/Applications/Visual Studio Code.app" ]]; then
  log_step "Default applications"
  VSCODE_ID="com.microsoft.VSCode"

  # Content types (UTIs). Anything that resolves to one of these is covered by
  # the type binding alone; `all` claims the viewer, editor and shell roles.
  vscode_utis=(
    public.plain-text
    public.utf8-plain-text
    public.source-code
    public.script
    public.shell-script
    public.json
    public.yaml
    public.xml
    public.comma-separated-values-text
    public.tab-separated-values-text
    public.delimited-values-text
    net.daringfireball.markdown
    org.tug.tex   # .tex
  )
  for uti in "${vscode_utis[@]}"; do
    duti -s "$VSCODE_ID" "$uti" all 2>/dev/null || true
  done

  # Extensions. Most of these resolve to dynamic UTIs (dyn.ah62d4…) that the
  # content-type bindings above don't cover, so bind them by suffix too.
  vscode_exts=(
    # data / config
    json jsonc json5 jsonl ndjson geojson yaml yml toml ini cfg conf env
    properties xml xsd xsl plist csv tsv lock
    # docs / plain text
    md markdown mdown mkd mdx rst adoc asciidoc txt text log
    # javascript / typescript / web
    js jsx mjs cjs ts tsx vue svelte astro css scss sass less
    # other languages
    py pyi rb go rs java kt kts swift scala clj cljs c h m mm cpp cc cxx hpp
    cs php pl lua sh bash zsh fish ps1 bat r jl dart ex exs erl hs vim
    # build / infra / misc
    sql graphql gql proto tf tfvars hcl gradle groovy cmake mk mak diff patch
  )
  for ext in "${vscode_exts[@]}"; do
    duti -s "$VSCODE_ID" ".$ext" all 2>/dev/null || true
  done
  log_ok "JSON/YAML/Markdown + ${#vscode_exts[@]} source & config extensions open in VS Code"
  # Note: .html/.htm are deliberately left with the browser. To hand them to
  # VS Code too: duti -s com.microsoft.VSCode .html all

  # NB: do NOT run `lsregister -kill -r` here — rebuilding the LaunchServices
  # database right after writing these bindings drops them. duti's changes
  # take effect immediately on their own.
fi

# ── iTerm2 ────────────────────────────────────────────────────────────────────
if [[ -d "/Applications/iTerm.app" ]]; then
  log_step "iTerm2"
  # The Gruvbox Dark dynamic profile (config/iterm2/DynamicProfiles/gruvbox.json,
  # symlinked by link.sh) ships with a fixed Guid — point new windows at it.
  defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "4EE71605-3A49-42C3-A7F8-5E6B31E5838D"
  log_ok "Default profile: Gruvbox Dark"

  # Load ALL preferences (General settings, Key Mappings, etc.) from the repo
  # instead of ~/Library/Preferences, so they're version-controlled and follow
  # you to a new machine. iTerm2 auto-exports changes back to this file on quit
  # (SavePrefsMode 0 = OnQuit), so editing settings in the GUI keeps it in sync.
  defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/config/iterm2/preferences"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile_selection -int 0
  defaults write com.googlecode.iterm2 NoSyncNeverRemindPrefsChangesLostForFile -bool true
  log_ok "Preferences loaded from config/iterm2/preferences/ (restart iTerm2 to apply)"
fi

# ── Restart affected apps ─────────────────────────────────────────────────────
log_step "Restarting affected system processes"
for app in "Dock" "Finder" "SystemUIServer"; do
  killall "$app" 2>/dev/null && echo "  ↺ Restarted $app" || true
done

echo -e "\n${GREEN}${BOLD}✓ macOS defaults applied.${RESET}"
echo "  Some changes require a logout or restart to fully take effect."
