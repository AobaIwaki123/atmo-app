# atmo App Store Connect リリース入力メモ

このファイルは、App Store Connectの入力・レビュー・著作権確認を一箇所に集約するための下書きです。公開前に、URLと連絡先が実際に到達できることを確認してください。

## アプリ識別情報

- アプリ名: `atmo`
- Bundle ID: `net.aooba.atmoApp`
- iOS Widget Extension: `net.aooba.atmoApp.AtmoWidgets`
- Team ID: `AL4Q7473XC`
- バージョン: `1.0.0 (1)`
- 著作権: `© 2026 Aoba Iwaki`
- 想定カテゴリ: Weather（最終決定はApp Store Connectで行う）

## プロダクトページ文案

### プロモーション用テキスト

> 気圧の変化を見える化。おおよその現在地から、48時間の気圧推移と体調変化の目安をすばやく確認できます。

### 概要

> atmoは、気圧の変化と気象病リスクの目安を確認できるアプリです。
>
> 現在地の利用を許可すると、おおよその位置情報だけを使って、周辺エリアの気圧を表示します。位置情報を許可しない場合は、既定地点のデータを利用できます。
>
> 主な機能:
> - 現在の気圧、気圧変化、体調変化の目安を表示
> - 48時間の気圧推移グラフ
> - iPhoneのホーム画面ウィジェット（Small / Medium）
> - 通信できない場合や位置情報を許可しない場合の既定地点表示
>
> 位置情報は通信前に広域メッシュへ丸め、ピンポイントの座標をAPIへ送信しません。ユーザーアカウント、広告、行動追跡はありません。
>
> ※表示内容は医療上の診断・治療を目的としたものではありません。体調に不安がある場合は医療専門家へ相談してください。

### キーワード案

`気圧,天気,気象病,頭痛,体調,天候,健康,予報,ウィジェット`

### URL

- 現行サポートURL: `https://atmo.aooba.net/support.html`
- 現行マーケティングURL: `https://atmo.aooba.net/`
- 現行プライバシーポリシーURL: `https://atmo.aooba.net/privacy-policy.html`
- 移行後の候補URL: `https://atmo.iorin.net/` / `https://atmo.iorin.net/support.html` / `https://atmo.iorin.net/privacy-policy.html`
- サポートメール: `support@iorin.net`

`atmo.iorin.net` のDNS・HTTPS・API配信が完了したら、App Store Connectには移行後URLを入力します。移行前に提出する場合は現行URLを使い、提出前に必ず実ブラウザで到達性を確認します。

## App Privacy申告案

現実の送信処理に合わせて申告します。位置情報は端末内だけで完結せず、丸めた座標をバックエンドへ送信するため、App Store Connectでは「収集なし」とせず次を確認します。

| 項目 | 入力案 |
| --- | --- |
| データタイプ | Location → Coarse Location |
| 利用目的 | App Functionality |
| ユーザーへの関連付け | No（アカウント・識別子と関連付けない） |
| トラッキング | No |
| その他 | 広告、分析SDK、アカウント、購入情報、連絡先、写真、健康情報は取得しない |

## App Review notes 文案

> 本アプリはアカウント登録なしで利用できます。位置情報を許可すると、おおよその位置を気圧データ取得に使用します。位置情報を拒否しても既定地点で利用できます。アプリ内の「i」ボタンから位置情報の扱いとデータ提供元を確認できます。ホーム画面ウィジェットは、アプリを起動してデータを更新した後に追加してください。レビュー時はインターネット接続が必要です。

## スクリーンショット方針

- Xcode Simulatorで、個人情報・通知・第三者コンテンツが写っていない状態を作って撮影する。
- まずiPhoneの主要サイズを用意し、App Store Connectの現在のアップロード要件に合うサイズで書き出す。
- 撮影済み候補: `docs/screenshots/atmo-iphone18pro-main.png`（1206×2622）、`docs/screenshots/atmo-ipad-pro13-main.png`（2064×2752）。
- 1枚目: 現在の気圧とステータスが分かるメイン画面。
- 2枚目: 48時間グラフと気圧変化。
- 3枚目: 位置情報の説明またはウィジェットプレビュー。
- iPadを販売対象にする場合は、iPad用の画面崩れを確認してからiPadスクリーンショットを追加する。

## 著作権・利用条件の提出前ゲート

1. `THIRD_PARTY_NOTICES.md` の帰属表示をアプリと公開ページで確認する。
2. Open-Meteo無料APIの非商用条件に、公開予定の運営形態が適合するか確認する。広告・課金を追加する場合はAPIプランを切り替える。
3. バックエンドのNominatim利用がUser-Agent、頻度制限、帰属表示の条件を満たしているか確認する。
4. アイコン・スクリーンショット・説明文に、他社の著作物・商標・ユーザーの個人情報がないことを確認する。
5. `support@iorin.net` を実際に作成し、`support.html` とApp Store Connectから到達できることを確認する。

## ユーザー側で最後に行う作業

- Apple Developerで `net.aooba.atmoApp` と `net.aooba.atmoApp.AtmoWidgets` のApp IDを確認する。
- App Group `group.net.aooba.atmo` を登録し、両App IDへ割り当てる。
- XcodeのSigning & CapabilitiesでAppleアカウントへサインインし、TeamとProvisioningを確認する。
- 仮メールアドレスを作成して動作確認する。
- App Store Connectでアプリレコードを作成し、本メモの文案・URL・スクリーンショットを入力する。
