import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _apiKey;

  @override
  void initState() {
    super.initState();
    _apiKey = TextEditingController(text: context.read<ExpenseProvider>().apiKey);
  }

  @override
  void dispose() {
    _apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text('Parsing', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(
            'Add an OpenAI API key to parse real receipt photos. Leave empty to use the demo parse and test the full flow on your iPhone.',
            style: GoogleFonts.dmSans(color: AppColors.ink.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apiKey,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'OpenAI API key',
              hintText: 'sk-…',
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: () async {
              await store.setApiKey(_apiKey.text);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key saved on device')),
                );
              }
            },
            child: const Text('Save API key'),
          ),
          const SizedBox(height: 28),
          Text('Defaults', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: store.defaultCurrency,
            decoration: const InputDecoration(labelText: 'Default currency'),
            items: const ['USD', 'EUR', 'GBP', 'INR', 'CAD']
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) {
              if (v != null) store.setCurrency(v);
            },
          ),
          const SizedBox(height: 28),
          Text('Subscription', style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(store.isPro ? 'Pro active' : 'Free plan'),
            subtitle: Text(
              store.isPro ? 'Unlimited scans' : '${store.remainingFreeScans} free scans left this month',
            ),
            trailing: TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/paywall'),
              child: Text(store.isPro ? 'Manage' : 'Upgrade'),
            ),
          ),
          TextButton(
            onPressed: () => store.restorePurchases(),
            child: const Text('Restore purchases'),
          ),
          const SizedBox(height: 20),
          Text(
            'Privacy',
            style: GoogleFonts.fraunces(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Receipt images are sent only to OpenAI when an API key is set. Expense history stays on this device. Demo mode never uploads photos.',
            style: GoogleFonts.dmSans(color: AppColors.ink.withValues(alpha: 0.65)),
          ),
        ],
      ),
    );
  }
}
