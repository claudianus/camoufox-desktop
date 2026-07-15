#!/usr/bin/env bash
# macOS desktop app installer for camoufox-desktop
# shellcheck shell=bash

cfd_macos_src_app() {
  local line kind path
  line="$(cfd_resolve)" || return 1
  kind="${line%%|*}"
  path="${line#*|}"
  if [[ "$kind" != "APP" ]]; then
    cfd_die "macOS expects Camoufox.app under $(cfd_cache_dir) (got: $path)"
  fi
  printf '%s\n' "$path"
}

cfd_macos_install_app() {
  local src target real_bin main_bin plist
  src="$(cfd_macos_src_app)"
  target="${CAMOUFOX_DESKTOP_APP:-$HOME/Applications/Camoufox.app}"

  cfd_info "Installing desktop app → $target"
  mkdir -p "$HOME/Applications"
  rm -rf "$target"

  if cp -Rc "$src" "$target" 2>/dev/null; then
    cfd_info "APFS clone complete (copy-on-write)."
  else
    cfd_info "Copying Camoufox.app (one-time)..."
    ditto "$src" "$target"
  fi

  real_bin="$target/Contents/MacOS/camoufox-real"
  main_bin="$target/Contents/MacOS/camoufox"
  if [[ -f "$main_bin" && ! -f "$real_bin" ]]; then
    mv "$main_bin" "$real_bin"
  fi
  chmod +x "$real_bin"

  # Firefox re-execs with -contentproc / -parentBuildID etc. — pass those through.
  cat >"$main_bin" <<'WRAP'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
REAL="$HERE/camoufox-real"
export PATH="${HOME}/.local/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:${PATH:-}"

PROFILE_ROOT="${CAMOUFOX_PROFILE_DIR:-$HOME/.camoufox/profiles}"
PROFILE_NAME="${CAMOUFOX_PROFILE:-default}"
PROFILE_DIR="$PROFILE_ROOT/$PROFILE_NAME"
LOG_DIR="${CAMOUFOX_LOG_DIR:-$HOME/.camoufox/logs}"
HOMEPAGE="${CAMOUFOX_HOMEPAGE:-https://duckduckgo.com}"
mkdir -p "$PROFILE_DIR" "$LOG_DIR"

# Subprocess / contentproc: do not inject profile flags
for a in "$@"; do
  case "$a" in
    -contentproc|-parentBuildID|-appDir|-greomni|-appomni|*contentproc*)
      exec "$REAL" "$@"
      ;;
  esac
done
# Also detect when -profile already present
for a in "$@"; do
  if [[ "$a" == "-profile" ]]; then
    exec "$REAL" "$@"
  fi
done

ARGS=("-profile" "$PROFILE_DIR" "-no-remote")
if [[ -n "${CAMOUFOX_PROXY:-}" ]]; then
  # Firefox network.proxy via env is limited; leave CLI open for future prefs
  :
fi

if [[ $# -eq 0 ]]; then
  set -- "$HOMEPAGE"
fi

printf '[%s] macos-app profile=%s argv=%s\n' \
  "$(date '+%Y-%m-%d %H:%M:%S')" "$PROFILE_DIR" "$*" \
  >>"$LOG_DIR/desktop-launch.log" 2>/dev/null || true

exec "$REAL" "${ARGS[@]}" "$@"
WRAP
  chmod +x "$main_bin"

  plist="$target/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Camoufox" "$plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string Camoufox" "$plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleName Camoufox" "$plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleName string Camoufox" "$plist"
  /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier app.camoufox.desktop" "$plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string app.camoufox.desktop" "$plist"

  xattr -dr com.apple.quarantine "$target" 2>/dev/null || true
  if command -v codesign >/dev/null 2>&1; then
    codesign --force --deep --sign - "$target" >/dev/null 2>&1 || true
  fi
  local lsregister="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"
  if [[ -x "$lsregister" ]]; then
    "$lsregister" -f "$target" >/dev/null 2>&1 || true
  fi

  printf '%s\n' "$target"
}

cfd_macos_install_cli() {
  local cli="$CFD_BIN_DIR/camoufox-app"
  cat >"$cli" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="${HOME}/.local/bin:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:${PATH:-}"
APP="${CAMOUFOX_DESKTOP_APP:-$HOME/Applications/Camoufox.app}"
if [[ ! -d "$APP" ]]; then
  echo "Camoufox.app not found at: $APP" >&2
  echo "Reinstall: curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/install.sh | bash" >&2
  exit 1
fi
if [[ $# -eq 0 ]]; then
  open -a "$APP"
else
  open -na "$APP" --args "$@"
fi
EOF
  chmod +x "$cli"
  printf '%s\n' "$cli"
}

cfd_macos_uninstall() {
  local target="${CAMOUFOX_DESKTOP_APP:-$HOME/Applications/Camoufox.app}"
  rm -rf "$target"
  rm -f "$CFD_BIN_DIR/camoufox-app"
  rm -rf "$CFD_SHARE_DIR"
  cfd_info "Removed app + CLI launcher."
  cfd_info "Kept official cache: $(cfd_cache_dir) and profiles under $HOME/.camoufox"
}
