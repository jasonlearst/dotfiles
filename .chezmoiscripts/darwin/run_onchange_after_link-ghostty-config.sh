#!/bin/bash
#
# Symlink Ghostty's macOS-native config path to the chezmoi-managed
# ~/.config/ghostty/config so the GUI's "Open Configuration" menu and
# any in-app edits write through to the source-of-truth.
#
# Ghostty on macOS reads ~/Library/Application Support/com.mitchellh.ghostty/config
# first (with priority over ~/.config/ghostty/config), so without this
# symlink the chezmoi-tracked config is effectively ignored.
#
# Idempotent: returns early if the symlink already points to the right
# target. If a real file already exists there, it is preserved as
# `config.pre-chezmoi` instead of being overwritten.

set -eufo pipefail

target="$HOME/.config/ghostty/config"
link="$HOME/Library/Application Support/com.mitchellh.ghostty/config"

if [ -L "$link" ] && [ "$(readlink "$link")" = "$target" ]; then
    exit 0
fi

mkdir -p "$(dirname "$link")"

if [ -e "$link" ] && [ ! -L "$link" ]; then
    backup="$link.pre-chezmoi.$(date +%s)"
    echo "Existing Ghostty Library config backed up to $backup"
    mv "$link" "$backup"
fi

ln -sf "$target" "$link"
echo "Linked $link -> $target"
