import 'package:flutter_test/flutter_test.dart';
import 'package:receiptline/models/expense.dart';

void main() {
  test('Expense copyLine formats cleanly', () {
    final e = Expense(
      id: '1',
      merchant: 'Starbucks',
      amount: 6.45,
      date: DateTime(2026, 4, 12),
      category: 'Food',
    );
    expect(e.copyLine, 'Starbucks · \$6.45 · Apr 12 · Food');
  });

  test('Expense round-trips through JSON', () {
    final e = Expense(
      id: 'abc',
      merchant: 'Uber',
      amount: 18.2,
      date: DateTime(2026, 7, 14),
      category: 'Travel',
      notes: 'Airport',
    );
    final list = Expense.decodeList(Expense.encodeList([e]));
    expect(list.single.merchant, 'Uber');
    expect(list.single.amount, 18.2);
    expect(list.single.notes, 'Airport');
  });
}
