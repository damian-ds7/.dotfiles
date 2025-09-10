#!/usr/bin/env sh
set -euo pipefail

TMUX_THEME_DIR="$HOME/.tmux/themes"
LSD_THEME_DIR="$HOME/.config/lsd"
ULAUNCHER_SETTINGS="$HOME/.config/ulauncher/settings.json"

get_current_theme() {
    gsettings get org.gnome.desktop.interface color-scheme
}

switch_to_dark() {
    gsettings set org.gnome.desktop.interface color-scheme prefer-dark
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/dark.conf" "$TMUX_THEME_DIR/current-theme.conf"
    ln -sf  "$LSD_THEME_DIR/dark.yaml" "$LSD_THEME_DIR/colors.yaml"
    ~/.local/bin/vicinae vicinae://theme/set/vicinae-dark
    #sed -i 's/"theme-name": "ulauncher-theme-gnome-light"/"theme-name": "ulauncher-theme-gnome-dark"/' "$ULAUNCHER_SETTINGS"
    #systemctl --user restart ulauncher
}

switch_to_light() {
    gsettings set org.gnome.desktop.interface color-scheme prefer-light
    gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/light.conf" "$TMUX_THEME_DIR/current-theme.conf"
    ln -sf  "$LSD_THEME_DIR/light.yaml" "$LSD_THEME_DIR/colors.yaml"
    ~/.local/bin/vicinae vicinae://theme/set/vicinae-light
    #sed -i 's/"theme-name": "ulauncher-theme-gnome-dark"/"theme-name": "ulauncher-theme-gnome-light"/' "$ULAUNCHER_SETTINGS"
    #systemctl --user restart ulauncher
}

if test "$(get_current_theme)" = "'prefer-light'"; then
    switch_to_dark
else
    switch_to_light
fi

tmux source-file ~/.tmux.conf
