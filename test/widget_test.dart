import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:atmo_app/api/pressure_api.dart';
import 'package:atmo_app/main.dart';
import 'package:atmo_app/models/pressure_report.dart';

class _FakePressureApi extends PressureApi {
  _FakePressureApi() : super(endpoint: 'https://example.invalid');

  @override
  Future<PressureReport> fetchLatestReport({
    required double latitude,
    required double longitude,
  }) async {
    return PressureReport({
      'updated_at': '2026-11-02T08:00:00Z',
      'current_pressure': 1012.3,
      'diff_3h': -0.4,
      'temperature': 15,
      'status': 'normal',
      'status_message': '',
      'series': [
        {
          'time': '2026-11-02T06:00:00Z',
          'pressure': 1012.7,
          'is_current': false,
        },
        {
          'time': '2026-11-02T08:00:00Z',
          'pressure': 1012.3,
          'is_current': true,
        },
      ],
    });
  }
}

void main() {
  testWidgets('AtmoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AtmoApp());
    expect(find.text('ソラケア'), findsOneWidget);
  });

  testWidgets('地点選択画面を開いて代表地点を検索できる', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    const homeWidgetChannel = MethodChannel('home_widget');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(homeWidgetChannel, (call) async => null);
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(homeWidgetChannel, null),
    );

    await tester.pumpWidget(
      MaterialApp(home: PressureMonitorPage(api: _FakePressureApi())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final locationChip = find.text('選択地点: 東京都（東京）');
    await tester.ensureVisible(locationChip);
    await tester.tap(locationChip);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('地点を選択'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '札幌');
    tester.testTextInput.hide();
    tester.view.viewInsets = const FakeViewPadding();
    await tester.pump();
    expect(find.text('北海道'), findsOneWidget);
    expect(find.text('代表地点: 札幌'), findsOneWidget);

    final hokkaidoTile = find.ancestor(
      of: find.text('北海道'),
      matching: find.byType(ListTile),
    );
    expect(hokkaidoTile, findsOneWidget);
    tester.widget<ListTile>(hokkaidoTile).onTap!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('選択地点: 北海道（札幌）'), findsOneWidget);
  });
}
