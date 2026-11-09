import 'dart:convert';

import '../models/pressure_report.dart';
import 'widget_formatters.dart';

/// ウィジェットの描画に必要な値だけを持つ表示用モデル。
///
/// APIレスポンスのMapやFlutterのWidgetはここへ持ち込まない。
class WidgetContent {
  final String locationName;
  final double currentPressure;
  final double diff3h;
  final String updatedAt;
  final String status;
  final List<double> pressures;
  final int currentIndex;
  final double latitude;
  final double longitude;
  final String rawSeriesJson;

  const WidgetContent({
    required this.locationName,
    required this.currentPressure,
    required this.diff3h,
    required this.updatedAt,
    required this.status,
    required this.pressures,
    required this.currentIndex,
    this.latitude = 35.6895,
    this.longitude = 139.6917,
    this.rawSeriesJson = '[]',
  });

  factory WidgetContent.fromReport(PressureReport report) {
    final points = report.series;
    var currentIndex = points.indexWhere((point) => point.isCurrent);
    if (currentIndex < 0 && points.isNotEmpty) {
      currentIndex = points.length ~/ 2;
    }

    final rawList = report.raw['series'] as List<dynamic>? ?? const [];

    return WidgetContent(
      locationName: report.locationName.isNotEmpty
          ? report.locationName
          : '選択地点',
      currentPressure: report.currentPressure,
      diff3h: report.diff3h,
      updatedAt: report.updatedAt,
      status: report.status,
      pressures: List.unmodifiable(points.map((point) => point.pressure)),
      currentIndex: currentIndex,
      latitude: report.latitude,
      longitude: report.longitude,
      rawSeriesJson: jsonEncode(rawList),
    );
  }

  String get hourText => formatToHourZero(updatedAt);

  String get signedDiffText => formatSignedPressureDelta(diff3h);

  WidgetChartData chartData({required int radius}) {
    if (pressures.isEmpty) {
      return const WidgetChartData(pressures: [], currentIndex: -1);
    }

    final startIndex = (currentIndex - radius)
        .clamp(0, pressures.length)
        .toInt();
    final endIndex = (currentIndex + radius + 1)
        .clamp(0, pressures.length)
        .toInt();
    final visiblePressures = pressures.sublist(startIndex, endIndex);

    return WidgetChartData(
      pressures: visiblePressures,
      currentIndex: currentIndex - startIndex,
    );
  }
}

/// Small/Mediumで共有するグラフの表示用データ。
class WidgetChartData {
  final List<double> pressures;
  final int currentIndex;

  const WidgetChartData({required this.pressures, required this.currentIndex});
}
