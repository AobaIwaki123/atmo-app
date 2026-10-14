/// Dart 3 extension type によるゼロコスト・極小データラッパー
extension type PressurePoint(Map<String, dynamic> raw) {
  String get time => raw['time'] ?? '';
  double get pressure => (raw['pressure'] as num?)?.toDouble() ?? 0.0;
  bool get isCurrent => raw['is_current'] ?? false;
}

extension type PressureReport(Map<String, dynamic> raw) {
  String get updatedAt => raw['updated_at'] ?? '';
  double get currentPressure => (raw['current_pressure'] as num?)?.toDouble() ?? 0.0;
  double get diff3h => (raw['diff_3h'] as num?)?.toDouble() ?? 0.0;
  double get temperature => (raw['temperature'] as num?)?.toDouble() ?? 0.0;
  String get status => raw['status'] ?? 'normal';
  String get statusMessage => raw['status_message'] ?? '';
  bool get isCaution => status == 'caution';

  List<PressurePoint> get series =>
      (raw['series'] as List<dynamic>?)
          ?.map((e) => PressurePoint(e as Map<String, dynamic>))
          .toList() ??
      const [];
}
