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

configure_dnf() {
    echo "Configuring DNF options..."
    for setting in \
        "defaultyes=True" \
        "fastestmirror=True" \
        "max_parallel_downloads=10"; do

        if ! grep -q "^$setting" /etc/dnf/dnf.conf; then
            echo "$setting" | sudo tee -a /etc/dnf/dnf.conf > /dev/null
        else
            echo "Already set: $setting"
        fi
    done
}

source install.conf
source utils.sh

setup_code_repo() {
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    dnf check-update
}

install_apps() {
  install_flatpaks "${FLATPAKS[@]}"
  install_packages "${PACKAGES[@]}"
}

setup_zen_browser() {
    echo "Setting up Zen Browser..."

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

setup_dotfiles() {
    echo "Cloning dotfiles repository..."

    while true; do
        if git clone git@github.com:damian-ds7/dotfiles.git ~/.dotfiles; then
            break
        fi

        echo "Failed to clone repository. Likely no SSH key is set up."
        echo "Options:"
        select choice in "Try again" "Skip"; do
            case $choice in
                "Try again")
                    echo "Generate SSH key eg.:"
                    echo "ssh-keygen -t ed25519"
                    echo "After that, return here and select 'Try again'."
                    break
                    ;;
                "Skip")
                    echo "Skipping dotfiles setup."
                    return
                    ;;
            esac
        done
    done

    cd ~/.dotfiles || exit 1
    stow -t ~/ scripts
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
    setup_zen_browser
    setup_dotfiles
    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
}

main
