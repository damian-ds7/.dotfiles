#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_MODULES=(git zsh nvim bat ghostty tmux lsd lazygit themes code yazi)
DRY_RUN=0
RUN_SSH=0
RUN_RESTORE=0
MODULES=()
USE_ALL=0
USE_CONFIG=0
STOW_ACTION=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [MODULE...]
       $(basename "$0") -a|--all [OPTIONS]
       $(basename "$0") -c|--config [OPTIONS]

Stow configuration modules using GNU stow with --adopt.

Arguments:
    MODULE...           One or more modules to stow (required unless -a or -c is used)

Options:
    -a, --all          Stow all available modules in dotfiles directory
    -c, --config       Stow config modules: git, zsh, nvim, bat, ghostty, tmux, lsd, lazygit, themes, code, yazi
    -D, --delete       Unstow modules (remove symlinks)
    -R, --restow       Restow modules (remove then recreate symlinks)
    --dry-run          Run stow with --simulate (no changes applied)
    --restore          Run 'git restore .' after stow completes
    --ssh              Run ssh-setup.sh without prompting
    -h, --help         Show this help message

Note: Either provide at least one MODULE or use -a/--all or -c/--config, but not multiple selection methods.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
  -a | --all)
    USE_ALL=1
    shift
    ;;
  -c | --config)
    USE_CONFIG=1
    shift
    ;;
  -D | --delete)
    STOW_ACTION="-D"
    shift
    ;;
  -R | --restow)
    STOW_ACTION="-R"
    shift
    ;;
  --dry-run)
    DRY_RUN=1
    shift
    ;;
  --restore)
    RUN_RESTORE=1
    shift
    ;;
  --ssh)
    RUN_SSH=1
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  --)
    shift
    break
    ;;
  -*)
    echo "Unknown option: $1" >&2
    usage
    exit 2
    ;;
  *)
    MODULES+=("$1")
    shift
    ;;
  esac
done

if [[ $USE_ALL -eq 1 && $USE_CONFIG -eq 1 ]]; then
  echo "Error: cannot use both --all and --config" >&2
  usage
  exit 2
fi

if [[ $USE_ALL -eq 1 && ${#MODULES[@]} -gt 0 ]]; then
  echo "Error: cannot specify modules when using --all" >&2
  usage
  exit 2
fi

if [[ $USE_CONFIG -eq 1 && ${#MODULES[@]} -gt 0 ]]; then
  echo "Error: cannot specify modules when using --config" >&2
  usage
  exit 2
fi

if [[ $USE_ALL -eq 1 ]]; then
  cd "$REPO_ROOT"
  for dir in */; do
    MODULES+=("${dir%/}")
  done
elif [[ $USE_CONFIG -eq 1 ]]; then
  MODULES=("${CONFIG_MODULES[@]}")
fi

if [[ ${#MODULES[@]} -eq 0 ]]; then
  echo "Error: at least one stow module must be provided" >&2
  usage
  exit 2
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed or not in PATH. Install it and retry." >&2
  exit 3
fi

STOW_ARGS=(-v --target "$HOME")

if [[ -n "$STOW_ACTION" ]]; then
  STOW_ARGS+=("$STOW_ACTION")
else
  STOW_ARGS+=(--adopt)
fi

if [[ $DRY_RUN -eq 1 ]]; then
  STOW_ARGS+=(--simulate)
  echo "Running stow in dry-run mode"
fi

echo "Running: stow ${STOW_ARGS[*]} ${MODULES[*]}"
set -x
stow "${STOW_ARGS[@]}" "${MODULES[@]}"
STOW_EXIT=$?
set +x

if [[ $STOW_EXIT -ne 0 ]]; then
  echo "stow finished with non-zero exit: $STOW_EXIT" >&2
  exit $STOW_EXIT
fi

if [[ $RUN_RESTORE -eq 1 ]]; then
  if [[ $DRY_RUN -eq 0 ]]; then
    echo "Running 'git restore .' in repo root: $REPO_ROOT"
    if command -v git >/dev/null 2>&1; then
      git -C "$REPO_ROOT" restore . || true
    else
      echo "git not found; skipping git restore." >&2
    fi
  else
    echo "Dry-run mode: skipping 'git restore .'"
  fi
fi

SSH_SCRIPT="$REPO_ROOT/ssh-setup.sh"
if [[ $RUN_SSH -eq 1 ]]; then
  if [[ -f "$SSH_SCRIPT" ]]; then
    echo "Running ssh setup script: $SSH_SCRIPT"
    bash "$SSH_SCRIPT" || true
  else
    echo "ssh-setup.sh not found at $SSH_SCRIPT; skipping" >&2
  fi
fi

echo "Bootstrap finished"
exit 0
