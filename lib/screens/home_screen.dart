import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _importReceipt(ImageSource source) async {
    final store = context.read<ExpenseProvider>();
    if (!store.canScan) {
      Navigator.of(context).pushNamed('/paywall');
      return;
    }

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null || !mounted) return;

    setState(() => _busy = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _ProcessingDialog(),
    );

    try {
      final draft = await store.parseImage(File(picked.path));
      if (!mounted) return;
      Navigator.of(context).pop(); // dialog
      Navigator.of(context).pushNamed('/review', arguments: draft);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      if (e is StateError && e.message == 'free_quota_exhausted') {
        Navigator.of(context).pushNamed('/paywall');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn’t read this receipt. Try another photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showImportSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a receipt',
                style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'On iPhone: take a photo or pick from Photos. (Share Sheet extension comes next.)',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(color: AppColors.ink.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Photos'),
                onTap: () {
                  Navigator.pop(ctx);
                  _importReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F2EC), AppColors.mist, Color(0xFFF7F3EA)],
          ),
        ),
        child: SafeArea(
          child: store.loading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'ReceiptLine',
                                style: GoogleFonts.fraunces(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Settings',
                              onPressed: () => Navigator.of(context).pushNamed('/settings'),
                              icon: const Icon(Icons.settings_outlined),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Receipt → expense in one share.',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: AppColors.ink.withValues(alpha: 0.72),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _QuotaBanner(
                              remaining: store.remainingFreeScans,
                              isPro: store.isPro,
                              onUpgrade: () => Navigator.of(context).pushNamed('/paywall'),
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: _busy ? null : _showImportSheet,
                              icon: const Icon(Icons.add_a_photo_outlined),
                              label: const Text('Scan a receipt'),
                            ),
                            const SizedBox(height: 28),
                            Text(
                              'Recent',
                              style: GoogleFonts.fraunces(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                    if (store.expenses.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_outlined,
                                  size: 56, color: AppColors.leaf.withValues(alpha: 0.7)),
                              const SizedBox(height: 14),
                              Text(
                                'No expenses yet',
                                style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Scan a receipt photo to create your first expense line.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.dmSans(
                                  color: AppColors.ink.withValues(alpha: 0.65),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                        sliver: SliverList.separated(
                          itemCount: store.expenses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final e = store.expenses[i];
                            return Dismissible(
                              key: ValueKey(e.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (_) => store.deleteExpense(e.id),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppColors.coral.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(Icons.delete_outline, color: AppColors.coral),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.paper.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.line.withValues(alpha: 0.7)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.leafSoft,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        e.category.characters.first,
                                        style: GoogleFonts.fraunces(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.leaf,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e.merchant,
                                            style: GoogleFonts.dmSans(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${e.category} · ${DateFormat.MMMd().format(e.date)}',
                                            style: GoogleFonts.dmSans(
                                              fontSize: 13,
                                              color: AppColors.ink.withValues(alpha: 0.55),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${e.amount.toStringAsFixed(2)}',
                                      style: GoogleFonts.dmSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _QuotaBanner extends StatelessWidget {
  const _QuotaBanner({
    required this.remaining,
    required this.isPro,
    required this.onUpgrade,
  });

  final int remaining;
  final bool isPro;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    final used = ExpenseProvider.freeScansPerMonth - remaining;
    final label = isPro
        ? 'Pro · unlimited scans'
        : '$used of ${ExpenseProvider.freeScansPerMonth} free scans this month';

    return Material(
      color: AppColors.paper.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: isPro ? null : onUpgrade,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                isPro ? Icons.verified_outlined : Icons.bolt_outlined,
                color: AppColors.leaf,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
              ),
              if (!isPro)
                Text(
                  'Upgrade',
                  style: GoogleFonts.dmSans(
                    color: AppColors.leaf,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProcessingDialog extends StatelessWidget {
  const _ProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          const CircularProgressIndicator(color: AppColors.leaf),
          const SizedBox(height: 18),
          Text(
            'Reading receipt…',
            style: GoogleFonts.fraunces(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Pulling merchant, amount, and date',
            style: GoogleFonts.dmSans(color: AppColors.ink.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}
