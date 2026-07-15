#!/usr/bin/env bash
# camoufox-desktop installer
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/install.sh | bash
#
# Unofficial desktop launcher for daijro/camoufox.
# Does NOT redistribute binaries — downloads via official `camoufox` package.
set -euo pipefail

REPO_RAW_BASE="${CAMOUFOX_DESKTOP_RAW:-https://raw.githubusercontent.com/claudianus/camoufox-desktop/main}"
INSTALL_MODE="${1:-install}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"
if [[ -n "${SCRIPT_DIR:-}" && -f "$SCRIPT_DIR/lib/common.sh" ]]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/common.sh"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/macos.sh"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/linux.sh"
  CFD_FROM_CLONE=1
else
  CFD_FROM_CLONE=0
  TMPDIR_CFD="$(mktemp -d "${TMPDIR:-/tmp}/camoufox-desktop.XXXXXX")"
  cleanup() { rm -rf "$TMPDIR_CFD"; }
  trap cleanup EXIT

  echo "==> Fetching camoufox-desktop scripts..."
  for f in lib/common.sh lib/macos.sh lib/linux.sh; do
    mkdir -p "$TMPDIR_CFD/$(dirname "$f")"
    curl -fsSL "$REPO_RAW_BASE/$f" -o "$TMPDIR_CFD/$f"
  done
  # shellcheck source=/dev/null
  source "$TMPDIR_CFD/lib/common.sh"
  # shellcheck source=/dev/null
  source "$TMPDIR_CFD/lib/macos.sh"
  # shellcheck source=/dev/null
  source "$TMPDIR_CFD/lib/linux.sh"
fi

cfd_stash_helpers() {
  mkdir -p "$CFD_SHARE_DIR/lib"
  if [[ "$CFD_FROM_CLONE" == "1" ]]; then
    cp -f "$SCRIPT_DIR/lib/"*.sh "$CFD_SHARE_DIR/lib/" 2>/dev/null || true
    cp -f "$SCRIPT_DIR/uninstall.sh" "$CFD_SHARE_DIR/uninstall.sh" 2>/dev/null || true
  else
    for f in lib/common.sh lib/macos.sh lib/linux.sh uninstall.sh; do
      curl -fsSL "$REPO_RAW_BASE/$f" -o "$CFD_SHARE_DIR/$f" 2>/dev/null || true
    done
  fi
  chmod +x "$CFD_SHARE_DIR/uninstall.sh" 2>/dev/null || true
}

main() {
  local os
  os="$(cfd_os)"
  cfd_info "camoufox-desktop v${CFD_VERSION} ($os) — mode=$INSTALL_MODE"
  cfd_ensure_dirs

  case "$os" in
    macos|linux) ;;
    windows)
      cfd_die "Windows not supported yet. Use official camoufox via pip/npm, or WSL."
      ;;
    *)
      cfd_die "Unsupported OS: $(uname -s)"
      ;;
  esac

  cfd_ensure_binary

  case "$os" in
    macos)
      local app cli
      app="$(cfd_macos_install_app)"
      cli="$(cfd_macos_install_cli)"
      cfd_stash_helpers
      cat <<EOF

✓ Installed Camoufox desktop

  App:     $app
  CLI:     $cli
  Profile: $CFD_PROFILE_DIR
  Cache:   $(cfd_cache_dir)

Open:
  open -a Camoufox
  camoufox-app
  camoufox-app https://example.com

Dock pin (macOS):
  Finder → Go → Home → Applications → Camoufox → drag to Dock

Update:
  npx camoufox fetch
  curl -fsSL $REPO_RAW_BASE/install.sh | bash

Uninstall:
  curl -fsSL $REPO_RAW_BASE/uninstall.sh | bash
EOF
      cfd_path_hint
      ;;
    linux)
      local launcher
      launcher="$(cfd_linux_install_launcher)"
      cfd_stash_helpers
      cat <<EOF

✓ Installed Camoufox desktop launcher

  Launcher: $launcher
  CLI:      $CFD_BIN_DIR/camoufox-app
  Desktop:  ~/.local/share/applications/camoufox.desktop
  Profile:  $CFD_PROFILE_DIR

Open:
  camoufox-app
  camoufox-app https://example.com

Update:
  npx camoufox fetch
  curl -fsSL $REPO_RAW_BASE/install.sh | bash

Uninstall:
  curl -fsSL $REPO_RAW_BASE/uninstall.sh | bash
EOF
      cfd_path_hint
      ;;
  esac
}

main "$@"
