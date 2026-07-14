import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('ReceiptLine Pro')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unlimited receipt scans',
                style: GoogleFonts.fraunces(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Free includes ${ExpenseProvider.freeScansPerMonth} scans per month. Pro unlocks unlimited scans, CSV export, and custom categories.',
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.ink.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 24),
              _PlanCard(
                title: 'Yearly',
                price: '\$29.99 / year',
                badge: 'Best value',
                featured: true,
                onTap: store.isPro
                    ? null
                    : () async {
                        await store.unlockPro();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pro unlocked (demo purchase)')),
                          );
                          Navigator.pop(context);
                        }
                      },
              ),
              const SizedBox(height: 12),
              _PlanCard(
                title: 'Monthly',
                price: '\$3.99 / month',
                onTap: store.isPro
                    ? null
                    : () async {
                        await store.unlockPro();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pro unlocked (demo purchase)')),
                          );
                          Navigator.pop(context);
                        }
                      },
              ),
              const Spacer(),
              if (store.isPro)
                Center(
                  child: Text(
                    'You’re on Pro',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      color: AppColors.leaf,
                    ),
                  ),
                )
              else
                Text(
                  'StoreKit / RevenueCat will replace the demo unlock before App Store release.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.ink.withValues(alpha: 0.5),
                  ),
                ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => store.restorePurchases(),
                child: const Text('Restore purchases'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.onTap,
    this.badge,
    this.featured = false,
  });

  final String title;
  final String price;
  final String? badge;
  final bool featured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: featured ? AppColors.leaf : AppColors.paper,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: featured ? null : Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (badge != null) ...[
                      Text(
                        badge!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: featured ? Colors.white70 : AppColors.leaf,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      title,
                      style: GoogleFonts.fraunces(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: featured ? Colors.white : AppColors.ink,
                      ),
                    ),
                    Text(
                      price,
                      style: GoogleFonts.dmSans(
                        color: featured ? Colors.white70 : AppColors.ink.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: featured ? Colors.white : AppColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
