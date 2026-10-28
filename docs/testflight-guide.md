# TestFlight 配信手順と運用ガイド

本ドキュメントは、`atmo-app` を有料の Apple Developer Program を用いて TestFlight へ配信し、実機検証および外部テストを行うための手順書です。

---

## 1. 配信の全体概要

| テスト種別 | 対象者 | Apple 審査 | 反映速度 | 主な用途 |
|---|---|---|---|---|
| **内部テスト (Internal Testing)** | Developer アカウントのメンバー（最大100人） | **不要**（審査なし） | アップロード処理完了後、即時配信 | 開発者本人・チーム内の動作検証 |
| **外部テスト (External Testing)** | メールアドレス招待、または公開リンク（最大10,000人） | **必要**（ベータ版審査、通常24h以内） | 審査通過後に配信開始 | 先行テスターへの配布、フィードバック収集 |

まずは審査不要で即座にインストール可能な **内部テスト** の開通を目指します。

---

## 2. 事前準備 (Apple Developer Portal / App Store Connect)

### 2.1. App ID の登録
1. [Apple Developer Certificates, Identifiers & Profiles](https://developer.apple.com/account/resources/identifiers/list) にアクセス。
2. 「Identifiers」の「＋」ボタンをクリックし、「App IDs」を選択して「Continue」。
3. タイプとして「App」を選択。
4. 以下の情報を入力:
   - **Description**: `atmo`
   - **Bundle ID**: `Explicit` を選択し、`net.aooba.atmoApp` を入力。
5. **Capabilities** リストから **「App Groups」** にチェックを入れる。
6. 「Continue」をクリックし、「Register」を完了する。

### 2.2. App Group の登録と紐付け
1. 再度「Identifiers」の「＋」をクリックし、右上のドロップダウンから **「App Groups」** を選択して「Continue」。
2. 以下の情報を入力:
   - **Description**: `atmo App Group`
   - **Identifier**: `group.net.aooba.atmo`
3. 「Register」を完了する。
4. 作成した App ID（`net.aooba.atmoApp`）をリストから開き、Capabilities の「App Groups」横の「Configure」または「Edit」をクリック。
5. 作成した `group.net.aooba.atmo` にチェックを入れて保存（Save）する。

### 2.3. App Store Connect での新規 App 作成
1. [App Store Connect](https://appstoreconnect.apple.com/) にサインイン。
2. 「マイ App」を開き、「＋」ボタンから「新規 App」を選択。
3. 以下の項目を設定:
   - **プラットフォーム**: `iOS` にチェック
   - **名前**: `atmo`（重複する場合は `atmo - 気圧アラート` 等）
   - **主要言語**: `日本語`
   - **バンドルID**: プルダウンから `net.aooba.atmoApp` を選択
   - **SKU**: 一意の英数字（例: `atmo-ios-001`）
   - **ユーザアクセス**: `完全アクセス`
4. 「作成」をクリック。

---

## 3. ビルドと TestFlight へのアップロード

### 3.1. Flutter による IPA ビルド
ターミナルから以下のコマンドを実行して、リリース用アーカイブおよび IPA ファイルを生成します。

```bash
flutter clean
flutter pub get
flutter build ipa --release
```

ビルドが完了すると、`build/ios/ipa/atmo_app.ipa` が生成されます。

### 3.2. App Store Connect へのアップロード

#### 方法 A: Transporter アプリを使用（推奨・最も簡便）
1. Mac App Store から無料の [Transporter](https://apps.apple.com/jp/app/transporter/id1450874784) をインストール。
2. Apple ID でサインイン。
3. 生成された `build/ios/ipa/atmo_app.ipa` を Transporter にドラッグ＆ドロップ。
4. 「配信」ボタンをクリックしてアップロード完了を待ちます。

#### 方法 B: Xcode Organizer を使用
1. `open ios/Runner.xcworkspace`
2. メニューバーの「Product」>「Archive」を実行。
3. オーガナイザー（Organizer）画面で「Distribute App」をクリックし、「App Store Connect」>「Upload」を選択してアップロード。

---

## 4. TestFlight での実機テスト手順

1. [App Store Connect](https://appstoreconnect.apple.com/) の「マイ App」>「atmo」>「TestFlight」タブを開きます。
2. ビルドのステータスが「処理中」から「テスト準備完了」に切り替わるのを待ちます（通常 5〜15分程度）。
3. 左メニューの「内部テスト」からグループを作成し、自身の Apple ID（メールアドレス）をテスターに追加します。
4. iPhone で公式「TestFlight」アプリを開き、「インストール」をタップします。
