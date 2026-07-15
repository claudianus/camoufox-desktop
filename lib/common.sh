#!/usr/bin/env bash
# Shared helpers for camoufox-desktop
# shellcheck shell=bash
set -euo pipefail

CFD_VERSION="${CFD_VERSION:-1.0.0}"
CFD_INSTALL_DIR="${CAMOUFOX_INSTALL_DIR:-}"
CFD_PROFILE_ROOT="${CAMOUFOX_PROFILE_DIR:-$HOME/.camoufox/profiles}"
CFD_PROFILE_NAME="${CAMOUFOX_PROFILE:-default}"
CFD_PROFILE_DIR="$CFD_PROFILE_ROOT/$CFD_PROFILE_NAME"
CFD_LOG_DIR="${CAMOUFOX_LOG_DIR:-$HOME/.camoufox/logs}"
CFD_LOG_FILE="$CFD_LOG_DIR/desktop-launch.log"
CFD_SHARE_DIR="${CAMOUFOX_DESKTOP_HOME:-$HOME/.local/share/camoufox-desktop}"
CFD_BIN_DIR="${CAMOUFOX_BIN_DIR:-$HOME/.local/bin}"
CFD_DEFAULT_URL="${CAMOUFOX_HOMEPAGE:-https://duckduckgo.com}"
CFD_NPM_PKG="${CAMOUFOX_NPM_PKG:-camoufox@latest}"

cfd_log() {
  mkdir -p "$CFD_LOG_DIR"
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >>"$CFD_LOG_FILE" 2>/dev/null || true
}

cfd_info() { printf '==> %s\n' "$*" >&2; }
cfd_warn() { printf 'warn: %s\n' "$*" >&2; }
cfd_die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

cfd_os() {
  case "$(uname -s)" in
    Darwin) echo macos ;;
    Linux)  echo linux ;;
    MINGW*|MSYS*|CYGWIN*) echo windows ;;
    *) echo unknown ;;
  esac
}

cfd_has() { command -v "$1" >/dev/null 2>&1; }

cfd_default_cache() {
  case "$(cfd_os)" in
    macos) printf '%s\n' "$HOME/Library/Caches/camoufox" ;;
    linux) printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}/camoufox" ;;
    *)     printf '%s\n' "$HOME/.cache/camoufox" ;;
  esac
}

cfd_cache_dir() {
  if [[ -n "${CFD_INSTALL_DIR}" ]]; then
    printf '%s\n' "$CFD_INSTALL_DIR"
  elif [[ -n "${CAMOUFOX_INSTALL_DIR:-}" ]]; then
    printf '%s\n' "$CAMOUFOX_INSTALL_DIR"
  else
    cfd_default_cache
  fi
}

cfd_ensure_dirs() {
  mkdir -p "$CFD_PROFILE_DIR" "$CFD_LOG_DIR" "$CFD_SHARE_DIR" "$CFD_BIN_DIR"
}

# Prints: APP|/path/to/Camoufox.app  or  BIN|/path/to/camoufox-bin
cfd_resolve() {
  if [[ -n "${CAMOUFOX_APP_PATH:-}" && -d "${CAMOUFOX_APP_PATH}" ]]; then
    printf 'APP|%s\n' "$CAMOUFOX_APP_PATH"
    return 0
  fi
  if [[ -n "${CAMOUFOX_BINARY_PATH:-}" && -x "${CAMOUFOX_BINARY_PATH}" ]]; then
    printf 'BIN|%s\n' "$CAMOUFOX_BINARY_PATH"
    return 0
  fi

  local cache
  cache="$(cfd_cache_dir)"

  if [[ -x "$cache/Camoufox.app/Contents/MacOS/camoufox" ]]; then
    printf 'APP|%s\n' "$cache/Camoufox.app"
    return 0
  fi
  if [[ -x "$cache/camoufox-bin" ]]; then
    printf 'BIN|%s\n' "$cache/camoufox-bin"
    return 0
  fi
  if [[ -x "$cache/camoufox" ]]; then
    printf 'BIN|%s\n' "$cache/camoufox"
    return 0
  fi
  # nested layouts
  local f
  shopt -s nullglob
  for f in "$cache"/*/Camoufox.app/Contents/MacOS/camoufox "$cache"/Camoufox.app/Contents/MacOS/camoufox; do
    if [[ -x "$f" ]]; then
      shopt -u nullglob
      printf 'APP|%s\n' "$(cd "$(dirname "$f")/../.." && pwd)"
      return 0
    fi
  done
  for f in "$cache"/*/camoufox-bin "$cache"/camoufox-bin; do
    if [[ -x "$f" ]]; then
      shopt -u nullglob
      printf 'BIN|%s\n' "$f"
      return 0
    fi
  done
  shopt -u nullglob
  return 1
}

cfd_ensure_node() {
  if cfd_has node && cfd_has npx; then
    return 0
  fi
  cfd_die "Node.js + npx required to download Camoufox.
Install Node 20+ from https://nodejs.org then re-run install."
}

cfd_install_binary() {
  cfd_ensure_node
  cfd_info "Downloading official Camoufox via ${CFD_NPM_PKG} fetch..."
  # Prefer camoufox CLI; camoufox-js also works as fallback
  if npx --yes "$CFD_NPM_PKG" fetch; then
    return 0
  fi
  cfd_warn "camoufox fetch failed; trying camoufox-js..."
  npx --yes camoufox-js@latest fetch || true
}

cfd_ensure_binary() {
  if cfd_resolve >/dev/null 2>&1; then
    return 0
  fi
  cfd_install_binary
  cfd_resolve >/dev/null 2>&1 \
    || cfd_die "Camoufox binary still missing under $(cfd_cache_dir)"
}

cfd_firefox_args() {
  # Firefox-style args; URLs / extra flags appended by caller
  CFD_ARGS=(
    "-profile"
    "$CFD_PROFILE_DIR"
    "-no-remote"
    "--"
  )
}

cfd_path_hint() {
  case ":${PATH:-}:" in
    *":$CFD_BIN_DIR:"*) return 0 ;;
  esac
  cat <<EOF

Note: $CFD_BIN_DIR is not on your PATH.
Add to ~/.zshrc or ~/.bashrc:

  export PATH="\$HOME/.local/bin:\$PATH"
EOF
}
