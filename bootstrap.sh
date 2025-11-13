#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0
RUN_SSH=0
MODULES=()

usage() {
  cat <<EOF
Usage: $(basename "$0") [--dry-run] [--ssh] <module> [module...]

Runs GNU stow with --adopt for the given modules and then runs
"git restore ." in the repository root. If --ssh is passed the
script will run the repository's ssh-setup.sh

Options:
  --dry-run    Run stow with --simulate (no changes applied)
  --ssh        Run ssh-setup.sh without prompting
  -h, --help   Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --ssh)
      RUN_SSH=1
      shift
      ;;
    -h|--help)
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

if [[ ${#MODULES[@]} -eq 0 ]]; then
  echo "Error: at least one stow module must be provided (e.g. config scripts)" >&2
  usage
  exit 2
fi

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is not installed or not in PATH. Install it and retry." >&2
  exit 3
fi

STOW_ARGS=(--adopt -v --target "$HOME")
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

if [[ $DRY_RUN -eq 0 ]]; then
  echo "stow completed. Now running 'git restore .' in repo root: $REPO_ROOT"
  if command -v git >/dev/null 2>&1; then
    git -C "$REPO_ROOT" restore . || true
  else
    echo "git not found; skipping git restore." >&2
  fi
else
  echo "Dry-run mode: skipping 'git restore .'"
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
