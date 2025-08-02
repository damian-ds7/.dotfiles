#!/usr/bin/env sh
set -euo pipefail

if test "$(gsettings get org.gnome.desktop.interface color-scheme)" = "'prefer-light'"; then
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
else
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
fi
