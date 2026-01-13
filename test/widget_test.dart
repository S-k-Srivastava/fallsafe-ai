import 'package:flutter_test/flutter_test.dart';
import 'package:fallsafe/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const FallSafeApp());
    expect(find.text('FallSafe'), findsOneWidget);
  });
}
