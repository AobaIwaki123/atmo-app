import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';

import '../models/pressure_report.dart';
import '../widgets/widget_content.dart';
import 'widget_data_store.dart';
import 'widget_image_renderer.dart';
import 'widget_integration_configuration.dart';

/// データを表示用に変換し、各連携先へ更新を依頼するオーケストレーター。
///
/// App GroupのキーやWidgetのレイアウトは、ここでは扱わない。
class WidgetUpdateService {
  /// 初期化 (iOS App Group の登録など)
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await WidgetDataStore.initialize();
    } catch (e) {
      debugPrint('Failed to setAppGroupId: $e');
    }
  }

  /// 気圧レポートを表示用モデルへ変換し、App Groupとウィジェットを更新する。
  static Future<void> updateWidgets(PressureReport report) async {
    if (kIsWeb) return;

    try {
      final content = WidgetContent.fromReport(report);
      await WidgetDataStore.save(content);
      await WidgetImageRenderer.render(content);

      await HomeWidget.updateWidget(
        name: 'AtmoSmallWidgetProvider',
        androidName: 'AtmoSmallWidgetProvider',
        iOSName: WidgetIntegrationConfiguration.smallIOSWidget,
        qualifiedAndroidName:
            WidgetIntegrationConfiguration.smallAndroidProvider,
      );
      await HomeWidget.updateWidget(
        name: 'AtmoMediumWidgetProvider',
        androidName: 'AtmoMediumWidgetProvider',
        qualifiedAndroidName:
            WidgetIntegrationConfiguration.mediumAndroidProvider,
      );

      debugPrint('Home widgets updated successfully.');
    } catch (e, st) {
      debugPrint('Error updating home widgets: $e\n$st');
    }
  }
}
