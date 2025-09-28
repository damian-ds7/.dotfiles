#!/usr/bin/env sh
set -euo pipefail

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
    "$TMUX_THEME_DIR/reset.sh"
    ln -sfn "$THEME_DIR/catppuccin-mocha"  "$THEME_DIR/current"
    sed -i 's/^\([[:space:]]*active-color[[:space:]]\+\)"#[^"]*"/\1"#cba6f7"/' "$NIRI_CONF_DIR/config.kdl"
#    sed -i 's/"theme-name": "ulauncher-theme-gnome-light"/"theme-name": "ulauncher-theme-gnome-dark"/' "$ULAUNCHER_SETTINGS"
#    systemctl --user restart ulauncher
}

switch_to_light() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
    "$TMUX_THEME_DIR/reset.sh"
    ln -sfn "$THEME_DIR/catppuccin-latte"  "$THEME_DIR/current"
    sed -i 's/^\([[:space:]]*active-color[[:space:]]\+\)"#[^"]*"/\1"#8839ef"/' "$NIRI_CONF_DIR/config.kdl"
#    sed -i 's/"theme-name": "ulauncher-theme-gnome-dark"/"theme-name": "ulauncher-theme-gnome-light"/' "$ULAUNCHER_SETTINGS"
#    systemctl --user restart ulauncher
}

if test "$(get_current_theme)" = "'prefer-light'"; then
    switch_to_dark
else
    switch_to_light
fi

killall waybar && waybar &
tmux source-file "$TMUX_CONF_DIR/tmux.conf"
killall swayosd-server && swayosd-server &
