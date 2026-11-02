---
name: solacare-widget-design
description: ソラケアのFlutter画像ウィジェットとiOS WidgetKitフォールバックを、共通の表示契約・デザイントークン・サイズ別レイアウト規約に沿って設計または変更する。
---

# ソラケア ウィジェット設計スキル

ウィジェットの実装・レビュー・デザイン変更では、最初に [`docs/widget-design-system.md`](../../../docs/widget-design-system.md) を読む。

## 責務の境界

- `WidgetContent` はAPIモデルからウィジェット表示用の値へ変換する。WidgetやApp Group APIを参照しない。
- `widget_design_tokens.dart` と `AtmoWidgetDesign.swift` は見た目のトークンだけを持つ。
- Small/Mediumのレイアウトはトークンと`WidgetContent`を受け取り、通信や保存を行わない。
- App Group保存は`WidgetDataStore`、画像生成は`WidgetImageRenderer`、WidgetKitの読み出しは`AtmoWidgetStore`、timelineは`AtmoWidgetProvider`が担当する。
- レイアウトファイルへ色・フォント・余白の新しいリテラルを追加しない。新しい意味の値が必要なら、デザイン文書と両言語のトークンを先に更新する。

## 変更手順

1. 変更が情報階層、状態、トークン、またはサイズ別レイアウトのどれかを分類する。
2. 表示値の変更なら`WidgetContent`とそのテストを先に変更する。
3. 見た目の変更ならデザイン文書、Flutterトークン、Swiftトークンを同時に確認する。
4. Small、Medium、placeholder、データなし、長い地点名を確認する。
5. `flutter analyze`、`flutter test`、`flutter build ios --simulator --no-codesign`を実行する。
6. 配信物へ反映する場合は、署名済み実機またはTestFlightで画像の切り抜き、重なり、アクセシビリティラベルを確認する。

現在の主経路はFlutterで生成したApp Group画像であり、SwiftUIはフォールバックである。Swift側だけを変更して表示確認を完了としない。
