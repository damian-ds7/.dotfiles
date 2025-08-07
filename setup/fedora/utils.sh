#!/bin/bash

install_flatpaks() {
    local flatpaks=("$@")
    for app in "${flatpaks[@]}"; do
        echo "Installing $app"
        flatpak install --noninteractive "$app"
    done
}

install_packages() {
    local packages=("$@")
    echo "Installing dnf packages"
    sudo dnf install -y --skip-unavailable "${packages[@]}"
}

# =======================================
# === Gnome related utility functions ===
# =======================================

apply_overrides() {
    local arr=("$@")
    local schema key value

    for item in "${arr[@]}"; do
        read -r schema key value <<< "$item"
        gsettings set "$schema" "$key" "$value"
    done
}

apply_custom_shortcuts() {
    local arr=("$@")
    local base_path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
    local paths=()
    local i=0

    for item in "${arr[@]}"; do
        IFS='|' read -r name cmd binding <<< "$item"
        local path="$base_path/custom$i/"
        local full_path="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:$path"

        gsettings set "$full_path" name "$name"
        gsettings set "$full_path" command "$cmd"
        gsettings set "$full_path" binding "$binding"

        paths+=("'$path'")
        ((i++))
    done

    local joined_paths
    IFS=,
    joined_paths="${paths[*]}"
    unset IFS

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "[$joined_paths]"
}
