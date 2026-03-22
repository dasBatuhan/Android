import 'package:flutter_test/flutter_test.dart';

import 'package:abschluss/main.dart';

void main() {
  testWidgets('App startet mit MenuScreen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.text('Racing Game'), findsOneWidget);
    expect(find.text('Dein Name'), findsOneWidget);
  });
}
