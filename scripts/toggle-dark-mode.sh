#!/usr/bin/env sh
set -euo pipefail

if test "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-light'"; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    ln -sf ~/.tmux/themes/dark.conf ~/.tmux/themes/current-theme.conf
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    ln -sf ~/.tmux/themes/light.conf ~/.tmux/themes/current-theme.conf
fi

tmux source-file ~/.tmux.conf
