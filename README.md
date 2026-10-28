# atmo-app

Cross-platform frontend application for **atmo** (Barometric Pressure & Weather-Headache Monitor).

Built with **Flutter** (supporting Web, iOS, Android, and macOS) connecting to the Go-based `atmo` caching API server.

## Concept & Architecture

```text
[ atmo-app (Flutter) ]
     │
     │ HTTP GET (JSON / PNG)
     ▼
[ atmo API Server (Go / in-memory cache) ]
     │
     │ Hourly background polling (1h)
     ▼
[ Open-Meteo Weather API ]
```

- **Minimalist & Clean Codebase**: Kept lightweight (1-2 main UI files) without bloated dependencies.
- **Privacy by Design (Zero-Knowledge Coarse Location)**:
  - **ピンポイント現在地の完全排除**: iOSの `NSLocationDefaultAccuracyReduced` により、OS レベルで数キロ四方の広域タイル中心点のみを強制供給。高精度 GPS（自宅・職場特定）のアプリ流入を物理遮断。
  - **10km固定メッシュスナップ**: クライアント内部で座標を `0.1度`（約10km）単位に丸めて通信。開発者のサーバーログや通信傍受でも居場所特定が原理的に不可能。
  - **ゼロ・インプット**: 地域の手動検索・切り替えという新たなペイン（UX低下）を生まず、移動先でも自動で安全に現在地周辺の気圧に追従。
- **Fast Local Feedback**: Run and debug instantly in Chrome (`make dev`) without heavy mobile emulators.
- **Dark Mode & Data Visualization**: Smooth atmospheric pressure curves and real-time headache risk indicators.

## Implementation Roadmap

### Phase 1: Planning & API Integration
- [x] Repository initialized.
- [x] Connect with `atmo` backend API (`GET /api/v1/pressure`).
- [x] Display current atmospheric pressure, 3-hour delta ($\Delta P$), and caution badge.

### Phase 2: Web Preview & UI Prototyping
- [x] Setup Flutter Web project structure.
- [x] Implement responsive card-based layout (optimized for mobile preview in browser).
- [x] Render 48-hour pressure chart using `fl_chart`.
- [x] UI component library evaluation & architectural decision ([docs/ui-library-evaluation.md](docs/ui-library-evaluation.md)).

### Phase 3: Mobile & Native Polish
- [ ] Build & test on iOS Simulator / Physical iPhone.
- [ ] Offline caching (local state persistence).
- [ ] Lock screen / Home screen widget integration.

## Getting Started

```bash
# 1. 依存パッケージの取得
make deps

# 2. Chrome で起動（ホットリロード有効）
make dev

# 3. macOS ネイティブで起動
make dev-macos

# 4. テスト & リント
make test
make lint

# 5. Web ビルド
make build
```
