import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_option.dart';

/// 選択した代表地点をモバイルではWidget共有領域、Webではブラウザの
/// ローカルストレージへ保存する。端末の位置情報や外部ジオコーダーは使用しない。
class LocationSelectionStore {
  LocationSelectionStore._();

  static const String _key = 'selected_location_prefecture';
  static const String _appGroupId = 'group.net.iorin.atmoapp';

  static Future<LocationOption?> load() async {
    if (kIsWeb) {
      try {
        final preferences = await SharedPreferences.getInstance();
        return LocationCatalog.byPrefecture(preferences.getString(_key));
      } catch (_) {
        return null;
      }
    }

    try {
      final prefecture = await HomeWidget.getWidgetData<String>(
        _key,
        appGroupId: _appGroupId,
      );
      return LocationCatalog.byPrefecture(prefecture);
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(LocationOption option) async {
    if (kIsWeb) {
      try {
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(_key, option.prefecture);
      } catch (_) {
        // Persisting the selection is best effort; the app remains usable.
      }
      return;
    }

    try {
      await HomeWidget.saveWidgetData<String>(
        _key,
        option.prefecture,
        appGroupId: _appGroupId,
      );
    } catch (_) {
      // Persisting the selection is best effort; the app remains usable.
    }
  }
}
