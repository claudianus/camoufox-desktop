#!/usr/bin/env bash
# Linux desktop entry + CLI for camoufox-desktop
# shellcheck shell=bash

cfd_linux_binary() {
  local line kind path
  line="$(cfd_resolve)" || return 1
  kind="${line%%|*}"
  path="${line#*|}"
  if [[ "$kind" == "APP" ]]; then
    path="$path/Contents/MacOS/camoufox"
  fi
  [[ -x "$path" ]] || return 1
  printf '%s\n' "$path"
}

cfd_linux_install_launcher() {
  local launcher="$CFD_SHARE_DIR/launch-camoufox.sh"
  mkdir -p "$CFD_SHARE_DIR" "$HOME/.local/share/applications" "$CFD_BIN_DIR"

  cat >"$launcher" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:/usr/local/bin:/usr/bin:/bin:${PATH:-}"

CACHE="${CAMOUFOX_INSTALL_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/camoufox}"
PROFILE_ROOT="${CAMOUFOX_PROFILE_DIR:-$HOME/.camoufox/profiles}"
PROFILE_NAME="${CAMOUFOX_PROFILE:-default}"
PROFILE_DIR="$PROFILE_ROOT/$PROFILE_NAME"
LOG_DIR="${CAMOUFOX_LOG_DIR:-$HOME/.camoufox/logs}"
HOMEPAGE="${CAMOUFOX_HOMEPAGE:-https://duckduckgo.com}"
mkdir -p "$PROFILE_DIR" "$LOG_DIR"

resolve_bin() {
  if [[ -n "${CAMOUFOX_BINARY_PATH:-}" && -x "${CAMOUFOX_BINARY_PATH}" ]]; then
    printf '%s\n' "$CAMOUFOX_BINARY_PATH"
    return 0
  fi
  for c in "$CACHE/camoufox-bin" "$CACHE/camoufox"; do
    [[ -x "$c" ]] && { printf '%s\n' "$c"; return 0; }
  done
  return 1
}

BIN="$(resolve_bin)" || {
  echo "Camoufox binary not found under $CACHE" >&2
  echo "Run: npx camoufox fetch" >&2
  exit 1
}

ARGS=("-profile" "$PROFILE_DIR" "-no-remote")
if [[ $# -eq 0 ]]; then
  set -- "$HOMEPAGE"
fi

printf '[%s] linux profile=%s argv=%s\n' \
  "$(date '+%Y-%m-%d %H:%M:%S')" "$PROFILE_DIR" "$*" \
  >>"$LOG_DIR/desktop-launch.log" 2>/dev/null || true

exec "$BIN" "${ARGS[@]}" "$@"
EOF
  chmod +x "$launcher"

  cat >"$CFD_BIN_DIR/camoufox-app" <<EOF
#!/usr/bin/env bash
exec "$launcher" "\$@"
EOF
  chmod +x "$CFD_BIN_DIR/camoufox-app"

  local desktop="$HOME/.local/share/applications/camoufox.desktop"
  cat >"$desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Camoufox
GenericName=Web Browser
Comment=Anti-detect Firefox desktop launcher (unofficial)
Exec=$launcher %U
Terminal=false
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Keywords=browser;web;camoufox;firefox;
EOF

  if cfd_has update-desktop-database; then
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true
  fi

  printf '%s\n' "$launcher"
}

cfd_linux_uninstall() {
  rm -f "$CFD_BIN_DIR/camoufox-app"
  rm -f "$HOME/.local/share/applications/camoufox.desktop"
  rm -rf "$CFD_SHARE_DIR"
  cfd_info "Removed Linux launcher + desktop entry."
  cfd_info "Kept official cache: $(cfd_cache_dir) and profiles under $HOME/.camoufox"
}
