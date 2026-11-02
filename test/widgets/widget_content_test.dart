import 'package:flutter_test/flutter_test.dart';

import 'package:atmo_app/models/pressure_report.dart';
import 'package:atmo_app/widgets/widget_content.dart';

void main() {
  test('PressureReportからWidgetContentへ必要な値だけを変換する', () {
    final report = PressureReport({
      'updated_at': '2026-11-02T08:00:00Z',
      'current_pressure': 1012.3,
      'diff_3h': -0.4,
      'status': 'notice',
      'location_name': '北海道',
      'series': [
        {'pressure': 1012.7, 'is_current': false},
        {'pressure': 1012.3, 'is_current': true},
        {'pressure': 1012.1, 'is_current': false},
      ],
    });

    final content = WidgetContent.fromReport(report);

    expect(content.locationName, '北海道');
    expect(content.currentPressure, 1012.3);
    expect(content.signedDiffText, '-0.4');
    expect(content.currentIndex, 1);
    expect(content.pressures, [1012.7, 1012.3, 1012.1]);
  });

  test('currentがない場合はグラフ中央を選択する', () {
    final report = PressureReport({
      'updated_at': '2026-11-02T08:00:00Z',
      'series': [
        {'pressure': 1000.0, 'is_current': false},
        {'pressure': 1001.0, 'is_current': false},
        {'pressure': 1002.0, 'is_current': false},
        {'pressure': 1003.0, 'is_current': false},
      ],
    });

    final content = WidgetContent.fromReport(report);

    expect(content.currentIndex, 2);
    expect(content.chartData(radius: 1).pressures, [1001.0, 1002.0, 1003.0]);
    expect(content.chartData(radius: 1).currentIndex, 1);
  });

  test('地点名がない場合は選択地点を表示する', () {
    final content = WidgetContent.fromReport(
      PressureReport({'updated_at': '2026-11-02T08:00:00Z'}),
    );

    expect(content.locationName, '選択地点');
    expect(content.chartData(radius: 12).currentIndex, -1);
  });
}
