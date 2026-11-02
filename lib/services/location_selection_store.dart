import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/location_option.dart';

/// 選択した代表地点を端末内のWidget共有領域へ保存する。
/// 端末の位置情報や外部ジオコーダーは使用しない。
class LocationSelectionStore {
  LocationSelectionStore._();

  static const String _key = 'selected_location_prefecture';
  static const String _appGroupId = 'group.net.aooba.atmo';

  static Future<LocationOption?> load() async {
    if (kIsWeb) return null;

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
    if (kIsWeb) return;

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
