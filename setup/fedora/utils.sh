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

create_web_app() {
  if [ "$#" -ne 3 ]; then
    return 0
  fi

  APP_NAME="$1"
  APP_URL="$2"
  ICON_URL="$3"

  if [[ -z "$APP_NAME" || -z "$APP_URL" || -z "$ICON_URL" ]]; then
    echo "You must set app name, app URL, and icon URL!"
    return 1
  fi

  ICON_DIR="$HOME/.local/share/applications/icons"
  DESKTOP_FILE="$HOME/.local/share/applications/$APP_NAME.desktop"
  ICON_PATH="$ICON_DIR/$APP_NAME.png"

  mkdir -p "$ICON_DIR"

  if ! curl -sL -o "$ICON_PATH" "$ICON_URL"; then
    echo "Error: Failed to download icon."
    return 1
  fi

  cat >"$DESKTOP_FILE" <<EOF
[Desktop Entry]
Version=1.0
Name=$APP_NAME
Comment=$APP_NAME
Exec=chromium --new-window --app="$APP_URL" --name="$APP_NAME" --class="$APP_NAME"
Terminal=false
Type=Application
Icon=$ICON_PATH
StartupNotify=true
EOF

  chmod +x "$DESKTOP_FILE"
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
