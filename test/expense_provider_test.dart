import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:receiptline/providers/expense_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('demo parse saves expense and consumes free scan', () async {
    final store = ExpenseProvider();
    await store.load();
    expect(store.canScan, isTrue);
    expect(store.remainingFreeScans, ExpenseProvider.freeScansPerMonth);

    final tmp = File('${Directory.systemTemp.path}/demo_receipt.jpg');
    await tmp.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    final draft = await store.parseImage(tmp);
    expect(draft.merchant, isNotEmpty);
    expect(store.scansThisMonth, 1);

    final expense = await store.saveDraft(draft);
    expect(store.expenses.first.id, expense.id);
    expect(expense.copyLine, contains(expense.merchant));
  });

  test('quota blocks sixth free scan', () async {
    final store = ExpenseProvider();
    await store.load();
    final tmp = File('${Directory.systemTemp.path}/demo_receipt2.jpg');
    await tmp.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

    for (var i = 0; i < ExpenseProvider.freeScansPerMonth; i++) {
      await store.parseImage(tmp);
    }
    expect(store.canScan, isFalse);
    expect(
      () => store.parseImage(tmp),
      throwsA(isA<StateError>()),
    );
  });
}
