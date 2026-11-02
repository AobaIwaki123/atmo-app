import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../models/pressure_report.dart';
import '../widgets/atmo_widget_preview.dart';

/// ホーム画面ウィジェットの更新を司るサービス
class WidgetUpdateService {
  static const String appGroupId = 'group.net.iorin.atmoapp.shared';
  static const String smallAndroidProvider =
      'net.aooba.atmo_app.AtmoSmallWidgetProvider';
  static const String mediumAndroidProvider =
      'net.aooba.atmo_app.AtmoMediumWidgetProvider';
  static const String smallIOSWidget = 'AtmoSmallWidget';

  /// 初期化 (iOS App Group の登録など)
  static Future<void> initialize() async {
    if (kIsWeb) return;
    try {
      await HomeWidget.setAppGroupId(appGroupId);
    } catch (e) {
      debugPrint('Failed to setAppGroupId: $e');
    }
  }

  /// 気圧レポート取得時にApp Groupへデータを書き込み、ウィジェットを更新する
  static Future<void> updateWidgets(PressureReport report) async {
    if (kIsWeb) return;

    try {
      await HomeWidget.saveWidgetData<String>(
        'location_name',
        report.locationName.isNotEmpty ? report.locationName : '選択地点',
        appGroupId: appGroupId,
      );
      await HomeWidget.saveWidgetData<String>(
        'current_pressure',
        report.currentPressure.toStringAsFixed(1),
        appGroupId: appGroupId,
      );
      await HomeWidget.saveWidgetData<String>(
        'diff_3h',
        '${report.diff3h >= 0 ? '+' : ''}${report.diff3h.toStringAsFixed(1)}',
        appGroupId: appGroupId,
      );
      await HomeWidget.saveWidgetData<String>(
        'hour_text',
        formatToHourZero(report.updatedAt),
        appGroupId: appGroupId,
      );
      await HomeWidget.saveWidgetData<String>(
        'status',
        report.status,
        appGroupId: appGroupId,
      );

      final series = report.series.map((point) => point.pressure).toList();
      var currentIndex = report.series.indexWhere((point) => point.isCurrent);
      if (currentIndex < 0 && series.isNotEmpty) {
        currentIndex = series.length ~/ 2;
      }
      await HomeWidget.saveWidgetData<String>(
        'series_json',
        jsonEncode(series),
        appGroupId: appGroupId,
      );
      await HomeWidget.saveWidgetData<String>(
        'current_index',
        currentIndex.toString(),
        appGroupId: appGroupId,
      );

      // アプリ本体と同じFlutter UIをApp Groupへ画像として保存する。
      // WidgetKit側はこの画像を優先し、画像生成に失敗した場合だけSwiftUIへフォールバックする。
      final smallImagePath = await HomeWidget.renderFlutterWidget(
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
        appGroupId: appGroupId,
      );
      final mediumImagePath = await HomeWidget.renderFlutterWidget(
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
        appGroupId: appGroupId,
      );
      debugPrint(
        'Home widget images saved: small=$smallImagePath, medium=$mediumImagePath',
      );

      // 小・中サイズを同じWidgetKit構成で提供する。
      await HomeWidget.updateWidget(
        name: 'AtmoSmallWidgetProvider',
        androidName: 'AtmoSmallWidgetProvider',
        iOSName: smallIOSWidget,
        qualifiedAndroidName: smallAndroidProvider,
      );

      // Android側の中サイズも従来どおり更新する。
      await HomeWidget.updateWidget(
        name: 'AtmoMediumWidgetProvider',
        androidName: 'AtmoMediumWidgetProvider',
        qualifiedAndroidName: mediumAndroidProvider,
      );

      debugPrint('Home widgets updated successfully.');
    } catch (e, st) {
      debugPrint('Error updating home widgets: $e\n$st');
    }
  }
}
