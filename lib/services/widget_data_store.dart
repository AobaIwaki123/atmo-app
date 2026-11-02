import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../widgets/widget_content.dart';
import 'widget_integration_configuration.dart';

/// App Groupへウィジェット表示用の値を書き込む責務。
class WidgetDataStore {
  static Future<void> initialize() {
    return HomeWidget.setAppGroupId(WidgetIntegrationConfiguration.appGroupId);
  }

  static Future<void> save(WidgetContent content) async {
    const appGroupId = WidgetIntegrationConfiguration.appGroupId;
    await HomeWidget.saveWidgetData<String>(
      'location_name',
      content.locationName,
      appGroupId: appGroupId,
    );
    await HomeWidget.saveWidgetData<String>(
      'current_pressure',
      content.currentPressure.toStringAsFixed(1),
      appGroupId: appGroupId,
    );
    await HomeWidget.saveWidgetData<String>(
      'diff_3h',
      content.signedDiffText,
      appGroupId: appGroupId,
    );
    await HomeWidget.saveWidgetData<String>(
      'hour_text',
      content.hourText,
      appGroupId: appGroupId,
    );
    await HomeWidget.saveWidgetData<String>(
      'status',
      content.status,
      appGroupId: appGroupId,
    );
    await HomeWidget.saveWidgetData<String>(
      'series_json',
      jsonEncode(content.pressures),
      appGroupId: appGroupId,
    );
    await HomeWidget.saveWidgetData<String>(
      'current_index',
      content.currentIndex.toString(),
      appGroupId: appGroupId,
    );
  }
}
