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
- **Fast Local Feedback**: Run and debug instantly in Chrome (`flutter run -d chrome`) without heavy mobile emulators.
- **Dark Mode & Data Visualization**: Smooth atmospheric pressure curves and real-time headache risk indicators.

## Implementation Roadmap

### Phase 1: Planning & API Integration (Current)
- [x] Repository initialized.
- [ ] Connect with `atmo` backend API (`GET /api/v1/pressure.json`).
- [ ] Display current atmospheric pressure, 3-hour delta ($\Delta P$), and caution badge.

### Phase 2: Web Preview & UI Prototyping
- [ ] Setup Flutter Web project structure.
- [ ] Implement responsive card-based layout (optimized for mobile preview in browser).
- [ ] Render 48-hour pressure chart using `fl_chart` or direct image render.

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
