#!/bin/bash

source install.conf
source gnome.conf
source utils.sh

BINDINGS_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--bindings-only)
            BINDINGS_ONLY=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -b, --bindings-only    Only setup GNOME keybindings"
            echo "  -h, --help            Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

update_system() {
    echo "Checking for system updates..."
    dnf check-update > /tmp/dnf_check 2>/dev/null
    code=$?

    if [[ $code -eq 1 ]]; then
        echo "Failed to check for updates."
    elif [[ $code -eq 100 ]]; then
        echo "Updates available. Running full update..."
        sudo dnf update -y

        echo "System update complete."
        read -p "Reboot now? [y/N]: " choice
        case "$choice" in
            y|Y ) reboot ;;
            * ) echo "Continuing without reboot." ;;
        esac
    else
        echo "System is already up to date."
    fi
}

remove_default_apps() {
    remove_packages "${REMOVE_PACKAGES[@]}"
    remove_groups "${REMOVE_GROUPS[@]}"
}

configure_dnf() {
    echo "Configuring DNF options..."

    for setting in ${DNF_SETTINGS[@]}; do
        [[ -z $setting || $setting =~ ^# ]] && continue
        if ! grep -q "^$setting" /etc/dnf/dnf.conf; then
            echo $setting | sudo tee -a /etc/dnf/dnf.conf > /dev/null
        else
            echo "Already set: $setting"
        fi
    done
}

setup_repos() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

    sudo dnf copr enable -y dejan/lazygit

    dnf check-update
}

install_apps() {
  install_flatpaks "${FLATPAKS[@]}"
  install_packages "${PACKAGES[@]}"
}

install_web_apps() {
  for app in "${WEBAPPS[@]}"; do
    IFS='|' read -r APP_NAME APP_URL ICON_URL <<< "$app"
    echo "Installing $APP_NAME web app"
    create_web_app "$APP_NAME" "$APP_URL" "$ICON_URL"
  done
}

install_zen_browser() {
    echo "Installing Zen Browser..."

    if [[ -d "$HOME/.local/opt/zen" ]]; then
        echo "Zen Browser is already installed at $HOME/.local/opt/zen"
        return
    fi

    curl -L -o /tmp/zen.linux-x86_64.tar.xz https://github.com/zen-browser/desktop/releases/latest/download/zen.linux-x86_64.tar.xz
    tar -xf /tmp/zen.linux-x86_64.tar.xz -C /tmp

    mkdir -p ~/.local/opt
    mv /tmp/zen ~/.local/opt/

    mkdir -p ~/.local/bin
    ln -sf ~/.local/opt/zen/zen ~/.local/bin/zen

    mkdir -p ~/.local/share/applications
    curl -Lo ~/.local/share/applications/zen.desktop https://raw.githubusercontent.com/zen-browser/desktop/1bca2529790304822411b403d3971a1f23ab8d49/build/AppDir/zen.desktop

    sed -i 's|^Icon=zen$|Icon=/home/damian/.local/opt/zen/browser/chrome/icons/default/default128.png|' ~/.local/share/applications/zen.desktop
    sed -i 's|^Exec=zen|Exec=/home/damian/.local/opt/zen/zen|' ~/.local/share/applications/zen.desktop
}

setup_gnome_keybinds() {
    echo "Setting up GNOME keybinding"
    echo "Overriding system keybindings"
    apply_overrides "${GNOME_OVERRIDES[@]}"
    echo "Adding custom keybindings"
    apply_custom_shortcuts "${GNOME_CUSTOM_SHORTCUTS[@]}"
}

setup_dotfiles() {
    cd ~/.dotfiles || exit 1
    stow -t ~/.local/bin scripts
    stow -t ~/ home --adopt
    git restore .

    mkdir -p ~/.ssh/s
    chmod 700 ~/.ssh/s
}

setup_nautilus() {
    # Open in any terminal
    sudo dnf copr enable monkeygold/nautilus-open-any-terminal
    sudo dnf install nautilus-open-any-terminal
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal use-generic-terminal-name true
    gsettings set com.github.stunkymonkey.nautilus-open-any-terminal terminal blackbox
}

main() {
    if [[ "$BINDINGS_ONLY" == true ]]; then
        echo "Running in bindings-only mode..."
        setup_gnome_keybinds
        echo "GNOME keybindings setup complete."
        exit 0
    fi

    update_system
    remove_default_apps
    configure_dnf
    setup_code_repo
    install_apps
    install_web_apps
    # install_zen_browser
    setup_gnome_keybinds
    setup_dotfiles
    setup_nautilus
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
}

main
