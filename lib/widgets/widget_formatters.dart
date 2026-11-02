/// ウィジェット表示専用の純粋な文字列フォーマッター。
String formatToHourZero(String isoTime) {
  try {
    final dateTime = DateTime.parse(isoTime).toLocal();
    return '${dateTime.hour.toString().padLeft(2, '0')}:00';
  } catch (_) {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:00';
  }
}

String formatSignedPressureDelta(double value) {
  return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(1)}';
}
