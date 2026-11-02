import 'package:flutter/material.dart';

/// ウィジェットの見た目を決める唯一のFlutter側トークン。
///
/// レイアウトファイルに色・文字サイズ・余白を直接書かず、ここを参照する。
abstract final class WidgetColors {
  static const surface = Color(0xFF101827);
  static const primaryText = Color(0xFFF8FAFC);
  static const secondaryText = Color(0xB8F8FAFC);
  static const tertiaryText = Color(0x78F8FAFC);
  static const mutedText = Color(0x5CF8FAFC);
  static const graph = Color(0xFF5CC8FF);
  static const normal = Color(0xFF62D6B0);
  static const notice = Color(0xFFF5C451);
  static const caution = Color(0xFFFF7A78);
  static const guide = Color(0x40FFFFFF);
  static const border = Color(0x14FFFFFF);
}

abstract final class WidgetSpacing {
  static const iconToText = 4.0;
  static const smallTop = 12.0;
  static const smallHorizontal = 14.0;
  static const mediumTop = 14.0;
  static const mediumHorizontal = 18.0;
  static const section = 6.0;
  static const chart = 5.0;
}

abstract final class WidgetMetrics {
  static const smallWidth = 158.0;
  static const smallHeight = 158.0;
  static const mediumWidth = 338.0;
  static const mediumHeight = 158.0;
  static const cardRadius = 24.0;
  static const smallIcon = 11.0;
  static const mediumIcon = 12.0;
  static const smallChartRadius = 12;
  static const mediumChartRadius = 18;
  static const mediumInfoWidth = 110.0;
  static const mediumColumnGap = 12.0;
  static const mediumChartStackGap = 4.0;
  static const mediumMetadataTop = 2.0;
  static const statusDot = 6.0;
}

abstract final class WidgetChartMetrics {
  static const plotBottom = 0.84;
  static const plotHeight = 0.66;
  static const strokeWidth = 2.2;
  static const guideStrokeWidth = 1.0;
  static const guideTop = 4.0;
  static const outerDotRadius = 4.0;
  static const innerDotRadius = 2.5;
  static const fillOpacity = 0.22;
}

abstract final class WidgetTypography {
  static const location = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: WidgetColors.primaryText,
  );

  static const locationMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: WidgetColors.primaryText,
  );

  static const timestamp = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: WidgetColors.secondaryText,
  );

  static const pressure = TextStyle(
    fontSize: 26,
    height: 1,
    fontWeight: FontWeight.w300,
    color: WidgetColors.primaryText,
  );

  static const pressureMedium = TextStyle(
    fontSize: 27,
    height: 1,
    fontWeight: FontWeight.w300,
    color: WidgetColors.primaryText,
  );

  static const unit = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: WidgetColors.tertiaryText,
  );

  static const axis = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: WidgetColors.mutedText,
  );

  static TextStyle delta(Color color) {
    return TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color);
  }
}

Color widgetStatusColor(String status) {
  switch (status) {
    case 'caution':
      return WidgetColors.caution;
    case 'notice':
      return WidgetColors.notice;
    default:
      return WidgetColors.normal;
  }
}
