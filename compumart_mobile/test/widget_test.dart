import 'package:flutter_test/flutter_test.dart';
import 'package:compumart_mobile/main.dart';

void main() {
  testWidgets('CompuMart app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CompuMartApp());
    expect(find.text('CompuMart'), findsWidgets);
  });
}
