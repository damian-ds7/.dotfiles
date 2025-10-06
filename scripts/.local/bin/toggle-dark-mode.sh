#!/usr/bin/env sh
set -uo pipefail

THEME_DIR="$HOME/.config/themes"
TMUX_CONF_DIR="$HOME/.config/tmux"
TMUX_THEME_DIR="$TMUX_CONF_DIR/themes"
NIRI_CONF_DIR="$HOME/.config/niri"
ULAUNCHER_SETTINGS="$HOME/.config/ulauncher/settings.json"

get_current_theme() {
    dconf read /org/gnome/desktop/interface/color-scheme
}

switch_to_dark() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
    qs ipc call darkMode setDark
    "$TMUX_THEME_DIR/reset.sh"
    ln -sfn "$THEME_DIR/catppuccin-mocha"  "$THEME_DIR/current"
    sed -i 's/^\([[:space:]]*active-color[[:space:]]\+\)"#[^"]*"/\1"#cba6f7"/' "$NIRI_CONF_DIR/config.kdl"
    sed -i 's/"theme-name": "ulauncher-theme-gnome-light"/"theme-name": "ulauncher-theme-gnome-dark"/' "$ULAUNCHER_SETTINGS"
    systemctl --user try-restart ulauncher
}

switch_to_light() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
    qs ipc call darkMode setLight
    "$TMUX_THEME_DIR/reset.sh"
    ln -sfn "$THEME_DIR/catppuccin-latte"  "$THEME_DIR/current"
    sed -i 's/^\([[:space:]]*active-color[[:space:]]\+\)"#[^"]*"/\1"#8839ef"/' "$NIRI_CONF_DIR/config.kdl"
    sed -i 's/"theme-name": "ulauncher-theme-gnome-dark"/"theme-name": "ulauncher-theme-gnome-light"/' "$ULAUNCHER_SETTINGS"
    systemctl --user try-restart ulauncher
}

if test "$(get_current_theme)" = "'prefer-light'"; then
    switch_to_dark
else
    switch_to_light
fi

systemctl --user try-restart waybar.service
tmux source-file "$TMUX_CONF_DIR/tmux.conf"
systemctl --user try-restart swayosd-server.service
