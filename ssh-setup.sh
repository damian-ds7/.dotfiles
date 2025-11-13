#!/usr/bin/env bash

SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_KEY="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

mkdir -p "$SSH_DIR/s"
chmod 700 "$SSH_DIR/s"

cat >"$SSH_CONFIG" <<'EOF'
Host *
  ServerAliveInterval 60
  ConnectTimeout 10
  AddKeysToAgent yes
  EscapeChar `
  ControlMaster auto
  ControlPersist 72000
  ControlPath ~/.ssh/s/%C
EOF

chmod 600 "$SSH_CONFIG"
echo "SSH config created at $SSH_CONFIG"

if [[ -f "$SSH_KEY" ]]; then
  echo "SSH key already exists at $SSH_KEY"
else
  echo "Generating ED25519 SSH key..."
  read -p "Enter your email address: " email
  ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
fi

echo ""
echo "To add this key to GitHub:"
cat ${SSH_KEY}.pub | wl-copy
echo "Key copied to clipboard, add to GitHub"
