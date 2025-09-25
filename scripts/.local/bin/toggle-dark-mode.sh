#!/usr/bin/env sh
set -euo pipefail

TMUX_CONF_DIR="$HOME/.config/tmux"
TMUX_THEME_DIR="$TMUX_CONF_DIR/themes"
LSD_THEME_DIR="$HOME/.config/lsd"
FUZZEL_THEME_DIR="$HOME/.config/fuzzel/themes"
WAYBAR_CONF_DIR="$HOME/.config/waybar"
NIRI_CONF_DIR="$HOME/.config/niri"
ULAUNCHER_SETTINGS="$HOME/.config/ulauncher/settings.json"

get_current_theme() {
    dconf read /org/gnome/desktop/interface/color-scheme
}

switch_to_dark() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3-dark'"
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/dark.conf" "$TMUX_THEME_DIR/current-theme.conf"
    ln -sf "$FUZZEL_THEME_DIR/dark.ini" "$FUZZEL_THEME_DIR/current-theme.ini"
    ln -sf "$LSD_THEME_DIR/dark.yaml" "$LSD_THEME_DIR/colors.yaml"
    ln -sf "$WAYBAR_CONF_DIR/dark.css" "$WAYBAR_CONF_DIR/theme.css"
    sed -i 's/^\([[:space:]]*active-color[[:space:]]\+\)"#[^"]*"/\1"#cba6f7"/' "$NIRI_CONF_DIR/config.kdl"
#    sed -i 's/"theme-name": "ulauncher-theme-gnome-light"/"theme-name": "ulauncher-theme-gnome-dark"/' "$ULAUNCHER_SETTINGS"
#    systemctl --user restart ulauncher
}

switch_to_light() {
    dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    dconf write /org/gnome/desktop/interface/gtk-theme "'adw-gtk3'"
    "$TMUX_THEME_DIR/reset.sh"
    ln -sf "$TMUX_THEME_DIR/light.conf" "$TMUX_THEME_DIR/current-theme.conf"
    ln -sf "$FUZZEL_THEME_DIR/light.ini" "$FUZZEL_THEME_DIR/current-theme.ini"
    ln -sf "$LSD_THEME_DIR/light.yaml" "$LSD_THEME_DIR/colors.yaml"
    ln -sf "$WAYBAR_CONF_DIR/light.css" "$WAYBAR_CONF_DIR/theme.css"
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
