#!/usr/bin/env bash
# @vicinae.schemaVersion 1
# @vicinae.title Battery threshold
# @vicinae.icon icons/battery-threshold.png
# @vicinae.mode silent
# @vicinae.argument1 { "type": "text", "placeholder": "threshold", "optional": true }
# @vicinae.description Toggle or set battery charge threshold.
# @vicinae.keywords ["battery", "threshold", "power"]

if [ -z "${1-}" ]; then
  qs ipc call plugin:battery-threshold togglePanel
  exit 0
fi

if [ "$#" -eq 1 ]; then
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    qs ipc call plugin:battery-threshold set "$1"
    echo "Threshold set to $1"
    exit 0
  fi

  echo "Threshold must be a number." >&2
  exit 1
fi

echo "Usage: battery-threshold [number]" >&2
exit 1
