import 'package:flutter_test/flutter_test.dart';
import 'package:event_management_system/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EventManagementApp());
    expect(find.byType(EventManagementApp), findsOneWidget);
  });
}
