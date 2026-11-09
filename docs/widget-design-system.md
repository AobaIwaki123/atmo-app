# ソラケア ウィジェットデザインシステム

## 目的

ホーム画面で一目で「選択地点の現在気圧」と「これからの推移」を確認できることを目的とする。ウィジェットはアプリ画面の縮小版ではなく、短時間で判断できる表示面として設計する。

AppleのWidget HIGが示す「サイズごとに価値を持たせる」「小さいサイズは通常一つの情報を主役にする」「情報密度と視認性のバランスを取る」という方針を採用する。

## 正本と責務

デザインを確認するときは、次の順に読む。

1. この文書: 目的、情報階層、レイアウト規約、受け入れ条件
2. `lib/widgets/widget_design_tokens.dart`: Flutter画像レンダラーのトークン実装
3. `ios/AtmoWidgets/AtmoWidgetDesign.swift`: SwiftUIフォールバックのトークン実装
4. `lib/widgets/atmo_small_widget_view.dart` / `atmo_medium_widget_view.dart`: Flutterのサイズ別構成
5. `ios/AtmoWidgets/AtmoWidgetViews.swift`: SwiftUIフォールバックのサイズ別構成

API、App Group、WidgetKitの更新タイミングはデザインファイルへ入れない。データと連携の責務は次のファイル群が持つ。

- `lib/widgets/widget_content.dart`: `PressureReport`から表示用値への純粋な変換
- `lib/services/widget_data_store.dart`: App Groupへの値の保存
- `lib/services/widget_image_renderer.dart`: Flutter表示の画像化
- `lib/services/widget_update_service.dart`: 上記を順番に呼ぶオーケストレーター
- `ios/AtmoWidgets/AtmoWidgetStore.swift`: App Groupからの読み出しと画像読み出し
- `ios/AtmoWidgets/AtmoWidgetProvider.swift`: placeholder、snapshot、timeline
- `ios/AtmoWidgets/AtmoWidgetEntry.swift`: WidgetKitへ渡す値の型

レイアウトファイルからAPI、`UserDefaults`、App Groupキー、`PressureReport`のraw Mapへ直接アクセスしない。

## レンダラーの扱い

リリース構成では、SwiftUIネイティブ描画（`AtmoWidgetViews.swift`）を主経路とする。
これにより、Flutterアプリが起動していないバックグラウンド環境下でも、Widget Extension自らがAPIフェッチを行い、向こう24時間のタイムラインを自動で展開・定期更新する自律動作を実現する。

Flutter側（`widget_design_tokens.dart`）とSwift側（`AtmoWidgetDesign.swift`）のトークン（色、余白、タイポグラフィ、グラデーション塗り）は完全に1対1で統一されており、ピクセルパーフェクトな外観の一致を担保する。

### バックグラウンド更新とタイムライン設計

1. **API直接フェッチ**: `AtmoWidgetProvider.getTimeline` 内で `URLSession` を用い、最新の観測値と未来24時間の毎時推移を非同期取得する。
2. **未来タイムライン展開**: 取得した時系列データから、向こう24時間の各時刻ごとの `AtmoEntry` を生成して WidgetKit に渡す。通信が行われない時間帯やオフライン時であっても、OSが自動的に1時間ごとにその時刻の予報値へと表示を切り替える。
3. **オフライン・フォールバック**: 通信失敗時は、App Groupにキャッシュされた `full_series_json` から同様にタイムラインを再構成する。

## 情報階層

### Small

1. 地点名と観測時刻
2. 現在気圧（最重要）
3. 3時間差
4. 気圧推移グラフ

Smallではロゴ、説明文、長いステータスメッセージ、過剰な軸ラベルを追加しない。グラフは現在値を補足するものとし、現在気圧の読み取りを妨げない。

### Medium

1. 左側に地点名、時刻、現在気圧、3時間差
2. 右側に推移グラフ
3. グラフ下に「-12h / 現在 / +12h」の最小限の軸情報

MediumはSmallの内容を単純に引き伸ばさず、横長の空間をグラフへ割り当てる。

## トークン規約

- 背景は単一の深いネイビー面。レイアウト側で追加の大きな影を描かない。
- グラフは常に空色のアクセント色。正常・注意・警告の色は、差分値と状態点にだけ使う。
- 主要値は白に近い高コントラスト、地点名は主要値より一段下、時刻と単位は補助色にする。
- 書体はシステム標準。全テキストをRoundedへ寄せない。数値は桁の揺れを抑える。
- 余白は4pt系を基本とし、カードの角丸は一つの値を共有する。
- レイアウトファイルに色、フォントサイズ、角丸、固定寸法の新しいリテラルを追加しない。追加する場合は先にトークンとこの文書を更新する。
- 画像の外側にWidgetKitのコンテナと競合する影や二重の枠を作らない。

実装値はFlutterとSwiftで同じ意味を持たせる。両言語の値がずれた場合は、まずこの文書を更新し、その後に各実装を合わせる。

## 状態規約

- placeholder: 実データに見えない固定サンプルを使い、Widgetギャラリーで構成が確認できること
- データなし: 「アプリを開いて更新」の一つの案内だけを表示し、壊れたグラフや空のカードを出さない
- stale: 最後に保存した値を表示し、アプリの更新が必要な場合は補助情報で示す
- グラフ不足: 1点以下でもレイアウトが崩れず、値の表示を優先する
- 長い地点名: 1行、省略、隣の時刻や値と重ならないこと

## 受け入れ条件

デザイン変更時は、次を確認してからPRを作る。

1. `flutter analyze` と `flutter test` が成功する
2. Small、Medium、placeholder、データなしを確認する
3. iPhone実機または署名済みTestFlightビルドで、明るい壁紙・暗い壁紙の両方を確認する
4. 数字、単位、時刻、地点名が重ならず、画像の切り抜きがない
5. Flutter画像主経路とSwiftUIフォールバックで情報階層が一致する
6. 変更後のIPAを作る場合は、App GroupとWidget Extensionの署名を再確認する

## 参考

- [Apple Human Interface Guidelines: Widgets](https://developer.apple.com/design/human-interface-guidelines/widgets)
- [Apple Developer: TimelineProvider](https://developer.apple.com/documentation/widgetkit/timelineprovider/)
- [Apple Developer: Keeping a widget up to date](https://developer.apple.com/documentation/widgetkit/keeping-a-widget-up-to-date)
