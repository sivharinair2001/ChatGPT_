import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/expense.dart';
import '../services/receipt_parse_service.dart';

class ExpenseProvider extends ChangeNotifier {
  static const freeScansPerMonth = 5;
  static const _expensesKey = 'expenses_v1';
  static const _scansKey = 'scans_month_v1';
  static const _scansMonthKey = 'scans_month_label_v1';
  static const _proKey = 'is_pro_v1';
  static const _apiKeyKey = 'openai_api_key_v1';
  static const _currencyKey = 'default_currency_v1';

  final _uuid = const Uuid();
  final _parser = ReceiptParseService();

  List<Expense> expenses = [];
  int scansThisMonth = 0;
  bool isPro = false;
  String apiKey = '';
  String defaultCurrency = 'USD';
  bool loading = true;
  String? processingMessage;

  int get remainingFreeScans =>
      isPro ? 999 : (freeScansPerMonth - scansThisMonth).clamp(0, freeScansPerMonth);

  bool get canScan => isPro || scansThisMonth < freeScansPerMonth;

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_expensesKey);
    if (raw != null) {
      expenses = Expense.decodeList(raw)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    final monthLabel = _monthLabel(DateTime.now());
    final storedMonth = prefs.getString(_scansMonthKey);
    if (storedMonth != monthLabel) {
      await prefs.setString(_scansMonthKey, monthLabel);
      await prefs.setInt(_scansKey, 0);
      scansThisMonth = 0;
    } else {
      scansThisMonth = prefs.getInt(_scansKey) ?? 0;
    }

    isPro = prefs.getBool(_proKey) ?? false;
    apiKey = prefs.getString(_apiKeyKey) ?? '';
    defaultCurrency = prefs.getString(_currencyKey) ?? 'USD';

    loading = false;
    notifyListeners();
  }

  Future<void> setApiKey(String value) async {
    apiKey = value.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
    notifyListeners();
  }

  Future<void> setCurrency(String value) async {
    defaultCurrency = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, value);
    notifyListeners();
  }

  /// Simulated Purchase for MVP until StoreKit / RevenueCat is wired.
  Future<void> unlockPro() async {
    isPro = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_proKey, true);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    // Placeholder for RevenueCat restore.
    notifyListeners();
  }

  Future<ExpenseDraft> parseImage(File file) async {
    if (!canScan) {
      throw StateError('free_quota_exhausted');
    }
    processingMessage = 'Reading receipt…';
    notifyListeners();
    try {
      final draft = await _parser.parseReceipt(imageFile: file, apiKey: apiKey);
      await _consumeScan();
      return draft;
    } finally {
      processingMessage = null;
      notifyListeners();
    }
  }

  Future<Expense> saveDraft(ExpenseDraft draft, {
    String? merchant,
    double? amount,
    String? currency,
    DateTime? date,
    String? category,
    String? notes,
  }) async {
    final expense = Expense(
      id: _uuid.v4(),
      merchant: merchant ?? draft.merchant,
      amount: amount ?? draft.amount,
      currency: currency ?? draft.currency,
      date: date ?? draft.date,
      category: category ?? draft.category,
      notes: notes ?? draft.notes,
    );
    expenses.insert(0, expense);
    await _persist();
    notifyListeners();
    return expense;
  }

  Future<void> deleteExpense(String id) async {
    expenses.removeWhere((e) => e.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _consumeScan() async {
    scansThisMonth += 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scansKey, scansThisMonth);
    await prefs.setString(_scansMonthKey, _monthLabel(DateTime.now()));
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_expensesKey, Expense.encodeList(expenses));
  }

  String _monthLabel(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
}
