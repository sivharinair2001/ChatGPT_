import 'package:athlete/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Stride app boots to Strava-style Home feed', (tester) async {
    await tester.pumpWidget(const StrideApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Record'), findsWidgets);
  });
}
