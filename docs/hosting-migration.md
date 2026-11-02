# atmo ホスティング移行メモ

バックエンド/Webホストは `atmo.iorin.net` に統一します。`atmo.aooba.net` は移行期間中の旧URLとして扱い、公開メタデータでは新ドメインを優先します。

## 移行時の切り替え

FlutterアプリのAPI先は `ATMO_API_BASE_URL` で上書きできます。通常のビルドでは新ドメインが既定値です。

```bash
flutter build ipa --release \
  --dart-define=ATMO_API_BASE_URL=https://atmo.iorin.net/api/v1/pressure
```

Web版も同じ値を指定してビルドします。

```bash
flutter build web --release \
  --dart-define=ATMO_API_BASE_URL=https://atmo.iorin.net/api/v1/pressure
```

## DNS・配信前チェック

- `atmo.iorin.net` のDNSを用意し、Cloudflare Tunnel経由のHTTPSを有効化する。
- `GET /api/v1/pressure` が現行と同じJSON契約で応答する。
- CORS、レート制限、監視、アクセスログの方針を確認する。
- `/support.html` と `/privacy-policy.html` が新ドメインで200を返す。
- App Store ConnectのサポートURL、マーケティングURL、プライバシーポリシーURLを新ドメインへ差し替える。
- 旧 `atmo.aooba.net` ホストは、移行期間中にAPI互換または適切な移行案内を維持する。

移行完了後は、アーカイブ、TestFlight、実機で新ホストを使ったビルドを検証してからApp Storeへ提出します。
