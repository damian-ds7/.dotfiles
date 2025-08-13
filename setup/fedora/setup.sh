#!/bin/bash

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

source install.conf
source utils.sh

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

setup_code_repo() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
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

setup_zen_browser() {
    echo "Setting up Zen Browser..."

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

source gnome.conf

gnome_keybinds() {
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

main() {
    update_system
    configure_dnf
    setup_code_repo
    install_apps
    install_web_apps
    setup_zen_browser
    gnome_keybinds
    setup_dotfiles
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
}

main
