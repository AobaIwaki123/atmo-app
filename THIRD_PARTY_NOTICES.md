# atmo 第三者データ・ライセンス表示

このファイルは、App Store提出前に確認する第三者データ・サービスの一覧です。

## Open-Meteo

気象データの取得元の一つとして [Open-Meteo](https://open-meteo.com/) を利用しています。Open-Meteoが案内するデータの帰属表示は次のとおりです。

> Weather data by [Open-Meteo.com](https://open-meteo.com/), licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

Open-Meteoの無料APIは非商用利用を前提とする条件があります。広告、サブスクリプション、有料機能などを追加する場合は、無料APIのまま公開せず、利用条件とAPIプランを再確認してください。

## OpenStreetMap / Nominatim

現在のアプリとWebサーバーは、地名の取得のためにOpenStreetMapまたはNominatimを呼び出していません。都道府県名と代表地点名は、アプリとサーバーに固定した47地点の一覧から表示します。

## Flutter packages

Flutter本体と `pubspec.yaml` に記載されたパッケージのライセンスは、各パッケージの配布物およびpub.devのライセンス表示に従います。App Store提出前に、依存パッケージのライセンス一覧を生成してアーカイブに同梱する必要があるか確認します。

## 著作権・商標チェック

- アプリアイコン、画面デザイン、スクリーンショット、説明文は開発者が作成したもの、または利用許諾を確認したものだけを使用します。
- Apple、Apple Weather、他社アプリのロゴ・画面・名称を、誤認を招く形で宣伝素材に使用しません。
- 実機スクリーンショットには、第三者の個人情報、通知、写真、著作権のある外部コンテンツを写し込みません。
- Open-Meteoの帰属表示とCC BY 4.0へのリンクが、アプリまたは公開ページから確認できることを提出前に確認します。
