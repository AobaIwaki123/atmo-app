import 'package:flutter_test/flutter_test.dart';
import 'package:atmo_app/main.dart';

void main() {
  testWidgets('AtmoApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AtmoApp());
    expect(find.text('atmo'), findsOneWidget);
  });
}
