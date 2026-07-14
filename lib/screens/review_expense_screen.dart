import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/expense_provider.dart';
import '../services/receipt_parse_service.dart';
import '../theme/app_theme.dart';

class ReviewExpenseScreen extends StatefulWidget {
  const ReviewExpenseScreen({super.key, required this.draft});

  final ExpenseDraft draft;

  @override
  State<ReviewExpenseScreen> createState() => _ReviewExpenseScreenState();
}

class _ReviewExpenseScreenState extends State<ReviewExpenseScreen> {
  late final TextEditingController _merchant;
  late final TextEditingController _amount;
  late final TextEditingController _notes;
  late DateTime _date;
  late String _category;
  late String _currency;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.draft;
    _merchant = TextEditingController(text: d.merchant);
    _amount = TextEditingController(text: d.amount.toStringAsFixed(2));
    _notes = TextEditingController(text: d.notes);
    _date = d.date;
    _category = d.category;
    _currency = d.currency;
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  String get _previewLine {
    final amount = double.tryParse(_amount.text) ?? 0;
    final tmp = Expense(
      id: 'preview',
      merchant: _merchant.text.trim().isEmpty ? 'Merchant' : _merchant.text.trim(),
      amount: amount,
      currency: _currency,
      date: _date,
      category: _category,
    );
    return tmp.copyLine;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2018),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save({bool copyToo = false}) async {
    final amount = double.tryParse(_amount.text.trim());
    if (_merchant.text.trim().isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a merchant and valid amount')),
      );
      return;
    }

    setState(() => _saving = true);
    final store = context.read<ExpenseProvider>();
    final expense = await store.saveDraft(
      widget.draft,
      merchant: _merchant.text.trim(),
      amount: amount,
      currency: _currency,
      date: _date,
      category: _category,
      notes: _notes.text.trim(),
    );
    if (copyToo) {
      await Clipboard.setData(ClipboardData(text: expense.copyLine));
    }
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pushReplacementNamed(
      '/done',
      arguments: expense,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review expense')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Text(
              'Check the fields, then save.',
              style: GoogleFonts.dmSans(color: AppColors.ink.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _merchant,
              decoration: const InputDecoration(labelText: 'Merchant'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _amount,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: const InputDecoration(labelText: 'Currency'),
                    items: const ['USD', 'EUR', 'GBP', 'INR', 'CAD']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => setState(() => _currency = v ?? 'USD'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date'),
                child: Text(DateFormat.yMMMd().format(_date)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Category', style: GoogleFonts.dmSans(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kCategories.map((c) {
                final selected = c == _category;
                return ChoiceChip(
                  label: Text(c),
                  selected: selected,
                  onSelected: (_) => setState(() => _category = c),
                  selectedColor: AppColors.leafSoft,
                  labelStyle: GoogleFonts.dmSans(
                    color: AppColors.ink,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.leafSoft.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Copy preview',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.leaf,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_previewLine, style: GoogleFonts.dmSans(fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : () => _save(),
              child: Text(_saving ? 'Saving…' : 'Save'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _saving ? null : () => _save(copyToo: true),
              child: const Text('Save & copy'),
            ),
          ],
        ),
      ),
    );
  }
}
