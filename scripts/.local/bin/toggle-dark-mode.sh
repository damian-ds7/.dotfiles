#!/usr/bin/env sh
set -euo pipefail

TMUX_CONF_DIR="$HOME/.config/tmux"
TMUX_THEME_DIR="$TMUX_CONF_DIR/themes"
LSD_THEME_DIR="$HOME/.config/lsd"
FUZZEL_THEME_DIR="$HOME/.config/fuzzel/themes"
ULAUNCHER_SETTINGS="$HOME/.config/ulauncher/settings.json"

get_current_theme() {
    gsettings get org.gnome.desktop.interface color-scheme
}

switch_to_dark() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/dark.conf" "$TMUX_THEME_DIR/current-theme.conf"
    ln -sf "$FUZZEL_THEME_DIR/dark.ini" "$FUZZEL_THEME_DIR/current-theme.ini"
    ln -sf  "$LSD_THEME_DIR/dark.yaml" "$LSD_THEME_DIR/colors.yaml"
    sed -i 's/"theme-name": "ulauncher-theme-gnome-light"/"theme-name": "ulauncher-theme-gnome-dark"/' "$ULAUNCHER_SETTINGS"
    systemctl --user restart ulauncher
}

switch_to_light() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/light.conf" "$TMUX_THEME_DIR/current-theme.conf"
    ln -sf "$FUZZEL_THEME_DIR/light.ini" "$FUZZEL_THEME_DIR/current-theme.ini"
    ln -sf  "$LSD_THEME_DIR/light.yaml" "$LSD_THEME_DIR/colors.yaml"
    sed -i 's/"theme-name": "ulauncher-theme-gnome-dark"/"theme-name": "ulauncher-theme-gnome-light"/' "$ULAUNCHER_SETTINGS"
    systemctl --user restart ulauncher
}

if test "$(get_current_theme)" = "'prefer-light'"; then
    switch_to_dark
else
    switch_to_light
fi

tmux source-file "$TMUX_CONF_DIR/tmux.conf"
