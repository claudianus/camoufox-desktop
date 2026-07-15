# Camoufox Desktop

**Unofficial** desktop launcher for [daijro/camoufox](https://github.com/daijro/camoufox) — use the anti-detect Firefox build like a normal browser app.

> Not affiliated with Camoufox authors. We **do not ship** browser binaries. The official `camoufox` package downloads them.

<p align="center">
  <img alt="platform" src="https://img.shields.io/badge/platform-macOS%20%7C%20Linux-blue">
  <img alt="license" src="https://img.shields.io/badge/license-MIT-green">
  <img alt="upstream" src="https://img.shields.io/badge/upstream-daijro%2Fcamoufox-orange">
</p>

## Why

Camoufox is an open-source anti-detect browser aimed at scraping & AI agents. This project wraps the same official binary as:

- macOS: `~/Applications/Camoufox.app` (Dock-friendly)
- CLI: `camoufox-app`
- Linux: `.desktop` entry
- Persistent profile: `~/.camoufox/profiles/default`

## Install (one line)

**Requirements:** macOS 13+ or modern Linux, **Node.js 20+** (`npx`), network.

```bash
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/install.sh | bash
```

Or from a clone:

```bash
git clone https://github.com/claudianus/camoufox-desktop.git
cd camoufox-desktop
bash install.sh
```

### Open

```bash
# macOS
open -a Camoufox
camoufox-app
camoufox-app https://example.com

# Linux
camoufox-app
```

### Pin to Dock (macOS)

Finder → **Go → Home** → **Applications** → **Camoufox** → drag to Dock.

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/uninstall.sh | bash
```

Also delete official cache + profiles:

```bash
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/uninstall.sh | bash -s -- --purge
```

## What gets installed

| Item | Location |
|------|----------|
| macOS app | `~/Applications/Camoufox.app` |
| CLI | `~/.local/bin/camoufox-app` |
| Linux desktop entry | `~/.local/share/applications/camoufox.desktop` |
| Official binary cache | `~/Library/Caches/camoufox` (macOS) / `~/.cache/camoufox` (Linux) |
| Browser profile | `~/.camoufox/profiles/default` |

## Configuration

| Variable | Default | Meaning |
|----------|---------|---------|
| `CAMOUFOX_PROFILE` | `default` | Profile name |
| `CAMOUFOX_HOMEPAGE` | `https://duckduckgo.com` | Start URL |
| `CAMOUFOX_INSTALL_DIR` | OS cache | Official binary root |
| `CAMOUFOX_BINARY_PATH` | auto | Override executable |
| `CAMOUFOX_APP_PATH` | auto | Override source `.app` |
| `CAMOUFOX_DESKTOP_APP` | `~/Applications/Camoufox.app` | Installed app path |

```bash
CAMOUFOX_PROFILE=work camoufox-app
```

## Update

```bash
npx camoufox fetch
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/install.sh | bash
```

## Important limitations

- Full anti-detect fingerprint orchestration is designed for the **Python/JS Camoufox API**.
- This desktop launcher gives you a **persistent headed browser** from the official binary with a stable profile.
- For maximum stealth parity with the library, prefer the API (`headless=False`) or inject prefs into the profile.

## Security

- Prefer reviewing `install.sh` before `curl | bash`.
- Binaries come from the official Camoufox release pipeline via `npx camoufox fetch`.
- See [docs/SECURITY.md](docs/SECURITY.md).

## Related

- Upstream: https://github.com/daijro/camoufox  
- Sibling Chromium launcher: https://github.com/claudianus/cloakbrowser-desktop  
- Docs (KO): [docs/KO.md](docs/KO.md)

## License

MIT — see [LICENSE](LICENSE).
