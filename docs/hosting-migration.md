# atmo ホスティング移行メモ

現行のバックエンド/Webホストは `atmo.aooba.net` です。将来は `atmo.iorin.net`（サブドメイン名は最終決定前）へ移行する想定です。

## 移行時の切り替え

FlutterアプリのAPI先は `ATMO_API_BASE_URL` で上書きできます。

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

- `atmo.iorin.net` のDNSを用意し、HTTPS証明書を有効化する。
- `GET /api/v1/pressure` が現行と同じJSON契約で応答する。
- CORS、レート制限、監視、アクセスログの方針を確認する。
- `/support.html` と `/privacy-policy.html` が同じドメインで200を返す。
- App Store ConnectのサポートURL、マーケティングURL、プライバシーポリシーURLを新ドメインへ差し替える。
- 旧 `aooba.net` ホストは、移行期間中にAPI互換または適切な移行案内を維持する。

移行完了後は、アーカイブ、TestFlight、実機で新ホストを使ったビルドを検証してからApp Storeへ提出します。
