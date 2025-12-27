#!/usr/bin/env zsh

if [[ -n "$NO_FZF" ]]; then
  return 0 2>/dev/null || exit 0
fi

if command -v fzf >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

_detect_arch() {
  local arch="$(uname -m)"
  case "$arch" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    armv7l) echo "armv7" ;;
    *) echo "unknown" ;;
  esac
}

_detect_os() {
  local os="$(uname -s | tr '[:upper:]' '[:lower:]')"
  case "$os" in
    linux*) echo "linux" ;;
    darwin*) echo "darwin" ;;
    *) echo "unknown" ;;
  esac
}

FZF_OS="$(_detect_os)"
FZF_ARCH="$(_detect_arch)"

if [[ "$FZF_OS" == "unknown" || "$FZF_ARCH" == "unknown" ]]; then
  echo "Unsupported platform: $FZF_OS $FZF_ARCH"
  return 1 2>/dev/null || exit 1
fi

if command -v gum >/dev/null 2>&1; then
  gum style \
    --foreground 212 --border-foreground 212 --border rounded \
    --align center --width 50 --margin "1 2" --padding "1 2" \
    "fzf" \
    "" \
    "fzf is not installed"

  if ! gum confirm "Install fzf?"; then
    gum style --foreground 220 "Skipping fzf installation"
    return 0 2>/dev/null || exit 0
  fi
else
  while true; do
    echo -n "fzf not found. Do you want to install it? [Y/n]: "
    read -k 1 response
    echo

    case "$response" in
      y|Y|$'\n')
        echo "Proceeding with installation..."
        break
        ;;
      n|N)
        echo "Skipping fzf installation."
        return 0 2>/dev/null || exit 0
        ;;
      *)
        echo "Invalid input. Please press 'y' or 'n'."
        ;;
    esac
  done
fi

FZF_VERSION=$(curl -s https://api.github.com/repos/junegunn/fzf/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/' 2>/dev/null)

if [[ -z "$FZF_VERSION" ]]; then
  echo "Error: Failed to fetch latest fzf version" >&2
  return 1 2>/dev/null || exit 1
fi

FZF_URL="https://github.com/junegunn/fzf/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION#v}-${FZF_OS}_${FZF_ARCH}.tar.gz"
TEMP_DIR=$(mktemp -d)
INSTALL_DIR="$HOME/.local/bin"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

if [[ ! -d "$INSTALL_DIR" ]]; then
  mkdir -p "$INSTALL_DIR"
fi

_download_cmd="curl -fsSL \"$FZF_URL\" -o \"$TEMP_DIR/fzf.tar.gz\""
_extract_cmd="tar -xzf \"$TEMP_DIR/fzf.tar.gz\" -C \"$TEMP_DIR\""
_install_cmd="mv \"$TEMP_DIR/fzf\" \"$INSTALL_DIR/fzf\" && chmod +x \"$INSTALL_DIR/fzf\""

if command -v gum >/dev/null 2>&1; then
  if gum spin --spinner dot --title "Downloading fzf ${FZF_VERSION}..." -- sh -c "$_download_cmd"; then
    if gum spin --spinner dot --title "Installing fzf..." -- sh -c "$_extract_cmd && $_install_cmd"; then
      if command -v fzf >/dev/null 2>&1; then
        gum style --foreground 212 "fzf installed successfully!"
        return 0 2>/dev/null || exit 0
      else
        gum style --foreground 196 "fzf installation failed"
        return 1 2>/dev/null || exit 1
      fi
    else
      gum style --foreground 196 "Installation failed"
      return 1 2>/dev/null || exit 1
    fi
  else
    gum style --foreground 196 "Failed to download fzf"
    return 1 2>/dev/null || exit 1
  fi
else
  echo "Downloading fzf ${FZF_VERSION}..."
  if ! sh -c "$_download_cmd"; then
    echo "Error: Failed to download fzf" >&2
    return 1 2>/dev/null || exit 1
  fi

  echo "Installing fzf..."
  sh -c "$_extract_cmd && $_install_cmd"

  if command -v fzf >/dev/null 2>&1; then
    echo "fzf installed successfully!"
    return 0 2>/dev/null || exit 0
  else
    echo "Error: fzf installation failed" >&2
    return 1 2>/dev/null || exit 1
  fi
fi

unset _download_cmd _extract_cmd _install_cmd
