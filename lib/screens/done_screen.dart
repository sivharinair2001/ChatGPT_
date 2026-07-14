import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/expense.dart';
import '../theme/app_theme.dart';

class DoneScreen extends StatelessWidget {
  const DoneScreen({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFDCEFE5), AppColors.mist],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.leaf,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 20),
                Text(
                  'Saved',
                  style: GoogleFonts.fraunces(fontSize: 34, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(
                    expense.copyLine,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: expense.copyLine));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied expense line')),
                      );
                    }
                  },
                  child: const Text('Copy again'),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
