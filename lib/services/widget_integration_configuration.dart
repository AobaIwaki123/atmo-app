/// OS連携に必要な識別子を一元管理する。
///
/// 気圧データやウィジェットの見た目は、このファイルを参照しない。
/// App Group・プロバイダ名・WidgetKitのkindだけをここに置く。
abstract final class WidgetIntegrationConfiguration {
  static const appGroupId = 'group.net.iorin.atmoapp.shared';

  static const smallAndroidProvider =
      'net.aooba.atmo_app.AtmoSmallWidgetProvider';
  static const mediumAndroidProvider =
      'net.aooba.atmo_app.AtmoMediumWidgetProvider';
  static const smallIOSWidget = 'AtmoSmallWidget';
}
