import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../widgets/atmo_medium_widget_view.dart';
import '../widgets/atmo_small_widget_view.dart';
import '../widgets/widget_content.dart';
import '../widgets/widget_design_tokens.dart';
import 'widget_integration_configuration.dart';

/// FlutterのWidget表示をApp Group内の画像へ変換する責務。
class WidgetImageRenderer {
  static Future<void> render(WidgetContent content) async {
    const appGroupId = WidgetIntegrationConfiguration.appGroupId;

    await HomeWidget.renderFlutterWidget(
      _renderable(
        AtmoSmallWidgetView(content: content),
        const Size(WidgetMetrics.smallWidth, WidgetMetrics.smallHeight),
      ),
      key: 'atmo_small_chart',
      logicalSize: const Size(
        WidgetMetrics.smallWidth,
        WidgetMetrics.smallHeight,
      ),
      pixelRatio: 3.0,
      appGroupId: appGroupId,
    );
    await HomeWidget.renderFlutterWidget(
      _renderable(
        AtmoMediumWidgetView(content: content),
        const Size(WidgetMetrics.mediumWidth, WidgetMetrics.mediumHeight),
      ),
      key: 'atmo_medium_chart',
      logicalSize: const Size(
        WidgetMetrics.mediumWidth,
        WidgetMetrics.mediumHeight,
      ),
      pixelRatio: 3.0,
      appGroupId: appGroupId,
    );
  }

  static Widget _renderable(Widget child, Size size) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Material(
        color: Colors.transparent,
        child: Directionality(textDirection: TextDirection.ltr, child: child),
      ),
    );
  }
}
