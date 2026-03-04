#!/usr/bin/env bash

if [ -f "$HOME/.env" ]; then
    . "$HOME/.env"
fi

if [ -f "$HOME/.config/shell/aliases.sh" ]; then
    . "$HOME/.config/shell/aliases.sh"
fi
