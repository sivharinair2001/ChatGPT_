import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'state/app_controller.dart';
import 'theme/stride_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const StrideApp());
}

class StrideApp extends StatelessWidget {
  const StrideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppController()..init(),
      child: MaterialApp(
        title: 'Stride',
        debugShowCheckedModeBanner: false,
        theme: buildStrideTheme(),
        home: const HomeShell(),
      ),
    );
  }
}
