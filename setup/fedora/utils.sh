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
