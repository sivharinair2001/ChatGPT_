import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/expense.dart';

/// Parses a receipt image into structured expense fields.
///
/// Set [apiKey] via Settings (stored locally). When empty, returns a
/// demo parse so you can walk the full UI on your iPhone without a key.
class ReceiptParseService {
  static const _endpoint = 'https://api.openai.com/v1/chat/completions';

  Future<ExpenseDraft> parseReceipt({
    required File imageFile,
    required String apiKey,
  }) async {
    if (apiKey.trim().isEmpty) {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      return ExpenseDraft.demo();
    }

    final bytes = await imageFile.readAsBytes();
    final b64 = base64Encode(bytes);
    final mime = imageFile.path.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';

    final body = {
      'model': 'gpt-4o-mini',
      'response_format': {'type': 'json_object'},
      'messages': [
        {
          'role': 'system',
          'content':
              'Extract receipt data. Return JSON keys: merchant (string), '
              'amount (number), currency (string, ISO like USD), '
              'date (YYYY-MM-DD or null), category (one of Food, Travel, '
              'Office, Shopping, Health, Other), notes (short string), '
              'confidence (0-1). Use the total amount charged.',
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Parse this receipt into expense fields.',
            },
            {
              'type': 'image_url',
              'image_url': {'url': 'data:$mime;base64,$b64'},
            },
          ],
        },
      ],
      'max_tokens': 300,
    };

    final res = await http
        .post(
          Uri.parse(_endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Parse failed (${res.statusCode}): ${res.body}');
    }

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    final content =
        decoded['choices'][0]['message']['content'] as String? ?? '{}';
    final map = jsonDecode(content) as Map<String, dynamic>;
    return ExpenseDraft.fromJson(map);
  }
}

class ExpenseDraft {
  final String merchant;
  final double amount;
  final String currency;
  final DateTime date;
  final String category;
  final String notes;
  final double confidence;

  ExpenseDraft({
    required this.merchant,
    required this.amount,
    required this.currency,
    required this.date,
    required this.category,
    required this.notes,
    this.confidence = 0.8,
  });

  factory ExpenseDraft.demo() => ExpenseDraft(
        merchant: 'Starbucks',
        amount: 6.45,
        currency: 'USD',
        date: DateTime.now(),
        category: 'Food',
        notes: 'Demo parse — add an API key in Settings for real receipts',
        confidence: 0.5,
      );

  factory ExpenseDraft.fromJson(Map<String, dynamic> json) {
    DateTime date;
    final rawDate = json['date'];
    if (rawDate is String && rawDate.isNotEmpty) {
      date = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      date = DateTime.now();
    }

    var category = (json['category'] as String?) ?? 'Other';
    if (!kCategories.contains(category)) category = 'Other';

    return ExpenseDraft(
      merchant: (json['merchant'] as String?)?.trim().isNotEmpty == true
          ? (json['merchant'] as String).trim()
          : 'Unknown merchant',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] as String?)?.toUpperCase() ?? 'USD',
      date: date,
      category: category,
      notes: (json['notes'] as String?) ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.7,
    );
  }
}
