#!/usr/bin/env bash

SSH_DIR="$HOME/.ssh"
SSH_CONFIG="$SSH_DIR/config"
SSH_KEY="$SSH_DIR/id_ed25519"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

mkdir -p "$SSH_DIR/s"
chmod 700 "$SSH_DIR/s"

cat > /tmp/ssh_config_new <<'EOF'
Host *
  ServerAliveInterval 60
  ConnectTimeout 10
  AddKeysToAgent yes
  EscapeChar `
  ControlMaster auto
  ControlPersist 72000
  ControlPath ~/.ssh/s/%C

EOF

if [ -f "$SSH_CONFIG" ]; then
  cat "$SSH_CONFIG" >> /tmp/ssh_config_new
fi

mv /tmp/ssh_config_new "$SSH_CONFIG"

chmod 600 "$SSH_CONFIG"
echo "SSH config created at $SSH_CONFIG"

if [[ -f "$SSH_KEY" ]]; then
  echo "SSH key already exists at $SSH_KEY"
else
  echo "Generating ED25519 SSH key..."
  read -p "Enter your email address: " email
  ssh-keygen -t ed25519 -C "$email" -f "$SSH_KEY" -N ""
fi

PUB="$SSH_KEY.pub"
if command -v wl-copy >/dev/null 2>&1; then
  wl-copy < "$PUB" && echo "Public key copied to wl-copy"
elif command -v xclip >/dev/null 2>&1; then
  xclip -selection clipboard < "$PUB" && printf "Public key copied to xclip"
elif command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$PUB" && echo "Public key copied to pbcopy"
else
  echo "Public key available at $PUB"
fi
