#!/bin/bash
#
# macOS `defaults` settings.
#
# `run_onchange_` means chezmoi only re-runs this script when its content hash
# changes, so editing this file (uncommenting a suggestion, tweaking a value)
# causes a single re-apply on the next `chezmoi apply`.
#
# To roll back ANY setting below, comment it out here AND run:
#     defaults delete <domain> <key>
# `defaults write` does not auto-revert when the line is removed from this
# script; you have to delete the key (or write the original value back).

set -eufo pipefail

############################################################
# Current customizations (captured 2026-05-04)
############################################################

# --- Keyboard / text input -------------------------------------------------
# Disable press-and-hold accent picker (lets vim hjkl repeat normally)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Show all file extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Disable autocorrect / auto-capitalize / auto-period
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# --- Appearance ------------------------------------------------------------
# Auto-switch light/dark with system schedule
defaults write NSGlobalDomain AppleInterfaceStyleSwitchesAutomatically -bool true

# --- Dock ------------------------------------------------------------------
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock tilesize -int 41
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 128
# Don't reorder spaces by most-recent-use
defaults write com.apple.dock mru-spaces -bool false

# --- Finder ----------------------------------------------------------------
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool false
# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
# Desktop icon visibility
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true
# New Finder windows open to "All My Files"
defaults write com.apple.finder NewWindowTarget -string "PfAF"

# --- Safari ----------------------------------------------------------------
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# --- Trackpad --------------------------------------------------------------
# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# --- Privacy ---------------------------------------------------------------
# No .DS_Store on network shares
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# --- Menu bar clock --------------------------------------------------------
defaults write com.apple.menuextra.clock IsAnalog -bool false
defaults write com.apple.menuextra.clock ShowDate -int 1
defaults write com.apple.menuextra.clock ShowAMPM -bool true


############################################################
# Suggestions — uncomment to try, see header for rollback
############################################################

# --- Faster key repeat (pairs nicely with ApplePressAndHoldEnabled=false) ---
# defaults write NSGlobalDomain KeyRepeat -int 2
# defaults write NSGlobalDomain InitialKeyRepeat -int 15

# --- Disable smart quotes / smart dashes (annoying in code) ----------------
# defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# --- Dock: hide Recents tray ----------------------------------------------
# defaults write com.apple.dock show-recents -bool false

# --- Dock: faster auto-hide animation -------------------------------------
# defaults write com.apple.dock autohide-time-modifier -float 0.15
# defaults write com.apple.dock autohide-delay -float 0

# --- Screenshots: redirect to ~/Pictures/Screenshots, default PNG ----------
# mkdir -p "$HOME/Pictures/Screenshots"
# defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
# defaults write com.apple.screencapture type -string "png"
# defaults write com.apple.screencapture disable-shadow -bool true
# defaults write com.apple.screencapture include-date -bool true

# --- Suppress .DS_Store on USB volumes too --------------------------------
# defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# --- Finder: sort folders before files in list view -----------------------
# defaults write com.apple.finder _FXSortFoldersFirst -bool true

# --- Finder: show full POSIX path in window title -------------------------
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# --- Finder: search current folder by default (not whole Mac) -------------
# defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# --- Save dialogs default to expanded view --------------------------------
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# --- Print dialog defaults to expanded view -------------------------------
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true


############################################################
# Apply changes that need a restart
############################################################
killall Finder Dock SystemUIServer 2>/dev/null || true
