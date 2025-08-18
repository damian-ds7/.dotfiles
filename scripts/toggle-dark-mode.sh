#!/usr/bin/env sh
set -euo pipefail

TMUX_THEME_DIR="$HOME/.tmux/themes"

get_current_theme() {
    gsettings get org.gnome.desktop.interface color-scheme
}

switch_to_dark() {
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/dark.conf" "$TMUX_THEME_DIR/current-theme.conf"
}

switch_to_light() {
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/light.conf" "$TMUX_THEME_DIR/current-theme.conf"
}

# Main logic
if test "$(get_current_theme)" = "'prefer-light'"; then
    switch_to_dark
else
    switch_to_light
fi

tmux source-file ~/.tmux.conf
