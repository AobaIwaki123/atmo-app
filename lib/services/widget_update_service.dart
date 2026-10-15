import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import '../models/pressure_report.dart';
import '../widgets/atmo_widget_preview.dart';

/// ホーム画面ウィジェットの更新を司るサービス
class WidgetUpdateService {
  static const String appGroupId = 'group.net.aooba.atmo';
  static const String smallAndroidProvider = 'net.aooba.atmo_app.AtmoSmallWidgetProvider';
  static const String mediumAndroidProvider = 'net.aooba.atmo_app.AtmoMediumWidgetProvider';
  static const String smallIOSWidget = 'AtmoSmallWidget';
  static const String mediumIOSWidget = 'AtmoMediumWidget';

  /// 初期化 (iOS App Group の登録など)
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('Failed to setAppGroupId: $e');
    }
  }

  /// 気圧レポート取得時にウィジェットをオフスクリーンレンダリングして更新
  static Future<void> updateWidgets(PressureReport report) async {
    if (kIsWeb) return;

    try {
      // 1. テキストデータを保存
      await HomeWidget.saveWidgetData<String>('location_name', report.locationName.isNotEmpty ? report.locationName : '現在地');
      await HomeWidget.saveWidgetData<String>('current_pressure', report.currentPressure.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('diff_3h', report.diff3h.toStringAsFixed(1));
      await HomeWidget.saveWidgetData<String>('hour_text', formatToHourZero(report.updatedAt));
      await HomeWidget.saveWidgetData<String>('status', report.status);

      // 2. Small ウィジェットの画像をオフスクリーンレンダリング
      await HomeWidget.renderFlutterWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AtmoSmallWidgetView(report: report),
          ),
        ),
        key: 'atmo_small_chart',
        logicalSize: const Size(158, 158),
        pixelRatio: 3.0,
      );

      // 3. Medium ウィジェットの画像をオフスクリーンレンダリング
      await HomeWidget.renderFlutterWidget(
        Material(
          color: Colors.transparent,
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: AtmoMediumWidgetView(report: report),
          ),
        ),
        key: 'atmo_medium_chart',
        logicalSize: const Size(338, 158),
        pixelRatio: 3.0,
      );

      // 4. プラットフォームにウィジェット更新を通知
      await HomeWidget.updateWidget(
        name: 'AtmoSmallWidgetProvider',
        androidName: 'AtmoSmallWidgetProvider',
        iOSName: smallIOSWidget,
        qualifiedAndroidName: smallAndroidProvider,
      );

      await HomeWidget.updateWidget(
        name: 'AtmoMediumWidgetProvider',
        androidName: 'AtmoMediumWidgetProvider',
        iOSName: mediumIOSWidget,
        qualifiedAndroidName: mediumAndroidProvider,
      );

      debugPrint('Home widgets updated successfully.');
    } catch (e, st) {
      debugPrint('Error updating home widgets: $e\n$st');
    }
  }
}
