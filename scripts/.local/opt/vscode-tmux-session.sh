#!/bin/sh
if [ -z "$1" ] || [ "$1" = "\${workspaceFolderBasename}" ]; then
  tmux new-session -A -s "vscode"
else
  tmux new-session -A -s "vscode:$1"
fi
