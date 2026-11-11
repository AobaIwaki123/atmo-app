# 作業規約

## 操作手段

- ファイル操作、ビルド、テスト、デプロイ、公開サービスの確認は、CLIまたはAPIを原則として使用する。
- GUI操作は、CLIやAPIでは提供されない操作、または画面表示の実機確認・スクリーンショット撮影が必要な場合に限る。
- GUI操作を行う場合も、準備・検証・成果物の保存は可能な限りCLIで行い、GUIでしかできない手順を明記する。

## ブランチ・リリース運用規約

- `main` ブランチへの直接 push は行わない。新機能の実装・改修・検証はトピックブランチで作業する。
- TestFlight検証を目的としたビルド・タグ付けを行う際、`main` に直接 push してはならない。検証用ブランチ（または検証用タグ）から配信し、実機確認が完了して正式リリースが決まるまで `main` にマージしない。
- ユーザーからリリースやTestFlight作成を指示された場合、`main` 本番反映を伴うのか、検証目的（ブランチ/検証用ビルド）なのかを確認・区別して実行する。

## ウィジェット設計規約

- Widgetのデザイン変更や責務分離を行うときは、先に [`docs/widget-design-system.md`](docs/widget-design-system.md) を読む。
- Widget作業では、再利用可能な手順を [`.agents/skills/solacare-widget-design/SKILL.md`](.agents/skills/solacare-widget-design/SKILL.md) に従う。
- 見た目の正本は `lib/widgets/widget_design_tokens.dart` と `ios/AtmoWidgets/AtmoWidgetDesign.swift` に集約し、レイアウト側へ色・文字サイズ・余白のリテラルを増やさない。
- データ変換、App Group保存、画像生成、WidgetKitのtimeline、Small/Mediumのレイアウトを別責務として扱う。
- Flutter画像レンダラーとSwiftUIフォールバックのどちらか一方だけを変更して完了としない。両者の情報階層と状態表示を確認する。
- デザイン変更は、実機または署名済みTestFlightでの表示確認を完了条件に含める。
