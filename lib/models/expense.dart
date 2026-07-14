import 'dart:convert';

class Expense {
  final String id;
  String merchant;
  double amount;
  String currency;
  DateTime date;
  String category;
  String notes;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    this.currency = 'USD',
    required this.date,
    required this.category,
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get copyLine =>
      '$merchant · \$${amount.toStringAsFixed(2)} · ${_fmt(date)} · $category';

  String get csvRow =>
      '"$merchant",${amount.toStringAsFixed(2)},$currency,${date.toIso8601String().split('T').first},"$category","$notes"';

  Map<String, dynamic> toJson() => {
        'id': id,
        'merchant': merchant,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'category': category,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        merchant: json['merchant'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'USD',
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String,
        notes: json['notes'] as String? ?? '',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static String encodeList(List<Expense> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<Expense> decodeList(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static String _fmt(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}

const kCategories = ['Food', 'Travel', 'Office', 'Shopping', 'Health', 'Other'];
