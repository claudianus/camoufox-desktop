#!/usr/bin/env bash
# Remove camoufox-desktop launchers (keeps official cache + profiles by default)
set -euo pipefail

REPO_RAW_BASE="${CAMOUFOX_DESKTOP_RAW:-https://raw.githubusercontent.com/claudianus/camoufox-desktop/main}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

if [[ -n "${SCRIPT_DIR:-}" && -f "$SCRIPT_DIR/lib/common.sh" ]]; then
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/common.sh"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/macos.sh"
  # shellcheck source=/dev/null
  source "$SCRIPT_DIR/lib/linux.sh"
elif [[ -f "${HOME}/.local/share/camoufox-desktop/lib/common.sh" ]]; then
  # shellcheck source=/dev/null
  source "${HOME}/.local/share/camoufox-desktop/lib/common.sh"
  # shellcheck source=/dev/null
  source "${HOME}/.local/share/camoufox-desktop/lib/macos.sh"
  # shellcheck source=/dev/null
  source "${HOME}/.local/share/camoufox-desktop/lib/linux.sh"
else
  TMPDIR_CFD="$(mktemp -d "${TMPDIR:-/tmp}/camoufox-desktop.XXXXXX")"
  cleanup() { rm -rf "$TMPDIR_CFD"; }
  trap cleanup EXIT
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

PURGE_ALL=0
for arg in "$@"; do
  case "$arg" in
    --purge|--all) PURGE_ALL=1 ;;
    -h|--help)
      cat <<'EOF'
Usage: uninstall.sh [--purge]

  (default)  Remove desktop app / CLI / desktop entry only
  --purge    Also delete official cache + ~/.camoufox profiles
EOF
      exit 0
      ;;
  esac
done

os="$(cfd_os)"
case "$os" in
  macos) cfd_macos_uninstall ;;
  linux) cfd_linux_uninstall ;;
  *) cfd_die "Unsupported OS for uninstall: $os" ;;
esac

if [[ "$PURGE_ALL" == "1" ]]; then
  cfd_info "Purging cache $(cfd_cache_dir) and $HOME/.camoufox ..."
  rm -rf "$(cfd_cache_dir)" "$HOME/.camoufox"
  cfd_info "Done."
else
  cfd_info "Cache kept: $(cfd_cache_dir)"
  cfd_info "Profiles kept: $HOME/.camoufox"
  cfd_info "Full wipe: uninstall.sh --purge"
fi
