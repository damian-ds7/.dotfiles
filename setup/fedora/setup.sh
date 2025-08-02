#!/bin/bash

update_system() {
    echo "Checking for system updates..."
    if ! dnf check-update > /tmp/dnf_check 2>/dev/null; then
        echo "Failed to check for updates."
    else
        if grep -q -v "Repositories loaded." /tmp/dnf_check; then
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
    fi
}

configure_dnf() {
    echo "Configuring DNF options..."
    sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOF
defaultyes=True
fastestmirror=True
max_parallel_downloads=10
EOF
}

install_flatpaks() {
    flatpak install -y \
        com.mattjakeman.ExtensionManager \
        io.github.vikdevelop.SaveDesktop \
        page.tesk.Refine
}

install_packages() {
    sudo dnf install -y \
        zsh \
        blackbox-terminal \
        bat \
        lsd \
        tldr \
        code \
        ulauncher
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
}

setup_dotfiles() {
    echo "Cloning dotfiles repository..."

    while true; do
        if git clone git@github.com:damian-ds7/dotfiles.git ~/.dotfiles; then
            break  # Success, move on
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
    install_flatpaks
    install_packages
    setup_zen_browser
    setup_dotfiles

    echo "Changing default shell to zsh..."
    chsh -s $(which zsh)
}

main

