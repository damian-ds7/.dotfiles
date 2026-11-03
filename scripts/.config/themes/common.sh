# Shared helpers for the theme scripts, sourced by them.
# State lives in $THEMES_DIR/{scheme,mode}; theme-apply --hook syncs it with noctalia.

source "$(readlink -f "$HOME/.profile")" 2>/dev/null || true

THEMES_DIR="$HOME/.config/themes"
THEME_BIN="$HOME/.local/bin"

DEFAULT_SCHEME="catppuccin"
DEFAULT_MODE="dark"

# Generated variant dir (<app>/themes/noctalia/), also the scheme for unlisted palettes
NOCTALIA_SCHEME="noctalia"

# scheme -> noctalia palette ("<source> <name>"). Community ids are the file names in
# ~/.local/state/noctalia/community-palettes/.
declare -A SCHEMES=(
  [catppuccin]="builtin Catppuccin"
  [dracula]="builtin Dracula"
  [eldritch]="builtin Eldritch"
  [gruvbox]="builtin Gruvbox"
  [kanagawa]="builtin Kanagawa"
  [nord]="builtin Nord"
  [rose-pine]="builtin Rosé Pine"
  [tokyo-night]="builtin Tokyo-Night"

  [monochrome]="community Monochrome"

  [vague]="custom Vague"
)

# Schemes selectable without noctalia, every app has native themes for them
NATIVE_SCHEMES=("catppuccin" "rose-pine" "vague")

available_schemes() {
  if noctalia_running; then
    printf '%s\n' "${!SCHEMES[@]}"
  else
    printf '%s\n' "${NATIVE_SCHEMES[@]}"
  fi | sort
}

list_schemes() {
  available_schemes | sed 's/^/- /'
}

is_scheme() {
  [[ -n $1 ]] || return 1

  if noctalia_running; then
    [[ -v SCHEMES[$1] ]]
    return
  fi

  local scheme
  for scheme in "${NATIVE_SCHEMES[@]}"; do
    [[ $scheme == "$1" ]] && return 0
  done
  return 1
}

is_mode() { [[ $1 == dark || $1 == light ]]; }

read_state() { # <scheme|mode> <default>
  local value=""
  read -r value 2>/dev/null <"$THEMES_DIR/$1"
  echo "${value:-$2}"
}

write_state() { # <scheme|mode> <value>
  mkdir -p "$THEMES_DIR"
  echo "$2" >"$THEMES_DIR/$1"
}

noctalia_msg() {
  noctalia msg "$@" 2>/dev/null
}

noctalia_running() {
  if [[ -z ${NOCTALIA_RUNNING:-} ]]; then
    NOCTALIA_RUNNING=0
    noctalia_msg theme-mode-get >/dev/null && NOCTALIA_RUNNING=1
  fi
  ((NOCTALIA_RUNNING))
}

# Maps a noctalia palette back to its scheme, unlisted ones (wallpaper, community, custom)
# are the noctalia scheme
scheme_from_palette() { # <source name>
  local scheme
  for scheme in "${!SCHEMES[@]}"; do
    if [[ ${SCHEMES[$scheme]} == "$1" ]]; then
      echo "$scheme"
      return
    fi
  done
  echo "$NOCTALIA_SCHEME"
}

current_mode() {
  read_state mode "$DEFAULT_MODE"
}
