import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/expense.dart';
import 'providers/expense_provider.dart';
import 'screens/done_screen.dart';
import 'screens/home_screen.dart';
import 'screens/paywall_screen.dart';
import 'screens/review_expense_screen.dart';
import 'screens/settings_screen.dart';
import 'services/receipt_parse_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ReceiptLineApp());
}

class ReceiptLineApp extends StatelessWidget {
  const ReceiptLineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExpenseProvider()..load(),
      child: MaterialApp(
        title: 'ReceiptLine',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const HomeScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/review':
              final draft = settings.arguments as ExpenseDraft;
              return MaterialPageRoute(
                builder: (_) => ReviewExpenseScreen(draft: draft),
                settings: settings,
              );
            case '/done':
              final expense = settings.arguments as Expense;
              return MaterialPageRoute(
                builder: (_) => DoneScreen(expense: expense),
                settings: settings,
              );
            case '/paywall':
              return MaterialPageRoute(
                builder: (_) => const PaywallScreen(),
                settings: settings,
              );
            case '/settings':
              return MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
                settings: settings,
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
