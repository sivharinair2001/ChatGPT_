import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:receiptline/providers/expense_provider.dart';
import 'package:receiptline/screens/home_screen.dart';
import 'package:receiptline/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('home shows brand, scan CTA, and empty state', (tester) async {
    final store = ExpenseProvider();
    await store.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: store,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ReceiptLine'), findsOneWidget);
    expect(find.textContaining('Receipt → expense'), findsOneWidget);
    expect(find.text('Scan a receipt'), findsOneWidget);
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.textContaining('free scans'), findsOneWidget);
  });
}
