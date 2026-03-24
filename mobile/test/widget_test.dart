import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile/app.dart';

void main() {
  testWidgets('QuickBite splash renders', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: QuickBiteApp()));
    await tester.pump();

    expect(find.text('QuickBite'), findsOneWidget);
  });
}
