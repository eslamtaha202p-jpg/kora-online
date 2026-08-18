import 'package:flutter/material.dart';

import 'core/app_identity.dart';
import 'core/app_theme.dart';
import 'data/sports_repository.dart';
import 'screens/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KoraOnlineApp());
}

class KoraOnlineApp extends StatelessWidget {
  const KoraOnlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppIdentity.storeName,
      theme: AppTheme.dark,
      locale: const Locale('ar'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: AppShell(repository: SportsRepository()),
    );
  }
}
