import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots and shows splash', (tester) async {
    app.main();
    await tester.pump();

    expect(find.text('QuickBite'), findsOneWidget);
  }, timeout: Timeout.none);
}
