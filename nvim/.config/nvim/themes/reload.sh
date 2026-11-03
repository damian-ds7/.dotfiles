#!/usr/bin/env bash

# Makes running nvim instances reapply the current theme (see lua/utils/colorscheme.lua)
pkill -USR1 -x nvim || true
