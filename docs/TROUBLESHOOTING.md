# Troubleshooting

## Node / npx missing

Install Node 20+ then re-run install.

## Binary not found

```bash
npx camoufox fetch
npx camoufox path
npx camoufox version
```

## CLI not found

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## macOS won't open

```bash
xattr -dr com.apple.quarantine ~/Applications/Camoufox.app
codesign --force --deep --sign - ~/Applications/Camoufox.app
open -a Camoufox
```

## Reset profile

```bash
rm -rf ~/.camoufox/profiles/default
```

## Logs

```bash
tail -f ~/.camoufox/logs/desktop-launch.log
```
