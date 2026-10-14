.PHONY: help dev run dev-macos build test lint clean deps

# デフォルトターゲット: ヘルプ表示
help:
	@echo "atmo-app コマンド一覧:"
	@echo "  make dev         - Web (Chrome) で立ち上げ（ホットリロード有効）"
	@echo "  make dev-macos   - macOS デスクトップアプリとして立ち上げ"
	@echo "  make build       - Web 配布用ビルド (build/web 出力)"
	@echo "  make test        - ユニット/ウィジェットテスト実行"
	@echo "  make lint        - 静的解析 (flutter analyze)"
	@echo "  make deps        - パッケージ依存解決 (flutter pub get)"
	@echo "  make clean       - ビルド成果物とキャッシュの削除"

# 開発用ローカル起動 (Web / Chrome)
dev:
	flutter run -d chrome

# エイリアス
run: dev

# macOS デスクトップ起動
dev-macos:
	flutter run -d macos

# Web 本番ビルド
build:
	flutter build web

# テスト実行
test:
	flutter test

# 静的解析
lint:
	flutter analyze

# 依存パッケージ取得
deps:
	flutter pub get

# キャッシュ・成果物クリーン
clean:
	flutter clean

# バックエンド (atmo) へ Web ビルドを同期
sync-backend: build
	@echo "Syncing build/web into ../atmo/web..."
	rm -rf ../atmo/web
	cp -r build/web ../atmo/web
	find ../atmo/web -name "*.symbols" -delete
	@echo "Sync complete!"

