import 'package:flutter_test/flutter_test.dart';
import 'package:opensweeper/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OpenSweeperApp());

    // Verify that the app displays the title.
    expect(find.text('OpenSweeper'), findsOneWidget);
  });
}
