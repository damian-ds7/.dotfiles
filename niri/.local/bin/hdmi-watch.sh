#!/usr/bin/env bash
# Turns the HDMI output on/off in niri based on the monitor's real power state.
# Polls only while the monitor is on (power-off sends no hotplug event);
# while it's off, waits idle for a hotplug event (power-on does send one).

OUT="HDMI-A-1"
BUS=5 # i2c bus from: ddcutil detect
INTERVAL=10
state=""

if ! niri msg outputs 2>/dev/null | grep -qF "($OUT)"; then
  echo "hdmi-watch: $OUT not found in niri, exiting" >&2
  exit 0
fi

alive() {
  ddcutil --bus "$BUS" getvcp d6 2>/dev/null | grep -q 'sl=0x01'
}

set_state() {
  [ "$state" = "$1" ] && return
  niri msg output "$OUT" "$1"
  state="$1"
}

check() {
  if alive; then set_state on; else set_state off; fi
}

check

udevadm monitor --udev --subsystem-match=drm | while true; do
  if [ "$state" = "on" ]; then
    # monitor is on: poll, because power-off sends no event
    if read -r -t "$INTERVAL" line; then
      [[ $line == UDEV* ]] || continue
      sleep 1
    fi
  else
    # monitor is off: wait idle for a hotplug event
    read -r line || break
    [[ $line == UDEV* ]] || continue
    sleep 1
  fi
  check
done
