import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/app_config.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';
import 'reconciler.dart';
import 'router.dart';

class ValizimApp extends ConsumerStatefulWidget {
  const ValizimApp({super.key});

  @override
  ConsumerState<ValizimApp> createState() => _ValizimAppState();
}

class _ValizimAppState extends ConsumerState<ValizimApp> {
  late final GoRouter _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      // Light and dark both derive from one seed and follow the system setting.
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      builder: (BuildContext context, Widget? child) {
        // Reconciliation needs a localized context to write notification copy,
        // so it hangs here rather than in bootstrap.
        return ReminderReconciler(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
