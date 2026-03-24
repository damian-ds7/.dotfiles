#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo mkdir -p /etc/keyd/
sudo ln -sf "$SCRIPT_DIR/default.conf" /etc/keyd/default.conf
sudo systemctl restart keyd
