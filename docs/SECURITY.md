# Security

## What this project does

- Installs shell wrappers and (on macOS) a local `.app` that launches Camoufox.
- Invokes the official `camoufox` npm CLI (`fetch`) to download binaries into the user cache.

## What this project does not do

- Does not host or re-upload browser binaries.
- Does not require root/sudo.
- Does not collect telemetry.

## curl | bash

Prefer review first:

```bash
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/install.sh -o /tmp/cfd-install.sh
less /tmp/cfd-install.sh
bash /tmp/cfd-install.sh
```

## Upstream trust

Binary authenticity is the responsibility of the Camoufox project (https://github.com/daijro/camoufox).

## Reporting issues

Use GitHub Issues. Do not request help bypassing third-party terms of service.
