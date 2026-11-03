#!/usr/bin/env bash

# Umbriel doesn't notice the current-theme.toml symlink being replaced, so reload explicitly
[ -n "${UMBRIEL_SOCKET:-}" ] && umbriel msg config-reload >/dev/null
exit 0
