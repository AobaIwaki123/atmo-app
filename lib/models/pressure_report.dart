class PressurePoint {
  final String time;
  final double pressure;
  final bool isCurrent;

  const PressurePoint({
    required this.time,
    required this.pressure,
    required this.isCurrent,
  });

  factory PressurePoint.fromJson(Map<String, dynamic> json) {
    return PressurePoint(
      time: json['time'] as String? ?? '',
      pressure: (json['pressure'] as num?)?.toDouble() ?? 0.0,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }
}

class PressureReport {
  final String updatedAt;
  final double currentPressure;
  final double diff3h;
  final double temperature;
  final String status;
  final String statusMessage;
  final List<PressurePoint> series;

  const PressureReport({
    required this.updatedAt,
    required this.currentPressure,
    required this.diff3h,
    required this.temperature,
    required this.status,
    required this.statusMessage,
    required this.series,
  });

  factory PressureReport.fromJson(Map<String, dynamic> json) {
    return PressureReport(
      updatedAt: json['updated_at'] as String? ?? '',
      currentPressure: (json['current_pressure'] as num?)?.toDouble() ?? 0.0,
      diff3h: (json['diff_3h'] as num?)?.toDouble() ?? 0.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'normal',
      statusMessage: json['status_message'] as String? ?? '',
      series: (json['series'] as List<dynamic>?)
              ?.map((item) => PressurePoint.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
