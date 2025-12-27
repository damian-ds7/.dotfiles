#!/usr/bin/env zsh

if [[ -n "$NO_OMP" ]]; then
  return 0 2>/dev/null || exit 0
fi

if command -v oh-my-posh >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

if command -v gum >/dev/null 2>&1; then
  gum style \
    --foreground 212 --border-foreground 212 --border rounded \
    --align center --width 50 --margin "1 2" --padding "1 2" \
    "Oh My Posh" \
    "" \
    "Oh My Posh is not installed"

  if ! gum confirm "Install Oh My Posh?"; then
    gum style --foreground 220 "Skipping Oh My Posh installation"
    return 0 2>/dev/null || exit 0
  fi
else
  while true; do
    echo -n "Oh My Posh not found. Do you want to install it? [Y/n]: "
    read -k 1 response
    echo

    case "$response" in
      y|Y|$'\n')
        echo "Proceeding with installation..."
        break
        ;;
      n|N)
        echo "Skipping Oh My Posh installation."
        return 0 2>/dev/null || exit 0
        ;;
      *)
        echo "Invalid input. Please press 'y' or 'n'."
        ;;
    esac
  done
fi

INSTALL_SCRIPT_URL="https://ohmyposh.dev/install.sh"
TEMP_DIR=$(mktemp -d)
INSTALL_SCRIPT="$TEMP_DIR/install.sh"
INSTALL_DIR="$HOME/.local/bin"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

if [[ ! -d "$INSTALL_DIR" ]]; then
  mkdir -p "$INSTALL_DIR"
fi

# Build installation commands
_download_cmd="curl -fsSL \"$INSTALL_SCRIPT_URL\" -o \"$INSTALL_SCRIPT\""
_install_cmd="bash \"$INSTALL_SCRIPT\" -d \"$INSTALL_DIR\""

# Execute with gum spinner or directly
if command -v gum >/dev/null 2>&1; then
  # Use gum spinner for download
  if gum spin --spinner dot --title "Downloading Oh My Posh installer..." -- sh -c "$_download_cmd"; then
    chmod +x "$INSTALL_SCRIPT"

    # Use gum spinner for install
    if gum spin --spinner dot --title "Installing Oh My Posh..." -- sh -c "$_install_cmd"; then
      if command -v oh-my-posh >/dev/null 2>&1; then
        gum style --foreground 212 "Oh My Posh installed successfully!"
        return 0 2>/dev/null || exit 0
      else
        gum style --foreground 196 "Oh My Posh installation failed"
        return 1 2>/dev/null || exit 1
      fi
    else
      gum style --foreground 196 "Installation script failed"
      return 1 2>/dev/null || exit 1
    fi
  else
    gum style --foreground 196 "Failed to download installer"
    return 1 2>/dev/null || exit 1
  fi
else
  # Fallback without gum
  echo "Downloading Oh My Posh installer..."
  if ! sh -c "$_download_cmd"; then
    echo "Error: Failed to download installer" >&2
    return 1 2>/dev/null || exit 1
  fi

  chmod +x "$INSTALL_SCRIPT"
  echo "Installing Oh My Posh..."
  sh -c "$_install_cmd"

  if command -v oh-my-posh >/dev/null 2>&1; then
    echo "Oh My Posh installed successfully!"
    return 0 2>/dev/null || exit 0
  else
    echo "Error: Oh My Posh installation failed" >&2
    return 1 2>/dev/null || exit 1
  fi
fi

unset _download_cmd _install_cmd
