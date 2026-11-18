import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atmo_app/widgets/atmo_lock_widget_view.dart';
import 'package:atmo_app/widgets/widget_content.dart';

void main() {
  testWidgets('ロック画面ウィジェット3種類が通常データでオーバーフローせず描画される', (
    WidgetTester tester,
  ) async {
    const content = WidgetContent(
      locationName: '東京都',
      currentPressure: 1012.3,
      diff3h: -1.4,
      updatedAt: '2026-11-02T08:00:00Z',
      status: 'normal',
      pressures: [1014.0, 1013.7, 1013.2, 1012.3, 1011.9],
      currentIndex: 3,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AtmoLockInlineWidgetView(content: content),
              AtmoLockCircularWidgetView(content: content),
              AtmoLockRectangularWidgetView(content: content),
            ],
          ),
        ),
      ),
    );

    expect(find.text('東京都 1012.3hPa (-1.4)'), findsOneWidget);
    expect(find.text('1012.3'), findsNWidgets(2));
    expect(find.text('-1.4'), findsNWidgets(2));
    expect(find.text('東京都'), findsOneWidget);
    expect(find.text('気圧'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('長い地点名と空のグラフデータでもロック画面ウィジェットが崩れない', (
    WidgetTester tester,
  ) async {
    const content = WidgetContent(
      locationName: 'とても長い都道府県名と代表地点名のテスト表示',
      currentPressure: 965.0,
      diff3h: 3.2,
      updatedAt: '2026-11-02T08:00:00Z',
      status: 'caution',
      pressures: [],
      currentIndex: -1,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: Column(
              children: [
                AtmoLockInlineWidgetView(content: content),
                AtmoLockCircularWidgetView(content: content),
                AtmoLockRectangularWidgetView(content: content),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('965.0'), findsNWidgets(2));
    expect(find.text('+3.2'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
