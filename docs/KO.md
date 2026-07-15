# 한국어 빠른 안내

## 한 줄 설치

```bash
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/install.sh | bash
```

**필요:** macOS 13+ 또는 Linux, Node.js 20+ (`npx`)

## 실행

```bash
camoufox-app
camoufox-app https://example.com
open ~/Applications/Camoufox.app
```

Dock 고정: Finder → 이동 → 홈 → Applications → **Camoufox** → Dock으로 드래그

## 제거

```bash
curl -fsSL https://raw.githubusercontent.com/claudianus/camoufox-desktop/main/uninstall.sh | bash
```

## 참고

- [daijro/camoufox](https://github.com/daijro/camoufox) **비공식** 데스크톱 런처입니다.
- 바이너리는 공식 `npx camoufox fetch`로 받습니다.
- API 수준의 full anti-detect는 Python/JS 쪽이 더 완전합니다. 이 프로젝트는 앱처럼 쓰는 용도입니다.
