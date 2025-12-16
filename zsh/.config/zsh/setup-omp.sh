#!/usr/bin/env zsh

if [[ -n "$NO_OMP" ]]; then
  return 0 2>/dev/null || exit 0
fi

if command -v oh-my-posh >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

echo "Oh My Posh not found. Installing..."

INSTALL_SCRIPT_URL="https://ohmyposh.dev/install.sh"
EXPECTED_SHA256="2e03d4e90e0d390f28ce739fbd90ed2a14f1e7b48bf693d538bede460b547560"
TEMP_DIR=$(mktemp -d)
INSTALL_SCRIPT="$TEMP_DIR/install.sh"
INSTALL_DIR="$HOME/.local/bin"

cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Downloading Oh My Posh installer..."
if ! curl -fsSL "$INSTALL_SCRIPT_URL" -o "$INSTALL_SCRIPT"; then
  echo "Error: Failed to download installer" >&2
  return 1 2>/dev/null || exit 1
fi

if ! echo "$EXPECTED_SHA256  $INSTALL_SCRIPT" | sha256sum -c --quiet; then
  echo "Error: Checksum verification failed!" >&2
  echo "Expected: $EXPECTED_SHA256" >&2
  return 1 2>/dev/null || exit 1
fi

if [[ ! -d "$INSTALL_DIR" ]]; then
  echo "Creating installation directory: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
fi

chmod +x "$INSTALL_SCRIPT"
bash "$INSTALL_SCRIPT" -d "$INSTALL_DIR"

if command -v oh-my-posh >/dev/null 2>&1; then
  echo "Oh My Posh installed successfully!"
  return 0 2>/dev/null || exit 0
else
  echo "Error: Oh My Posh installation failed" >&2
  return 1 2>/dev/null || exit 1
fi
