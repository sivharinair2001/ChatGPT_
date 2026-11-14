import 'package:athlete/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Stride app boots to feed brand', (tester) async {
    await tester.pumpWidget(const StrideApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Stride'), findsWidgets);
  });
}
